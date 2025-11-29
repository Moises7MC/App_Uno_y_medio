import '../../../menu/domain/entities/menu_item.dart';

class OrderItemEntity {
  final MenuItem item;
  final int quantity;

  OrderItemEntity({
    required this.item,
    required this.quantity,
  });

  double get subtotal => item.price * quantity;

  // NUEVO: Método para convertir el ítem a un formato JSON simple para el backend
  Map<String, dynamic> toJson() {
    // Es CRÍTICO que el ID del ítem (String en Flutter) se convierta a un entero, 
    // ya que Spring Boot espera Integer para la clave foránea 'PlatoId'.
    final int? platoId = int.tryParse(item.id);
    
    // Devolvemos el formato JSON esperado por la entidad DetallePedido de Spring Boot.
    return {
      'platoId': platoId, 
      'cantidad': quantity,
      'precioUnitario': item.price,
    };
  }

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