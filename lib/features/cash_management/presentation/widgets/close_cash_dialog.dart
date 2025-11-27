import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cash_flow_provider.dart';
import '../../../tables/presentation/providers/table_provider.dart';

class CloseCashDialog extends StatelessWidget {
  const CloseCashDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final tableProvider = Provider.of<TableProvider>(context, listen: false);
    final cashFlowProvider = Provider.of<CashFlowProvider>(context, listen: false);
    
    final occupiedTables = tableProvider.occupiedTables;

    // Si hay mesas ocupadas, mostrar advertencia
    if (occupiedTables.isNotEmpty) {
      return AlertDialog(
        title: const Text('¡Mesas Pendientes!'),
        icon: const Icon(
          Icons.warning_amber_rounded,
          color: Colors.orange,
          size: 48,
        ),
        content: Text(
          'No puedes cerrar la caja. Aún hay ${occupiedTables.length} mesa${occupiedTables.length > 1 ? 's' : ''} con pedidos activos.\n\n'
          'Ejemplo: Mesa ${occupiedTables.first.id}\n\n'
          'Debes cobrar y liberar todas las mesas primero.',
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            child: const Text('Entendido'),
          ),
        ],
      );
    }

    // Si no hay mesas ocupadas, mostrar resumen de cierre
    final currentCashFlow = cashFlowProvider.currentCashFlow;
    if (currentCashFlow == null) {
      return AlertDialog(
        title: const Text('Error'),
        content: const Text('No hay una sesión de caja activa.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      );
    }

    final finalBalance = currentCashFlow.calculatedFinalBalance;

    return AlertDialog(
      title: const Text('Cerrar Caja'),
      icon: const Icon(
        Icons.receipt_long,
        color: Colors.blue,
        size: 48,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Resumen de la sesión:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
          _buildSummaryRow(
            'Saldo inicial:',
            'S/. ${currentCashFlow.initialBalance.toStringAsFixed(2)}',
            Colors.grey.shade700,
          ),
          const SizedBox(height: 8),
          _buildSummaryRow(
            'Ventas totales:',
            'S/. ${currentCashFlow.totalSales.toStringAsFixed(2)}',
            Colors.green.shade700,
          ),
          const Divider(height: 24, thickness: 2),
          _buildSummaryRow(
            'Total en caja:',
            'S/. ${finalBalance.toStringAsFixed(2)}',
            Colors.blue.shade700,
            isBold: true,
          ),
          const SizedBox(height: 16),
          Text(
            'Hora de apertura: ${_formatTime(currentCashFlow.openingTime)}',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
          Text(
            'Hora de cierre: ${_formatTime(DateTime.now())}',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton.icon(
          onPressed: () {
            cashFlowProvider.closeCashFlow();
            Navigator.of(context).pop();
            
            // Mostrar mensaje de confirmación
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Caja cerrada. Total: S/. ${finalBalance.toStringAsFixed(2)}',
                ),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 3),
              ),
            );
          },
          icon: const Icon(Icons.lock),
          label: const Text('Confirmar y Cerrar'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value, Color color, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isBold ? 16 : 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: color,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isBold ? 18 : 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  // Método estático para mostrar el diálogo fácilmente
  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (ctx) => const CloseCashDialog(),
    );
  }
}