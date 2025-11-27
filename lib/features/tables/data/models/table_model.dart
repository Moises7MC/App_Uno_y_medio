import 'package:uno_y_medio/features/orders/domain/entities/order_item.dart';
import '../../domain/entities/table.dart';

class TableModel extends TableEntity {
  TableModel({
    required super.id,
    super.status = 'Libre',
    super.currentOrder = const [],
  });

  factory TableModel.fromJson(Map<String, dynamic> json) {
    return TableModel(
      id: json['id'],
      status: json['status'],
      currentOrder: (json['currentOrder'] as List?)
              ?.map((item) => OrderItemEntity(
                    item: item['item'],
                    quantity: item['quantity'],
                  ))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status': status,
      'currentOrder': currentOrder
          .map((item) => {
                'item': item.item,
                'quantity': item.quantity,
              })
          .toList(),
    };
  }

  TableModel copyWith({
    int? id,
    String? status,
    List<OrderItemEntity>? currentOrder,
  }) {
    return TableModel(
      id: id ?? this.id,
      status: status ?? this.status,
      currentOrder: currentOrder ?? this.currentOrder,
    );
  }

  factory TableModel.fromEntity(TableEntity entity) {
    return TableModel(
      id: entity.id,
      status: entity.status,
      currentOrder: entity.currentOrder,
    );
  }
}