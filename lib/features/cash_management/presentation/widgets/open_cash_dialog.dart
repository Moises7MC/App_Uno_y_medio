import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cash_flow_provider.dart';

class OpenCashDialog extends StatelessWidget {
  const OpenCashDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController controller = TextEditingController();

    return AlertDialog(
      title: const Text('Abrir Sesión de Caja'),
      content: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
          labelText: 'Saldo Inicial (S/.)',
          prefixIcon: Icon(Icons.attach_money),
          border: OutlineInputBorder(),
        ),
        autofocus: true,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton.icon(
          onPressed: () {
            final double? initialBalance = double.tryParse(controller.text);
            if (initialBalance != null && initialBalance >= 0) {
              final cashFlowProvider = Provider.of<CashFlowProvider>(
                context,
                listen: false,
              );
              cashFlowProvider.openCashFlow(initialBalance);
              Navigator.of(context).pop();
              
              // Mostrar mensaje de éxito
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Caja abierta con S/. ${initialBalance.toStringAsFixed(2)}',
                  ),
                  backgroundColor: Colors.green,
                  duration: const Duration(seconds: 2),
                ),
              );
            } else {
              // Mostrar error si el valor no es válido
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Por favor ingresa un monto válido'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          icon: const Icon(Icons.lock_open),
          label: const Text('Abrir Caja'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
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
      builder: (ctx) => const OpenCashDialog(),
    );
  }
}