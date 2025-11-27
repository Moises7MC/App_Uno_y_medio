import '../../domain/entities/table.dart';
import '../../domain/repositories/table_repository.dart';
import '../datasources/table_local_datasource.dart';
import '../models/table_model.dart';

class TableRepositoryImpl implements TableRepository {
  final TableLocalDataSource dataSource;

  TableRepositoryImpl({required this.dataSource});

  @override
  List<TableEntity> getTables() {
    return dataSource.getTables();
  }

  @override
  TableEntity getTableById(int id) {
    return dataSource.getTableById(id);
  }

  @override
  void updateTable(TableEntity table) {
    dataSource.updateTable(TableModel.fromEntity(table));
  }
}