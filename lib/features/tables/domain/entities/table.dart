import '../../../orders/domain/entities/order_item.dart';

class TableEntity {
  final int id;
  final String status;
  final List<OrderItemEntity> currentOrder;

  TableEntity({
    required this.id,
    required this.status,
    required this.currentOrder,
  });

  bool get isOccupied => currentOrder.isNotEmpty;

  double get totalAmount {
    return currentOrder.fold(
      0.0,
      (sum, item) => sum + (item.item.price * item.quantity),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TableEntity && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}