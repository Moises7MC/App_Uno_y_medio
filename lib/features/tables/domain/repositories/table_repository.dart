import '../entities/table.dart';

abstract class TableRepository {
  List<TableEntity> getTables();
  TableEntity getTableById(int id);
  void updateTable(TableEntity table);
}