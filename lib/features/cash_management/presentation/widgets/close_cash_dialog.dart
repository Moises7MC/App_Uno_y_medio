import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cash_flow_provider.dart';
import '../../../tables/presentation/providers/table_provider.dart';
import '../../domain/entities/cash_flow.dart'; // Para usar CashFlowEntity

class CloseCashDialog extends StatelessWidget {
  const CloseCashDialog({super.key});

  final String _cajaApiUrl = 'http://localhost:8080/api/caja';

  // Función auxiliar para formatear la hora
  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
  
  // Widget auxiliar para las filas de resumen
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

  @override
  Widget build(BuildContext context) {
    final tableProvider = Provider.of<TableProvider>(context);
    final cashFlowProvider = Provider.of<CashFlowProvider>(context);
    
    final tableProviderActions = Provider.of<TableProvider>(context, listen: false);
    final cashFlowProviderActions = Provider.of<CashFlowProvider>(context, listen: false);
    
    final CashFlowEntity? currentCashFlow = cashFlowProvider.currentCashFlow;
    final List occupiedTables = tableProvider.occupiedTables; // Corregido el tipo a List

    // 1. Manejo de caja no abierta o mesas pendientes (flujo sin cambios)
    if (currentCashFlow == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ No hay una sesión de caja activa para cerrar.'),
            backgroundColor: Colors.red,
          ),
        );
      });
      return const SizedBox.shrink(); 
    }

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
          'Ejemplo: Mesa ${tableProvider.occupiedTables.first.id}\n\n'
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


    // 2. Resumen de Cierre (Si no hay mesas pendientes)
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
          onPressed: () async {
            // Guardar contexto para cerrarlo al final.
            final BuildContext dialogContext = context;

            try {
              // LLAMADA A LA API DE CIERRE: POST /api/caja/close
              final response = await http.post(
                Uri.parse('$_cajaApiUrl/close'),
                headers: { 'Content-Type': 'application/json' },
                body: json.encode({}), 
              );

              if (response.statusCode != 200) {
                throw Exception('Error al cerrar caja. Código: ${response.statusCode}');
              }
              
              // 1. ÉXITO: Sincronizar el estado (lo que pondrá currentCashFlow en null)
              await cashFlowProviderActions.loadCurrentCashFlow();
              
              // 2. Mostrar mensaje de confirmación
              ScaffoldMessenger.of(dialogContext).showSnackBar(
                SnackBar(
                  content: Text(
                    'Caja cerrada. Total registrado: S/. ${finalBalance.toStringAsFixed(2)}',
                  ),
                  backgroundColor: Colors.green,
                  duration: const Duration(seconds: 4),
                ),
              );
              
              // 3. Cerrar el diálogo solo si todo fue bien
              Navigator.of(dialogContext).pop();

            } catch (e) {
              print('ERROR API Cierre de Caja: $e');
              // Error, no cerramos el diálogo
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('❌ Error al cerrar caja: ${e.toString().split(':').last}'),
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 6),
                ),
              );
            }
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

  // Método estático para mostrar el diálogo fácilmente
  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (ctx) => const CloseCashDialog(),
    );
  }
}
