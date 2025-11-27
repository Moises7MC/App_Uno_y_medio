import 'package:flutter/foundation.dart';
import '../../domain/entities/cash_flow.dart';
import '../../domain/repositories/cash_flow_repository.dart';

class CashFlowProvider extends ChangeNotifier {
  final CashFlowRepository repository;

  CashFlowEntity? _currentCashFlow;

  CashFlowProvider({required this.repository}) {
    _loadCurrentCashFlow();
  }

  // Getters
  CashFlowEntity? get currentCashFlow => _currentCashFlow;
  
  bool get isCashFlowOpen => _currentCashFlow != null && !_currentCashFlow!.isClosed;
  
  double get currentTotal {
    if (_currentCashFlow == null) return 0.0;
    return _currentCashFlow!.initialBalance + _currentCashFlow!.totalSales;
  }

  // Methods
  void _loadCurrentCashFlow() {
    _currentCashFlow = repository.getCurrentCashFlow();
    notifyListeners();
  }

  void openCashFlow(double initialBalance) {
    repository.openCashFlow(initialBalance);
    _loadCurrentCashFlow();
  }

  void updateSales(double amount) {
    repository.updateSales(amount);
    _loadCurrentCashFlow();
  }

  void closeCashFlow() {
    repository.closeCashFlow();
    _currentCashFlow = null;
    notifyListeners();
  }

  List<CashFlowEntity> getCashFlowHistory() {
    return repository.getCashFlowHistory();
  }
}