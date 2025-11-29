import 'package:uno_y_medio/features/menu/data/datasources/menu_api_datasource.dart'; // <-- Usar el nuevo API DataSource
import '../../domain/entities/menu_item.dart';
import '../../domain/repositories/menu_repository.dart';
// import '../datasources/menu_local_datasource.dart'; // <-- Ya no se usa

class MenuRepositoryImpl implements MenuRepository {
  // Ahora usamos la interfaz MenuDataSource, implementada por MenuApiDataSourceImpl
  final MenuDataSource dataSource; 
  
  MenuRepositoryImpl({required this.dataSource});
  
  @override
  Future<List<String>> getCategories() { // <-- Método asíncrono
    return dataSource.getCategories();
  }
  
  @override
  Future<List<MenuItem>> getFullMenu() { // <-- Método asíncrono
    // Convierte los Models a Entities
    return dataSource.getFullMenu();
  }
  
  @override
  Future<List<MenuItem>> getMenuByCategory(String category) { // <-- Método asíncrono
    return dataSource.getMenuByCategory(category);
  }
}