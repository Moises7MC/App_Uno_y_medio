import '../models/cash_flow_model.dart';

abstract class CashFlowLocalDataSource {
  CashFlowModel? getCurrentCashFlow();
  void saveCashFlow(CashFlowModel cashFlow);
  void clearCashFlow();
  List<CashFlowModel> getCashFlowHistory();
}

class CashFlowLocalDataSourceImpl implements CashFlowLocalDataSource {
  // Simulación de almacenamiento en memoria
  CashFlowModel? _currentCashFlow;
  final List<CashFlowModel> _history = [];

  @override
  CashFlowModel? getCurrentCashFlow() {
    return _currentCashFlow;
  }

  @override
  void saveCashFlow(CashFlowModel cashFlow) {
    _currentCashFlow = cashFlow;
    
    // Si está cerrada, la guardamos en el historial
    if (cashFlow.isClosed) {
      _history.add(cashFlow);
    }
  }

  @override
  void clearCashFlow() {
    _currentCashFlow = null;
  }

  @override
  List<CashFlowModel> getCashFlowHistory() {
    return List.from(_history);
  }
}