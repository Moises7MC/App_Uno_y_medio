// screens/table_screen.dart

import 'package:flutter/material.dart';
// Importaciones de modelos
import 'package:uno_y_medio/models/table_model.dart';
import 'package:uno_y_medio/models/cash_flow_model.dart'; // Importamos el nuevo modelo

// Importamos la pantalla de pedidos que vamos a abrir
import 'order_screen.dart';

class TableScreen extends StatefulWidget {
  const TableScreen({super.key});

  @override
  State<TableScreen> createState() => _TableScreenState();
}

class _TableScreenState extends State<TableScreen> {
  // Lista de mesas en memoria (nuestra "base de datos" por ahora)
  final List<TableModel> _tables = List.generate(
    5, // 5 Mesas en total
    (index) => TableModel(id: index + 1), // Estado inicial: Libre
  );

  // NUEVO: El estado de la caja del día (null si está cerrada)
  CashFlowModel? _currentCashFlow;

  // --- LÓGICA DE FLUJO DE CAJA ---

  void _openCashFlow(double initialBalance) {
    setState(() {
      _currentCashFlow = CashFlowModel(
        id: DateTime.now().toIso8601String(),
        initialBalance: initialBalance,
        openingTime: DateTime.now(),
      );
    });
  }

  void _updateSales(double amount) {
    // Solo actualiza si la caja está abierta
    if (_currentCashFlow != null && !_currentCashFlow!.isClosed) {
      // Necesitamos llamar a setState para que el AppBar se reconstruya
      setState(() {
        _currentCashFlow!.totalSales += amount;
      });
    }
  }

  void _closeCashFlow() {
    if (_currentCashFlow == null) return;

    // NUEVO: Verificación de mesas abiertas/ocupadas
    final occupiedTables = _tables
        .where((t) => t.currentOrder.isNotEmpty)
        .toList();

    if (occupiedTables.isNotEmpty) {
      // Si hay mesas abiertas, mostramos una alerta de error.
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
      return; // Detiene el proceso de cierre.
    }

    // Si no hay mesas ocupadas, procedemos al cierre normal
    _showSummaryAndClose(_currentCashFlow!);
  }

  void _showSummaryAndClose(CashFlowModel closedFlow) {
    final finalBalance = closedFlow.initialBalance + closedFlow.totalSales;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Caja Cerrada'),
        content: Text(
          'Caja ${closedFlow.id} cerrada.\n'
          'Inicio: S/. ${closedFlow.initialBalance.toStringAsFixed(2)}\n'
          'Ventas: S/. ${closedFlow.totalSales.toStringAsFixed(2)}\n'
          '----------------------\n'
          'Total en Caja: S/. ${finalBalance.toStringAsFixed(2)}',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              // Cerramos la caja y reiniciamos el estado
              setState(() {
                closedFlow.closingTime =
                    DateTime.now(); // Marcamos como cerrada
                closedFlow.finalBalance = finalBalance;
                _currentCashFlow = null; // Reinicia para el siguiente día
              });
            },
            child: const Text('Aceptar y Cerrar'),
          ),
        ],
      ),
    );
  }

  // NUEVO: Diálogo para ingresar el saldo inicial
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
                _openCashFlow(initialBalance); // Abrir la caja
                Navigator.of(ctx).pop();
              } else {
                // Puedes añadir un SnackBar de error aquí
              }
            },
            child: const Text('Abrir'),
          ),
        ],
      ),
    );
  }

  // --- LÓGICA DE MESAS Y PEDIDOS ---

  // Función que se llamará al hacer clic en una mesa
  void _selectTable(TableModel table) async {
    // 1. VALIDACIÓN: Obligar a abrir caja antes de seleccionar una mesa
    if (_currentCashFlow == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Error! Debes abrir la caja antes de tomar pedidos.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Guardamos el total original ANTES de ir a la pantalla de pedido
    final originalTotal = table.currentOrder.fold(
      0.0,
      (sum, item) => sum + (item.item.price * item.quantity),
    );

    // 2. Navegación a la pantalla de Pedido y espera de resultados (updatedTable)
    final updatedTable = await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (ctx) => OrderScreen(table: table)));

    // 3. Si recibimos una mesa actualizada (el mesero guardó/liberó el pedido)
    if (updatedTable != null && updatedTable is TableModel) {
      // El pedido actualizado (puede ser vacío si se liberó la mesa)
      final updatedTotal = updatedTable.currentOrder.fold(
        0.0,
        (sum, item) => sum + (item.item.price * item.quantity),
      );

      // Verificamos si la mesa fue liberada y tenía un pedido
      if (originalTotal > 0 && updatedTotal == 0) {
        // Si el total pasó de >0 a 0, la venta se completó y liberó
        _updateSales(originalTotal);
      }

      setState(() {
        // Encontramos la posición de la mesa en la lista
        final index = _tables.indexWhere((t) => t.id == updatedTable.id);
        if (index != -1) {
          // Reemplazamos la mesa vieja con la nueva orden
          _tables[index] = updatedTable;
        }
      });
    }
  }

  // Widget que dibuja una sola mesa como una tarjeta bonita
  Widget _buildTableCard(TableModel table) {
    // Definición de estilo basado en el estado
    Color color;
    String statusText;
    // La mesa está ocupada si tiene ítems en la orden
    final isOccupied = table.currentOrder.isNotEmpty;

    if (isOccupied) {
      color = Colors.red.shade400;
      // Muestra la cantidad de ítems en la orden actual
      statusText = 'Ocupada (${table.currentOrder.length} ítems)';
    } else {
      color = Colors.green.shade400;
      statusText = 'Libre';
    }

    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        // InkWell proporciona el efecto visual al hacer clic (ripple effect)
        onTap: () => _selectTable(table),
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
                Icons.table_bar, // Icono corregido
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
    // Calcula el estado actual de la caja para el botón
    final double currentTotal =
        (_currentCashFlow?.initialBalance ?? 0) +
        (_currentCashFlow?.totalSales ?? 0);

    // Define el botón de caja según su estado
    Widget cashButton;

    if (_currentCashFlow == null) {
      // Caja no abierta -> Botón para abrir
      cashButton = ElevatedButton.icon(
        onPressed: () =>
            _showOpenDialog(context), // Mostrar diálogo para ingresar saldo
        icon: const Icon(Icons.lock_open, color: Colors.white),
        label: const Text('Abrir Caja', style: TextStyle(color: Colors.white)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          padding: const EdgeInsets.symmetric(horizontal: 8),
        ),
      );
    } else {
      // Caja abierta -> Botón para cerrar
      cashButton = ElevatedButton.icon(
        onPressed: _closeCashFlow,
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
        foregroundColor: Colors.white, // Color del texto en el AppBar
        elevation: 0,
        actions: [
          // Mostramos el estado/botón de la caja
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: Center(child: cashButton),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        // Usamos GridView para mostrar las mesas en un diseño de cuadrícula
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // 2 mesas por fila
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
            childAspectRatio: 0.95, // Corregido para evitar overflow
          ),
          itemCount: _tables.length,
          itemBuilder: (context, index) {
            return _buildTableCard(_tables[index]);
          },
        ),
      ),
    );
  }
}
