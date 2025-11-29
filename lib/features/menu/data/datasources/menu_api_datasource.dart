import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../../data/models/menu_item_model.dart';
import '../../domain/entities/menu_item.dart';

// --- Modelos para la API de Categorías ---
class CategoryApiResponse {
  final int id;
  final String category; 
  
  CategoryApiResponse({required this.id, required this.category});

  factory CategoryApiResponse.fromJson(Map<String, dynamic> json) {
    return CategoryApiResponse(
      id: json['id'] as int,
      category: json['categoria'] as String,
    );
  }
}

// --- Definición de la Interfaz ---
abstract class MenuDataSource {
  Future<List<MenuItemModel>> getFullMenu();
  Future<List<String>> getCategories();
  Future<List<MenuItemModel>> getMenuByCategory(String category);
}


// --- Implementación del API DataSource ---
class MenuApiDataSourceImpl implements MenuDataSource {
  // Configuración de la URL base
  final String baseUrl = 'http://localhost:8080/api';
  
  // Mapa para almacenar el ID y Nombre de Categoría (necesario para el mapeo de Platos)
  // Lo inicializamos con datos vacíos, se llena en getCategories()
  final Map<int, String> _categoryMap = {}; 


  @override
  Future<List<String>> getCategories() async {
    final response = await http.get(Uri.parse('$baseUrl/categorias'));

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(utf8.decode(response.bodyBytes));
      
      // 1. Limpiar y llenar el mapa de IDs a nombres de categoría
      _categoryMap.clear();
      final List<String> categoryNames = [];
      for (var json in jsonList) {
        final cat = CategoryApiResponse.fromJson(json);
        _categoryMap[cat.id] = cat.category;
        categoryNames.add(cat.category);
      }
      
      return categoryNames;

    } else {
      throw Exception('Failed to load categories from API: ${response.statusCode}');
    }
  }

  @override
  Future<List<MenuItemModel>> getFullMenu() async {
    // *** AHORA SÍ: LLAMAMOS A LA API DE PLATOS ***
    final response = await http.get(Uri.parse('$baseUrl/menu'));
    
    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(utf8.decode(response.bodyBytes));
      
      return jsonList.map((jsonItem) {
        // Mapeamos el JSON del plato a nuestro MenuItemModel
        final price = (jsonItem['precio'] as num).toDouble();
        final categoryId = jsonItem['categoriaId'] as int; 
        
        // Usamos el mapa cargado en getCategories() para obtener el nombre de la categoría
        String categoryName = _categoryMap[categoryId] ?? 'Desconocido';

        return MenuItemModel(
          // Es vital usar .toString() si el id de la Entidad Dart es String
          id: jsonItem['id'].toString(), 
          name: jsonItem['nombre'] as String, 
          price: price, 
          category: categoryName,
        );
      }).toList();

    } else {
      throw Exception('Failed to load full menu from API: ${response.statusCode}');
    }
  }
  
  @override
  Future<List<MenuItemModel>> getMenuByCategory(String category) async {
    // Este método ya no necesita lógica, porque el Provider lo está gestionando.
    return Future.value([]); 
  }
}