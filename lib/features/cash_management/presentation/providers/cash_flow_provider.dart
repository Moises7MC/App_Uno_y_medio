import 'dart:convert';
import 'dart:async'; 
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../../domain/entities/cash_flow.dart';
import '../../domain/repositories/cash_flow_repository.dart';

// NOTA: Se asume que CashFlowEntity tiene un constructor fromJson/fromMap si no se usa CashFlowModel.

class CashFlowProvider extends ChangeNotifier {
  final CashFlowRepository repository; 
  CashFlowEntity? _currentCashFlow;
  
  // URL corregida a /api/caja
  final String _cajaApiUrl = 'http://localhost:8080/api/caja'; 
  Timer? _pollingTimer;

  CashFlowProvider({required this.repository}) {
    loadCurrentCashFlow(); 
    startPolling();
  }

  // Getters
  CashFlowEntity? get currentCashFlow => _currentCashFlow;
  bool get isCashFlowOpen => _currentCashFlow != null && !_currentCashFlow!.isClosed;
  
  double get currentTotal {
    // Calcula el balance final (Inicial + Ventas)
    if (_currentCashFlow == null) return 0.0;
    return _currentCashFlow!.initialBalance + _currentCashFlow!.totalSales;
  }

  // Polling y Dispose
  void startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      loadCurrentCashFlow();
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  // **********************************************
  // MÉTODO PÚBLICO REQUERIDO POR open_cash_dialog.dart
  // **********************************************
  Future<void> loadCurrentCashFlow() async {
    try {
      final response = await http.get(Uri.parse(_cajaApiUrl));
      
      if (response.statusCode == 200) {
        // Caja ABIERTA
        final jsonResponse = json.decode(utf8.decode(response.bodyBytes));

        // Mapeo simple de la respuesta JSON del backend a la entidad Dart
        _currentCashFlow = CashFlowEntity(
          id: jsonResponse['id'].toString(),
          initialBalance: (jsonResponse['initialBalance'] as num).toDouble(),
          totalSales: (jsonResponse['totalSales'] as num).toDouble(),
          // Debemos manejar la conversión de String a DateTime
          openingTime: DateTime.parse(jsonResponse['openingTime']),
          finalBalance: (jsonResponse['finalBalance'] as num).toDouble(),
          closingTime: jsonResponse['closingTime'] != null 
              ? DateTime.parse(jsonResponse['closingTime']) 
              : null,
        );
      } else if (response.statusCode == 404) {
        // Caja CERRADA o no existe ninguna sesión
        _currentCashFlow = null; 
      }
    } catch (e) {
      print('Error de conexión al cargar caja: $e');
    } finally {
      notifyListeners();
    }
  }

  // Nota: Los métodos openCashFlow, updateSales, etc. (que usaban lógica local)
  // ya no son necesarios aquí, pues la lógica de la API reside en los diálogos
  // y solo se llama a loadCurrentCashFlow() para actualizar el estado.
}