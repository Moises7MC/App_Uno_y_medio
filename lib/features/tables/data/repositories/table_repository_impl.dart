import 'package:uno_y_medio/features/tables/data/datasources/table_api_datasource.dart';

import '../../domain/entities/table.dart';
import '../../domain/repositories/table_repository.dart';
import '../models/table_model.dart';

class TableRepositoryImpl implements TableRepository {
  // Cambiamos el tipo de origen de datos a la nueva interfaz
  final TableApiDataSourceImpl dataSource;

  TableRepositoryImpl({required this.dataSource});

  @override
  Future<List<TableEntity>> getTables() { // <--- Método asíncrono
    return dataSource.getTables();
  }
  
  // Mantenemos los métodos locales por ahora
  // NOTA: getTableById y updateTable son temporales si no se usa API para ellos.
  // Idealmente, también harían llamadas a la API.

  @override
  TableEntity getTableById(int id) {
    // Implementación temporal para no romper la lógica actual
    // En un sistema real, se obtendría de un estado centralizado o API.
    throw UnimplementedError('getTableById no está implementado para la API.');
  }

  @override
  void updateTable(TableEntity table) {
    // Implementación temporal para no romper la lógica actual
    // En un sistema real, se enviaría una actualización a la API.
    print('Aviso: Mesa ${table.id} actualizada localmente. Pendiente de implementar API para guardar estado.');
  }
}