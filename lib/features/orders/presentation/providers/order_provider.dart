import 'package:flutter/foundation.dart';
import '../../domain/entities/order_item.dart';
import '../../domain/repositories/order_repository.dart';
import '../../../menu/domain/entities/menu_item.dart';

class OrderProvider extends ChangeNotifier {
  final OrderRepository repository;

  List<OrderItemEntity> _currentOrder = [];
  int? _currentTableId;

  OrderProvider({required this.repository});

  // Getters
  List<OrderItemEntity> get currentOrder => _currentOrder;
  int? get currentTableId => _currentTableId;
  
  double get total => repository.calculateTotal(_currentOrder);
  
  bool get hasItems => _currentOrder.isNotEmpty;

  // Methods
  void loadOrderForTable(int tableId, List<OrderItemEntity> existingOrder) {
    _currentTableId = tableId;
    _currentOrder = List.from(existingOrder);
    notifyListeners();
  }

  void addOrUpdateItem(MenuItem menuItem) {
    final existingIndex = _currentOrder.indexWhere(
      (item) => item.item.id == menuItem.id,
    );

    if (existingIndex >= 0) {
      // Incrementar cantidad
      final existing = _currentOrder[existingIndex];
      _currentOrder[existingIndex] = OrderItemEntity(
        item: existing.item,
        quantity: existing.quantity + 1,
      );
    } else {
      // Añadir nuevo item
      _currentOrder.add(OrderItemEntity(item: menuItem, quantity: 1));
    }
    notifyListeners();
  }

  void removeItem(int index) {
    if (index >= 0 && index < _currentOrder.length) {
      _currentOrder.removeAt(index);
      notifyListeners();
    }
  }

  void decrementItem(int index) {
    if (index >= 0 && index < _currentOrder.length) {
      final item = _currentOrder[index];
      if (item.quantity > 1) {
        _currentOrder[index] = OrderItemEntity(
          item: item.item,
          quantity: item.quantity - 1,
        );
      } else {
        _currentOrder.removeAt(index);
      }
      notifyListeners();
    }
  }

  void incrementItem(int index) {
    if (index >= 0 && index < _currentOrder.length) {
      final item = _currentOrder[index];
      _currentOrder[index] = OrderItemEntity(
        item: item.item,
        quantity: item.quantity + 1,
      );
      notifyListeners();
    }
  }

  void clearOrder() {
    _currentOrder.clear();
    _currentTableId = null;
    notifyListeners();
  }

  List<OrderItemEntity> saveAndGetOrder() {
    if (_currentTableId != null) {
      repository.saveOrdersForTable(_currentTableId!, _currentOrder);
    }
    return List.from(_currentOrder);
  }
}