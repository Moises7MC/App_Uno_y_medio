import '../../domain/entities/menu_item.dart';

class MenuItemModel extends MenuItem {
  MenuItemModel({
    required super.id,
    required super.name,
    required super.price,
    required super.category,
  });
  
  factory MenuItemModel.fromJson(Map<String, dynamic> json) {
    return MenuItemModel(
      id: json['id'],
      name: json['name'],
      price: (json['price'] as num).toDouble(),
      category: json['category'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'category': category,
    };
  }
  
  // Método para convertir Entity a Model
  factory MenuItemModel.fromEntity(MenuItem entity) {
    return MenuItemModel(
      id: entity.id,
      name: entity.name,
      price: entity.price,
      category: entity.category,
    );
  }
}