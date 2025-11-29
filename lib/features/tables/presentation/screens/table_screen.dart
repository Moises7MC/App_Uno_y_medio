import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uno_y_medio/features/tables/presentation/providers/table_provider.dart';
import 'package:uno_y_medio/features/cash_management/presentation/providers/cash_flow_provider.dart';
import 'package:uno_y_medio/features/tables/data/models/table_model.dart';
import 'package:uno_y_medio/features/tables/domain/entities/table.dart';
import 'package:uno_y_medio/features/orders/presentation/screens/order_screen.dart';
import 'package:uno_y_medio/features/cash_management/presentation/widgets/open_cash_dialog.dart';
import 'package:uno_y_medio/features/cash_management/presentation/widgets/close_cash_dialog.dart';
import 'package:uno_y_medio/features/tables/presentation/widgets/table_card.dart';

class TableScreen extends StatefulWidget {
  const TableScreen({super.key});

  @override
  State<TableScreen> createState() => _TableScreenState();
}

class _TableScreenState extends State<TableScreen> {
  // ... (funciones _showOpenDialog y _closeCashFlow se mantienen igual)

  void _showOpenDialog(BuildContext context) {
    OpenCashDialog.show(context);
  }

  void _closeCashFlow(BuildContext context) {
    CloseCashDialog.show(context);
  }

  void _selectTable(BuildContext context, TableModel table) async {
    final cashFlowProvider = Provider.of<CashFlowProvider>(
      context,
      listen: false,
    );

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
    final updatedTable = await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (ctx) => OrderScreen(table: table)));

    if (updatedTable != null && updatedTable is TableModel) {
      final updatedTotal = updatedTable.currentOrder.fold(
        0.0,
        (sum, item) => sum + (item.item.price * item.quantity),
      );

      // Bloque de código ORIGINAL que causaba el error:
      /*
      if (originalTotal > 0 && updatedTotal == 0) {
        // ERROR: La venta ya se registró en _clearTable en OrderScreen.dart
        // Esta llamada a updateSales ya no es válida ni necesaria.
        cashFlowProvider.updateSales(originalTotal); 
      }
      */
      
      // ELIMINAMOS EL BLOQUE OBSOLETO. La venta se registra EN EL DIÁLOGO DE CIERRE.

      // Solo actualizamos la mesa localmente (el Polling se encarga del estado de Caja)
      final tableProvider = Provider.of<TableProvider>(context, listen: false);
      tableProvider.updateTable(updatedTable);
    }
  }

  Widget _buildTableCard(BuildContext context, TableEntity tableEntity) {
    final table = TableModel.fromEntity(tableEntity);

    return TableCard(
      table: table,
      onTap: () => _selectTable(context, table),
      showItemCount: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    // ... (El resto del build se mantiene igual)
    final tableProvider = Provider.of<TableProvider>(context);
    final cashFlowProvider = Provider.of<CashFlowProvider>(context);

    final tables = tableProvider.tables;
    final currentTotal = cashFlowProvider.currentTotal;
    final isCashFlowOpen = cashFlowProvider.isCashFlowOpen;
    final isLoading = tableProvider.isLoading; // Usamos el loading de la tabla

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
          // Mostrar el total actual de la caja
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
      body: RefreshIndicator( 
        onRefresh: tableProvider.loadTables, // Usamos la función del provider
        child: isLoading
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 10),
                    Text('Cargando mesas desde el servidor...'),
                  ],
                ),
              )
            : tables.isEmpty
                ? const Center(
                    child: Text(
                      'No se encontraron mesas. Revisa la conexión con el servidor.',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  )
                : Padding(
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
      ),
    );
  }
}