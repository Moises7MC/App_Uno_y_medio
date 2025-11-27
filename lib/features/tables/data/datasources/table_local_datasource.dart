import '../models/table_model.dart';

abstract class TableLocalDataSource {
  List<TableModel> getTables();
  TableModel getTableById(int id);
  void updateTable(TableModel table);
}

class TableLocalDataSourceImpl implements TableLocalDataSource {
  // Simulación de base de datos en memoria
  final List<TableModel> _tables = List.generate(
    5,
    (index) => TableModel(id: index + 1),
  );

  @override
  List<TableModel> getTables() {
    return List.from(_tables);
  }

  @override
  TableModel getTableById(int id) {
    return _tables.firstWhere((table) => table.id == id);
  }

  @override
  void updateTable(TableModel table) {
    final index = _tables.indexWhere((t) => t.id == table.id);
    if (index != -1) {
      _tables[index] = table;
    }
  }
}