// lib/models/cash_flow_model.dart
class CashFlowModel {
  final String id; // ID de la sesión de caja (ej: fecha y hora)
  final double initialBalance; // Saldo inicial al abrir caja
  double finalBalance; // Saldo final al cerrar caja (se calcula)
  final DateTime openingTime; // Hora de apertura
  DateTime? closingTime; // Hora de cierre (opcional, será null si está abierta)
  double totalSales; // Suma de todos los pedidos pagados
  
  // Lista de todas las transacciones (futuro: para registrar pagos)
  // List<TransactionModel> transactions; 
  
  CashFlowModel({
    required this.id,
    required this.initialBalance,
    required this.openingTime,
    this.finalBalance = 0.0,
    this.closingTime,
    this.totalSales = 0.0,
  });
  
  // Método de utilidad para verificar el estado
  bool get isClosed => closingTime != null;
}