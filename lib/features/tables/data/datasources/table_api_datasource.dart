import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:uno_y_medio/features/tables/domain/repositories/table_repository.dart';
import '../../domain/entities/table.dart';
import '../models/table_model.dart';

// Definimos una entidad simple para la respuesta de la API (solo ID y NombreMesa)
class MesaApiResponse {
  final int id;
  final String nombreMesa;

  MesaApiResponse({required this.id, required this.nombreMesa});

  factory MesaApiResponse.fromJson(Map<String, dynamic> json) {
    return MesaApiResponse(
      id: json['id'] as int,
      nombreMesa: json['nombreMesa'] as String,
    );
  }
}

// Interfaz abstracta para el origen de datos de Mesas (puede ser local o API)
abstract class TableDataSource {
  // CAMBIO CLAVE: Hacemos la interfaz del DataSource asíncrona también.
  Future<List<TableEntity>> getTables();
}

// Implementación usando la API de Spring Boot
class TableApiDataSourceImpl implements TableDataSource {
  // Asegúrate de que esta URL coincida con la IP de tu PC si usas un emulador o dispositivo físico
  // Si usas un emulador, usa la IP local como 'http://10.0.2.2:8080' o la IP de tu PC.
  // Si usas tu PC local, usa 'http://localhost:8080'
  final String apiUrl = 'http://localhost:8080/api/mesas'; 

  @override
  Future<List<TableEntity>> getTables() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        // La API devuelve una lista de Mesas.
        final List<dynamic> jsonList = json.decode(response.body);
        
        // Mapeamos los datos de la API a TableEntity.
        return jsonList.map((jsonItem) {
          final mesa = MesaApiResponse.fromJson(jsonItem);
          return TableEntity(
            id: mesa.id,
            // Inicializar el estado y la orden para que el resto de la app funcione
            status: 'Libre', 
            currentOrder: const [],
          );
        }).toList();
      } else {
        // Si la respuesta no fue 200, lanza un error
        throw Exception('Fallo al cargar las mesas desde la API. Status: ${response.statusCode}');
      }
    } catch (e) {
      // Manejo de errores de conexión o parsing
      print('Error al obtener mesas: $e');
      // Puedes devolver una lista vacía o relanzar el error.
      throw Exception('Error de conexión o inesperado: $e');
    }
  }
}