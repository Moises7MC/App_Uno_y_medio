import '../models/menu_item_model.dart';

abstract class MenuLocalDataSource {
  List<MenuItemModel> getFullMenu();
  List<String> getCategories();
  List<MenuItemModel> getMenuByCategory(String category);
}

class MenuLocalDataSourceImpl implements MenuLocalDataSource {
  // Data hardcodeada (en el futuro puede venir de SQLite o Firebase)
  static final List<MenuItemModel> _menuItems = [
    MenuItemModel(id: 'LP001', name: 'Arroz con Pato', price: 25.0, category: 'Almuerzo'),
    MenuItemModel(id: 'LP002', name: 'Arroz con Cabrito', price: 30.0, category: 'Almuerzo'),
    MenuItemModel(id: 'LP003', name: 'Ceviche Mixto', price: 35.0, category: 'Almuerzo'),
    MenuItemModel(id: 'DP001', name: 'Jugo de Papaya', price: 8.0, category: 'Desayuno'),
    MenuItemModel(id: 'DP002', name: 'Pan con Pollo', price: 12.0, category: 'Desayuno'),
    MenuItemModel(id: 'CP001', name: 'Sopa a la Minuta', price: 15.0, category: 'Cena'),
    MenuItemModel(id: 'CP002', name: 'Ensalada Cesar', price: 22.0, category: 'Cena'),
  ];
  
  static final List<String> _categories = [
    'Desayuno',
    'Almuerzo',
    'Cena',
  ];
  
  @override
  List<String> getCategories() {
    return List.from(_categories);
  }
  
  @override
  List<MenuItemModel> getFullMenu() {
    return List.from(_menuItems);
  }
  
  @override
  List<MenuItemModel> getMenuByCategory(String category) {
    return _menuItems.where((item) => item.category == category).toList();
  }
}