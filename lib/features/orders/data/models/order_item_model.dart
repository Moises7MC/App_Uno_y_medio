import 'package:uno_y_medio/features/menu/data/models/menu_item_model.dart';
import 'package:uno_y_medio/features/menu/domain/entities/menu_item.dart';
import '../../domain/entities/order_item.dart';

class OrderItemModel extends OrderItemEntity {
  OrderItemModel({
    required super.item,
    required super.quantity,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      item: MenuItemModel.fromJson(json['item']),
      quantity: json['quantity'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'item': MenuItemModel.fromEntity(item).toJson(),
      'quantity': quantity,
    };
  }

  factory OrderItemModel.fromEntity(OrderItemEntity entity) {
    return OrderItemModel(
      item: entity.item,
      quantity: entity.quantity,
    );
  }

  OrderItemModel copyWith({
    MenuItem? item,
    int? quantity,
  }) {
    return OrderItemModel(
      item: item ?? this.item,
      quantity: quantity ?? this.quantity,
    );
  }
}