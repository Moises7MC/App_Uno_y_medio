import '../../domain/entities/order_item.dart';
import '../../domain/repositories/order_repository.dart';
import '../datasources/order_local_datasource.dart';
import '../models/order_item_model.dart';

class OrderRepositoryImpl implements OrderRepository {
  final OrderLocalDataSource dataSource;

  OrderRepositoryImpl({required this.dataSource});

  @override
  List<OrderItemEntity> getOrdersForTable(int tableId) {
    return dataSource.getOrdersForTable(tableId);
  }

  @override
  void saveOrdersForTable(int tableId, List<OrderItemEntity> orders) {
    final models = orders
        .map((entity) => OrderItemModel.fromEntity(entity))
        .toList();
    dataSource.saveOrdersForTable(tableId, models);
  }

  @override
  void clearOrdersForTable(int tableId) {
    dataSource.clearOrdersForTable(tableId);
  }

  @override
  double calculateTotal(List<OrderItemEntity> orders) {
    return orders.fold(0.0, (sum, item) => sum + item.subtotal);
  }
}