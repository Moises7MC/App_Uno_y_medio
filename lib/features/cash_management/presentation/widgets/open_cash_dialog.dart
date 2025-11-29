import 'dart:convert'; // Necesario para json.encode
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cash_flow_provider.dart';

class OpenCashDialog extends StatelessWidget {
  const OpenCashDialog({super.key});
  
  // URL CORREGIDA: Usamos /api/caja
  final String _cajaApiUrl = 'http://localhost:8080/api/caja'; 

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
          onPressed: () async { 
            final double? initialBalance = double.tryParse(controller.text);
            
            if (initialBalance != null && initialBalance >= 0) {
              final cashFlowProvider = Provider.of<CashFlowProvider>(
                context,
                listen: false,
              );
              
              try {
                // LLAMADA A LA API DE APERTURA: /api/caja/open
                final response = await http.post(
                  Uri.parse('$_cajaApiUrl/open'),
                  headers: { 'Content-Type': 'application/json' },
                  body: json.encode({
                    "initialBalance": initialBalance.toStringAsFixed(2),
                  }),
                );
                
                if (response.statusCode == 201) { // 201 CREATED
                  // Si la API es exitosa, actualizamos el estado local del provider
                  // Esto fuerza al provider a hacer GET /api/caja y actualizar la UI
                  await cashFlowProvider.loadCurrentCashFlow(); 
                  Navigator.of(context).pop();
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Caja abierta con S/. ${initialBalance.toStringAsFixed(2)}',
                      ),
                      backgroundColor: Colors.green,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                } else if (response.statusCode == 409) { 
                    throw Exception('Ya existe una sesión de caja abierta.');
                } else {
                    // Muestra el error de Spring Boot si no es 201 o 409
                    final errorBody = json.decode(response.body);
                    final errorMessage = errorBody['message'] ?? 'Error desconocido';
                    throw Exception('Error al abrir la caja: ${errorMessage}');
                }
              } catch (e) {
                print('Error API Abrir Caja: $e');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('❌ Error al abrir caja: ${e.toString().split(':').last}'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            } else {
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

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (ctx) => const OpenCashDialog(),
    );
  }
}