
// Estructura principal de una mesa. Contiene su estado y la lista de pedidos.
import 'package:uno_y_medio/models/order_item.dart';

class TableModel {
  final int id;
  // Estado: 'Libre', 'Ocupada', 'Pagando' (por ahora usaremos solo Ocupada/Libre)
  String status; 
  List<OrderItem> currentOrder;

  TableModel({
    required this.id,
    this.status = 'Libre',
    this.currentOrder = const [],
  });
}