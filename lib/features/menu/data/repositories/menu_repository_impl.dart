import '../../domain/entities/menu_item.dart';
import '../../domain/repositories/menu_repository.dart';
import '../datasources/menu_local_datasource.dart';

class MenuRepositoryImpl implements MenuRepository {
  final MenuLocalDataSource dataSource;
  
  MenuRepositoryImpl({required this.dataSource});
  
  @override
  List<String> getCategories() {
    return dataSource.getCategories();
  }
  
  @override
  List<MenuItem> getFullMenu() {
    // Convierte los Models a Entities
    return dataSource.getFullMenu();
  }
  
  @override
  List<MenuItem> getMenuByCategory(String category) {
    return dataSource.getMenuByCategory(category);
  }
}