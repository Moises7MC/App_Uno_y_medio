// models/menu_data.dart
import 'package:uno_y_medio/models/menu_item.dart';

// Definición de las categorías (para hacerlas seleccionables en la UI)
const List<String> menuCategories = [
  'Desayuno',
  'Almuerzo',
  'Cena',
];

// Lista de todos los platos del menú con su categoría definida
const List<MenuItem> fullMenu = [
  // --- Platos de ALMUERZO (existentes) ---
  MenuItem(id: 'LP001', name: 'Arroz con Pato', price: 25.0, category: 'Almuerzo'),
  MenuItem(id: 'LP002', name: 'Arroz con Cabrito', price: 30.0, category: 'Almuerzo'),
  MenuItem(id: 'LP003', name: 'Ceviche Mixto', price: 35.0, category: 'Almuerzo'),

  // --- Platos de DESAYUNO (añadidos temporalmente) ---
  MenuItem(id: 'DP001', name: 'Jugo de Papaya', price: 8.0, category: 'Desayuno'),
  MenuItem(id: 'DP002', name: 'Pan con Pollo', price: 12.0, category: 'Desayuno'),
  
  // --- Platos de CENA (añadidos temporalmente) ---
  MenuItem(id: 'CP001', name: 'Sopa a la Minuta', price: 15.0, category: 'Cena'),
  MenuItem(id: 'CP002', name: 'Ensalada Cesar', price: 22.0, category: 'Cena'),
];