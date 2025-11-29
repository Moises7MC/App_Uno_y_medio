import 'dart:async'; // Necesario para usar Timer
import 'package:flutter/foundation.dart';
import '../../domain/entities/menu_item.dart';
import '../../domain/repositories/menu_repository.dart';

class MenuProvider extends ChangeNotifier {
  final MenuRepository repository;
  
  List<MenuItem> _fullMenu = [];
  List<String> _categories = [];
  String _selectedCategory = '';
  bool _isLoading = true; 
  
  Timer? _pollingTimer; // <-- 1. AÑADIR EL TEMPORIZADOR

  MenuProvider({required this.repository}) {
    loadMenu();
    startPolling(); // <-- 2. INICIAR EL SONDEO
  }
  
  // Getters
  List<MenuItem> get fullMenu => _fullMenu;
  List<String> get categories => _categories;
  String get selectedCategory => _selectedCategory;
  bool get isLoading => _isLoading; 
  
  List<MenuItem> get filteredMenu {
    if (_selectedCategory.isEmpty) return _fullMenu;
    return _fullMenu.where((item) => item.category == _selectedCategory).toList();
  }
  
  // *** LÓGICA DEL SONDEO (POLLING) ***
  void startPolling() {
    // Cancela el temporizador anterior si existe
    if (_pollingTimer != null) {
      _pollingTimer!.cancel();
    }
    
    // Configuramos un temporizador que se dispara cada 10 segundos
    _pollingTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      print('Polling Menu: Recargando categorías y menú desde la API...');
      loadMenu(isPolling: true); 
    });
  }

  // 3. Método Dispose para liberar el temporizador al cerrar la pantalla
  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }
  
  // Methods
  Future<void> loadMenu({bool isPolling = false}) async {
    // Solo mostramos el indicador de carga si no es una actualización periódica
    if (!isPolling) {
      _isLoading = true;
      notifyListeners();
    }
    
    try {
      final fetchedCategories = await repository.getCategories();
      final fetchedMenu = await repository.getFullMenu(); 

      // 4. Optimizamos: Solo notificamos si la lista de categorías cambió
      if (!listEquals(_categories, fetchedCategories) || !listEquals(_fullMenu, fetchedMenu)) {
          
          // Guardar la categoría seleccionada antes de actualizar la lista
          final oldSelectedCategory = _selectedCategory;

          _categories = fetchedCategories;
          _fullMenu = fetchedMenu;

          // Si la categoría anterior sigue existiendo, la mantenemos.
          // Si no, seleccionamos la primera de la nueva lista.
          if (_categories.contains(oldSelectedCategory)) {
            _selectedCategory = oldSelectedCategory;
          } else if (_categories.isNotEmpty) {
            _selectedCategory = _categories[0];
          } else {
            _selectedCategory = '';
          }

          notifyListeners();
      }
      
    } catch (e) {
      print('Error loading menu or categories: $e');
      if (!isPolling) {
        _categories = ['Error'];
        _selectedCategory = 'Error';
      }
    } finally {
      if (_isLoading) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }
  
  void selectCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }
}