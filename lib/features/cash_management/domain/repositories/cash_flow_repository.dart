import '../entities/cash_flow.dart';

abstract class CashFlowRepository {
  CashFlowEntity? getCurrentCashFlow();
  void openCashFlow(double initialBalance);
  void updateSales(double amount);
  void closeCashFlow();
  List<CashFlowEntity> getCashFlowHistory();
}