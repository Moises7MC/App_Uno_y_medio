import '../models/order_item_model.dart';

abstract class OrderLocalDataSource {
  List<OrderItemModel> getOrdersForTable(int tableId);
  void saveOrdersForTable(int tableId, List<OrderItemModel> orders);
  void clearOrdersForTable(int tableId);
}

class OrderLocalDataSourceImpl implements OrderLocalDataSource {
  // Simulación de almacenamiento en memoria
  // En una app real, esto podría ser SQLite o Shared Preferences
  final Map<int, List<OrderItemModel>> _ordersStorage = {};

  @override
  List<OrderItemModel> getOrdersForTable(int tableId) {
    return List.from(_ordersStorage[tableId] ?? []);
  }

  @override
  void saveOrdersForTable(int tableId, List<OrderItemModel> orders) {
    _ordersStorage[tableId] = List.from(orders);
  }

  @override
  void clearOrdersForTable(int tableId) {
    _ordersStorage.remove(tableId);
  }
}