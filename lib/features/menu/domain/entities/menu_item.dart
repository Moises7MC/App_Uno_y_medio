class MenuItem {
  final String id;
  final String name;
  final double price;
  final String category;
  
  MenuItem({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
  });
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MenuItem && other.id == id;
  }
  
  @override
  int get hashCode => id.hashCode;
}