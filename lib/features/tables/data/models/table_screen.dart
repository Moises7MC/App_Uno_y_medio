import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uno_y_medio/features/tables/presentation/providers/table_provider.dart';
import 'package:uno_y_medio/features/cash_management/presentation/providers/cash_flow_provider.dart';
import 'package:uno_y_medio/features/tables/data/models/table_model.dart';
import 'package:uno_y_medio/features/tables/domain/entities/table.dart';
import 'package:uno_y_medio/features/orders/presentation/screens/order_screen.dart';

class TableScreen extends StatefulWidget {
  const TableScreen({super.key});

  @override
  State<TableScreen> createState() => _TableScreenState();
}

class _TableScreenState extends State<TableScreen> {
  void _showOpenDialog(BuildContext context) {
    final TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Abrir Sesión de Caja'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Saldo Inicial (S/.)'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final double? initialBalance = double.tryParse(controller.text);
              if (initialBalance != null && initialBalance >= 0) {
                final cashFlowProvider = Provider.of<CashFlowProvider>(
                  context,
                  listen: false,
                );
                cashFlowProvider.openCashFlow(initialBalance);
                Navigator.of(ctx).pop();
              }
            },
            child: const Text('Abrir'),
          ),
        ],
      ),
    );
  }

  void _closeCashFlow(BuildContext context) {
    final tableProvider = Provider.of<TableProvider>(context, listen: false);
    final cashFlowProvider = Provider.of<CashFlowProvider>(context, listen: false);
    
    final occupiedTables = tableProvider.occupiedTables;

    if (occupiedTables.isNotEmpty) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('¡Mesas Pendientes!'),
          content: Text(
            'No puedes cerrar la caja. Aún hay ${occupiedTables.length} mesas con pedidos activos (ej: Mesa ${occupiedTables.first.id}).\n'
            'Debes cobrar y liberar todas las mesas primero.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Entendido'),
            ),
          ],
        ),
      );
      return;
    }

    final currentCashFlow = cashFlowProvider.currentCashFlow;
    if (currentCashFlow == null) return;

    final finalBalance = currentCashFlow.calculatedFinalBalance;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Caja Cerrada'),
        content: Text(
          'Caja ${currentCashFlow.id} cerrada.\n'
          'Inicio: S/. ${currentCashFlow.initialBalance.toStringAsFixed(2)}\n'
          'Ventas: S/. ${currentCashFlow.totalSales.toStringAsFixed(2)}\n'
          '----------------------\n'
          'Total en Caja: S/. ${finalBalance.toStringAsFixed(2)}',
        ),
        actions: [
          TextButton(
            onPressed: () {
              cashFlowProvider.closeCashFlow();
              Navigator.of(ctx).pop();
            },
            child: const Text('Aceptar y Cerrar'),
          ),
        ],
      ),
    );
  }

  void _selectTable(BuildContext context, TableModel table) async {
    final cashFlowProvider = Provider.of<CashFlowProvider>(
      context,
      listen: false,
    );

    // Validación: Caja debe estar abierta
    if (!cashFlowProvider.isCashFlowOpen) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Error! Debes abrir la caja antes de tomar pedidos.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final originalTotal = table.currentOrder.fold(
      0.0,
      (sum, item) => sum + (item.item.price * item.quantity),
    );

    // Navegación a OrderScreen
    final updatedTable = await Navigator.of(context).push(
      MaterialPageRoute(builder: (ctx) => OrderScreen(table: table)),
    );

    if (updatedTable != null && updatedTable is TableModel) {
      final updatedTotal = updatedTable.currentOrder.fold(
        0.0,
        (sum, item) => sum + (item.item.price * item.quantity),
      );

      // Si la mesa fue liberada (pasó de ocupada a libre)
      if (originalTotal > 0 && updatedTotal == 0) {
        cashFlowProvider.updateSales(originalTotal);
      }

      // Actualizar la mesa usando el Provider
      final tableProvider = Provider.of<TableProvider>(context, listen: false);
      tableProvider.updateTable(updatedTable);
    }
  }

  Widget _buildTableCard(BuildContext context, TableEntity tableEntity) {
    // Convertir TableEntity a TableModel
    final table = TableModel.fromEntity(tableEntity);
    
    Color color;
    String statusText;

    final isOccupied = table.currentOrder.isNotEmpty;

    if (isOccupied) {
      color = Colors.red.shade400;
      statusText = 'Ocupada (${table.currentOrder.length} ítems)';
    } else {
      color = Colors.green.shade400;
      statusText = 'Libre';
    }

    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: () => _selectTable(context, table),
        borderRadius: BorderRadius.circular(15),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            gradient: LinearGradient(
              colors: [color.withOpacity(0.8), color],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.table_bar,
                size: 40,
                color: Colors.white,
              ),
              const SizedBox(height: 10),
              Text(
                'Mesa ${table.id}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                statusText,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tableProvider = Provider.of<TableProvider>(context);
    final cashFlowProvider = Provider.of<CashFlowProvider>(context);
    
    final tables = tableProvider.tables;
    final currentTotal = cashFlowProvider.currentTotal;
    final isCashFlowOpen = cashFlowProvider.isCashFlowOpen;

    Widget cashButton;
    if (!isCashFlowOpen) {
      cashButton = ElevatedButton.icon(
        onPressed: () => _showOpenDialog(context),
        icon: const Icon(Icons.lock_open, color: Colors.white),
        label: const Text('Abrir Caja', style: TextStyle(color: Colors.white)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          padding: const EdgeInsets.symmetric(horizontal: 8),
        ),
      );
    } else {
      cashButton = ElevatedButton.icon(
        onPressed: () => _closeCashFlow(context),
        icon: const Icon(Icons.lock, color: Colors.white),
        label: Text(
          'Cerrar Caja (S/. ${currentTotal.toStringAsFixed(2)})',
          style: const TextStyle(color: Colors.white, fontSize: 13),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          padding: const EdgeInsets.symmetric(horizontal: 8),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Mesas del Restaurante',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: Center(child: cashButton),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
            childAspectRatio: 0.95,
          ),
          itemCount: tables.length,
          itemBuilder: (context, index) {
            return _buildTableCard(context, tables[index]);
          },
        ),
      ),
    );
  }
}