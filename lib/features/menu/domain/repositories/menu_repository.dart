import '../entities/menu_item.dart';

abstract class MenuRepository {
  Future<List<MenuItem>> getFullMenu(); // <-- AHORA ES ASÍNCRONO
  Future<List<String>> getCategories(); // <-- AHORA ES ASÍNCRONO
  Future<List<MenuItem>> getMenuByCategory(String category); // <-- AHORA ES ASÍNCRONO
}