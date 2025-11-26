// models/menu_item.dart

class MenuItem {
  final String id;
  final String name;
  final double price; // Precio para futuros cálculos
  final String category; // <-- **CAMBIO: Añadimos la categoría**

  const MenuItem({
    required this.id,
    required this.name,
    required this.price,
    required this.category, // <-- Nuevo campo requerido
  });
}