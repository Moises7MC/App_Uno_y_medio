// Estructura de un ítem dentro de un pedido (ej: 2 Arroces con Pato)
import 'package:uno_y_medio/models/menu_item.dart';

class OrderItem {
  final MenuItem item;
  int quantity;

  OrderItem({required this.item, this.quantity = 1});
}