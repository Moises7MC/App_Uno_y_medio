import '../entities/order_item.dart';

abstract class OrderRepository {
  List<OrderItemEntity> getOrdersForTable(int tableId);
  void saveOrdersForTable(int tableId, List<OrderItemEntity> orders);
  void clearOrdersForTable(int tableId);
  double calculateTotal(List<OrderItemEntity> orders);
}