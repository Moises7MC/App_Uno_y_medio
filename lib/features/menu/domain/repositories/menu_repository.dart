import '../entities/menu_item.dart';

abstract class MenuRepository {
  List<MenuItem> getFullMenu();
  List<String> getCategories();
  List<MenuItem> getMenuByCategory(String category);
}