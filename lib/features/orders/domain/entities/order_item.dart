import '../../../menu/domain/entities/menu_item.dart';

class OrderItemEntity {
  final MenuItem item;
  final int quantity;

  OrderItemEntity({
    required this.item,
    required this.quantity,
  });

  double get subtotal => item.price * quantity;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OrderItemEntity && 
           other.item.id == item.id && 
           other.quantity == quantity;
  }

  @override
  int get hashCode => item.id.hashCode ^ quantity.hashCode;
}