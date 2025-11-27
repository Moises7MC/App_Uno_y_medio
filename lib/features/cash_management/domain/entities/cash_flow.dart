class CashFlowEntity {
  final String id;
  final double initialBalance;
  final double finalBalance;
  final DateTime openingTime;
  final DateTime? closingTime;
  final double totalSales;

  CashFlowEntity({
    required this.id,
    required this.initialBalance,
    required this.openingTime,
    this.finalBalance = 0.0,
    this.closingTime,
    this.totalSales = 0.0,
  });

  bool get isClosed => closingTime != null;
  
  double get calculatedFinalBalance => initialBalance + totalSales;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CashFlowEntity && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}