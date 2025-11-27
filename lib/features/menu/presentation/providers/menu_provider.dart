import 'package:flutter/foundation.dart';
import '../../domain/entities/menu_item.dart';
import '../../domain/repositories/menu_repository.dart';

class MenuProvider extends ChangeNotifier {
  final MenuRepository repository;
  
  List<MenuItem> _fullMenu = [];
  List<String> _categories = [];
  String _selectedCategory = '';
  
  MenuProvider({required this.repository}) {
    loadMenu();
  }
  
  // Getters
  List<MenuItem> get fullMenu => _fullMenu;
  List<String> get categories => _categories;
  String get selectedCategory => _selectedCategory;
  
  List<MenuItem> get filteredMenu {
    if (_selectedCategory.isEmpty) return _fullMenu;
    return repository.getMenuByCategory(_selectedCategory);
  }
  
  // Methods
  void loadMenu() {
    _fullMenu = repository.getFullMenu();
    _categories = repository.getCategories();
    if (_categories.isNotEmpty) {
      _selectedCategory = _categories[0];
    }
    notifyListeners();
  }
  
  void selectCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }
}