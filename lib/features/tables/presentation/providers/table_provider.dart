import 'dart:async'; // Necesario para usar Timer
import 'package:flutter/foundation.dart';
import '../../domain/entities/table.dart';
import '../../domain/repositories/table_repository.dart';

class TableProvider extends ChangeNotifier {
  final TableRepository repository;

  List<TableEntity> _tables = [];
  bool _isLoading = false;
  
  Timer? _pollingTimer; // Variable para controlar el temporizador de sondeo

  TableProvider({required this.repository}) {
    loadTables();
    startPolling(); // Iniciar el sondeo activo al inicializar
  }

  // Getters (el resto se queda igual)
  List<TableEntity> get tables => _tables;
  bool get isLoading => _isLoading; 

  List<TableEntity> get occupiedTables {
    return _tables.where((table) => table.isOccupied).toList();
  }

  // *** LÓGICA DEL SONDEO (POLLING) ***

  void startPolling() {
    // Si el temporizador ya está activo, lo cancelamos para evitar duplicados.
    if (_pollingTimer != null) {
      _pollingTimer!.cancel();
    }
    
    // Configuramos un temporizador que se dispara cada 10 segundos (Duration)
    _pollingTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      print('Polling: Recargando lista de mesas desde la API...');
      loadTables(); 
    });
  }
  
  // Detenemos el temporizador cuando el proveedor se desecha (necesario)
  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  // Método asíncrono para cargar las mesas desde la API
  Future<void> loadTables() async {
    // Solo mostramos el indicador de carga en la primera carga, no en el polling
    if (_tables.isEmpty) {
      _isLoading = true;
      notifyListeners();
    }

    try {
      final fetchedTables = await repository.getTables();
      
      // Solo actualizamos si el contenido cambió para evitar redibujar innecesariamente
      if (!listEquals(_tables, fetchedTables)) {
        _tables = fetchedTables;
        notifyListeners();
      }
      
    } catch (e) {
      print('Error al cargar mesas en Provider durante el polling: $e');
    } finally {
      if (_isLoading) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  // Lógica de actualización de mesa (se mantiene igual, no es asíncrona)
  void updateTable(TableEntity table) {
    repository.updateTable(table);
    
    // Forzamos la actualización inmediata después de cambiar una mesa localmente
    // para que el estado se refleje instantáneamente en la UI
    final index = _tables.indexWhere((t) => t.id == table.id);
    if (index != -1) {
      _tables[index] = table;
    }
    notifyListeners();
    
    // Si queremos garantizar que el cambio local persista en la DB remota, 
    // podríamos llamar a una API de PUT/POST aquí (aún no implementada).
  }

  TableEntity getTableById(int id) {
    return _tables.firstWhere((table) => table.id == id);
  }
}