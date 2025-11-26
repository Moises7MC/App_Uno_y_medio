// screens/order_screen.dart

import 'package:flutter/material.dart';
import 'package:uno_y_medio/models/table_model.dart';
import 'package:uno_y_medio/models/menu_item.dart';
import 'package:uno_y_medio/models/order_item.dart';
// Importamos el nuevo archivo con los datos del menú
import '../models/menu_data.dart'; 


class OrderScreen extends StatefulWidget {
  final TableModel table;

  const OrderScreen({super.key, required this.table});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  // Nueva variable de estado para la categoría seleccionada
  String _selectedCategory = menuCategories[0]; // Inicia en 'Desayuno'
  
  // Lista temporal para construir el nuevo pedido (Copia de la orden actual)
  late List<OrderItem> _currentOrder; 

  @override
  void initState() {
    super.initState();
    // Creamos una COPIA profunda para que la edición no afecte al modelo original
    _currentOrder = widget.table.currentOrder
        .map((item) => OrderItem(item: item.item, quantity: item.quantity))
        .toList();
  }

  // --- Lógica de la Pantalla (sin cambios) ---
  void _addOrUpdateItem(MenuItem menuItem) {
    setState(() {
      final existingIndex = _currentOrder.indexWhere((item) => item.item.id == menuItem.id);
      
      if (existingIndex >= 0) {
        _currentOrder[existingIndex].quantity++;
      } else {
        _currentOrder.add(OrderItem(item: menuItem));
      }
    });
  }

 // dentro de class _OrderScreenState extends State<OrderScreen>

void _saveOrder() {
  // 1. Determinar el estado final de la mesa
  final String newStatus = _currentOrder.isEmpty ? 'Libre' : 'Ocupada';
  
  // 2. Clonar la mesa y actualizar la orden
  final updatedTable = TableModel(
    id: widget.table.id,
    status: newStatus, 
    currentOrder: _currentOrder,
  );

  // 3. Devolver la mesa actualizada a la pantalla de Mesas (TableScreen)
  Navigator.of(context).pop(updatedTable);
}

  // dentro de class _OrderScreenState extends State<OrderScreen>

// Función para vaciar la mesa y liberarla (AHORA CON CONFIRMACIÓN)
void _clearTable() {
  showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Cerrar Cuenta y Liberar'),
      content: Text('¿Estás seguro de cerrar la cuenta y liberar la Mesa ${widget.table.id}? Esta acción no se puede deshacer.'),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(ctx).pop(false); // No confirmar
          },
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(ctx).pop(true); // Confirmar
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red, // Botón de confirmación en rojo
            foregroundColor: Colors.white,
          ),
          child: const Text('Confirmar'),
        ),
      ],
    ),
  ).then((confirmed) {
    // Si el diálogo devuelve 'true' (Confirmar)
    if (confirmed ?? false) { 
      // Creamos la versión de la mesa como LIBRE y sin pedido.
      final clearedTable = TableModel(
        id: widget.table.id,
        status: 'Libre', 
        currentOrder: const [], 
      );
      
      // Devolvemos la mesa liberada a TableScreen
      Navigator.of(context).pop(clearedTable);
    }
  });
}
  // Widget para mostrar los platos del menú disponibles para agregar
  Widget _buildMenuItemCard(MenuItem item) {
    // ... (el código del widget _buildMenuItemCard se mantiene igual)
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('S/. ${item.price.toStringAsFixed(2)}'),
        trailing: IconButton(
          icon: const Icon(Icons.add_circle, color: Colors.green),
          onPressed: () => _addOrUpdateItem(item),
        ),
      ),
    );
  }

  Widget _buildOrderItemList() {
    // ... (el código del widget _buildOrderItemList se mantiene igual)
    return ListView.builder(
        itemCount: _currentOrder.length,
        itemBuilder: (context, index) {
          final itemOrder = _currentOrder[index];
          // ... (resto de ListTile y Row de cantidad)
          return ListTile(
            title: Text('${itemOrder.item.name}'),
            subtitle: Text('S/. ${itemOrder.item.price.toStringAsFixed(2)} c/u'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon Button Remove
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                  onPressed: () {
                    setState(() {
                      if (itemOrder.quantity > 1) {
                        itemOrder.quantity--;
                      } else {
                        _currentOrder.removeAt(index);
                      }
                    });
                  },
                ),
                // Text Quantity
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    '${itemOrder.quantity}x',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                // Icon Button Add
                IconButton(
                  icon: const Icon(Icons.add_circle_outline, color: Colors.blue),
                  onPressed: () {
                    setState(() {
                      itemOrder.quantity++;
                    });
                  },
                ),
              ],
            ),
          );
        },
    );
  }

  @override
  Widget build(BuildContext context) {
    final total = _currentOrder.fold(0.0, (sum, item) => sum + (item.item.price * item.quantity));
    
    // Filtramos los ítems del menú según la categoría seleccionada
    final filteredMenu = fullMenu
        .where((item) => item.category == _selectedCategory)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Pedido Mesa ${widget.table.id}'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        // NUEVO: Añadimos un botón de acción
    actions: [
      if (widget.table.currentOrder.isNotEmpty) // Solo mostrar si la mesa está ocupada
        IconButton(
          icon: const Icon(Icons.check_circle_outline, color: Colors.greenAccent),
          tooltip: 'Cerrar Cuenta y Liberar',
          onPressed: _clearTable, // Llamamos a la función
        ),
    ],
      ),
      body: Column(
        children: [
          // --- NUEVO: Selector de Categorías (Dropdown) ---
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            color: Colors.grey.shade100,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Selecciona Categoría:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                DropdownButton<String>(
                  value: _selectedCategory,
                  icon: const Icon(Icons.arrow_downward),
                  elevation: 16,
                  style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 16, fontWeight: FontWeight.w500),
                  underline: Container(
                    height: 2,
                    color: Theme.of(context).primaryColor,
                  ),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedCategory = newValue!; // Actualiza la categoría
                    });
                  },
                  items: menuCategories.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          
          // 1. Menú de platos (Arriba) - AHORA USA EL MENÚ FILTRADO
          Container(
            padding: const EdgeInsets.all(16.0),
            color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Menú de $_selectedCategory', // Muestra la categoría actual
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                const SizedBox(height: 10),
                // Muestra los platos FILTRADOS
                ...filteredMenu.map((item) => _buildMenuItemCard(item)).toList(),
              ],
            ),
          ),
          
          // 2. Separador y Pedido Actual (Medio)
          const Divider(height: 1, thickness: 1),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'Orden Actual',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: _currentOrder.isEmpty
                ? const Center(child: Text('Aún no hay platos. Agrega algo del menú.'))
                : _buildOrderItemList(),
          ),

          // 3. Total y Botón de Guardar (Abajo)
          // ... (Esta parte se mantiene igual)
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 2,
                  blurRadius: 5,
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total a la Fecha:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                    Text('S/. ${total.toStringAsFixed(2)}', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor)),
                  ],
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _currentOrder.isEmpty ? null : _saveOrder,
                    icon: const Icon(Icons.send),
                    label: const Text('GUARDAR Y ENVIAR PEDIDO'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}