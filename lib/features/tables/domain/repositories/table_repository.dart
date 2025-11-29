import '../entities/table.dart';

abstract class TableRepository {
  // CAMBIO CLAVE: Ahora getTables debe ser asíncrono (Future)
  Future<List<TableEntity>> getTables();
  
  // Los otros métodos siguen siendo síncronos por ahora
  TableEntity getTableById(int id);
  void updateTable(TableEntity table);
}