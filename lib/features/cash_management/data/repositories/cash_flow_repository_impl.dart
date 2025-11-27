import '../../domain/entities/cash_flow.dart';
import '../../domain/repositories/cash_flow_repository.dart';
import '../datasources/cash_flow_local_datasource.dart';
import '../models/cash_flow_model.dart';

class CashFlowRepositoryImpl implements CashFlowRepository {
  final CashFlowLocalDataSource dataSource;

  CashFlowRepositoryImpl({required this.dataSource});

  @override
  CashFlowEntity? getCurrentCashFlow() {
    return dataSource.getCurrentCashFlow();
  }

  @override
  void openCashFlow(double initialBalance) {
    final newCashFlow = CashFlowModel(
      id: DateTime.now().toIso8601String(),
      initialBalance: initialBalance,
      openingTime: DateTime.now(),
    );
    dataSource.saveCashFlow(newCashFlow);
  }

  @override
  void updateSales(double amount) {
    final current = dataSource.getCurrentCashFlow();
    if (current != null && !current.isClosed) {
      final updated = CashFlowModel.fromEntity(current).copyWith(
        totalSales: current.totalSales + amount,
      );
      dataSource.saveCashFlow(updated);
    }
  }

  @override
  void closeCashFlow() {
    final current = dataSource.getCurrentCashFlow();
    if (current != null) {
      final closed = CashFlowModel.fromEntity(current).copyWith(
        closingTime: DateTime.now(),
        finalBalance: current.calculatedFinalBalance,
      );
      dataSource.saveCashFlow(closed);
      dataSource.clearCashFlow();
    }
  }

  @override
  List<CashFlowEntity> getCashFlowHistory() {
    return dataSource.getCashFlowHistory();
  }
}