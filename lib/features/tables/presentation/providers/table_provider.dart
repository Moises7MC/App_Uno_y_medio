import 'package:flutter/foundation.dart';
import '../../domain/entities/table.dart';
import '../../domain/repositories/table_repository.dart';

class TableProvider extends ChangeNotifier {
  final TableRepository repository;

  List<TableEntity> _tables = [];

  TableProvider({required this.repository}) {
    loadTables();
  }

  List<TableEntity> get tables => _tables;

  List<TableEntity> get occupiedTables {
    return _tables.where((table) => table.isOccupied).toList();
  }

  void loadTables() {
    _tables = repository.getTables();
    notifyListeners();
  }

  void updateTable(TableEntity table) {
    repository.updateTable(table);
    loadTables();
  }

  TableEntity getTableById(int id) {
    return repository.getTableById(id);
  }
}