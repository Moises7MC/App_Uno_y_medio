import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uno_y_medio/features/tables/data/models/table_model.dart';
import 'package:uno_y_medio/features/menu/presentation/providers/menu_provider.dart';
import 'package:uno_y_medio/features/orders/presentation/providers/order_provider.dart';
import 'package:uno_y_medio/features/orders/domain/entities/order_item.dart';

import 'package:uno_y_medio/features/menu/presentation/widgets/menu_item_card.dart';
import 'package:uno_y_medio/features/orders/presentation/widgets/order_item_list.dart';
import 'package:uno_y_medio/features/orders/presentation/widgets/order_summary.dart';

class OrderScreen extends StatefulWidget {
  final TableModel table;

  const OrderScreen({super.key, required this.table});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  @override
  void initState() {
    super.initState();
    // Cargar el pedido actual de la mesa en el OrderProvider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final orderProvider = Provider.of<OrderProvider>(context, listen: false);

      // Convertir los OrderItem viejos a OrderItemEntity nuevos
      final existingOrder = widget.table.currentOrder.map((oldItem) {
        return OrderItemEntity(
          item: oldItem.item,
          quantity: oldItem.quantity,
        );
      }).toList();

      orderProvider.loadOrderForTable(widget.table.id, existingOrder);
    });
  }

 void _saveOrder() {
  final orderProvider = Provider.of<OrderProvider>(context, listen: false);
  final currentOrder = orderProvider.currentOrder;

  // Determinar el estado final de la mesa
  final String newStatus = currentOrder.isEmpty ? 'Libre' : 'Ocupada';

  // Ya no necesitamos conversión, currentOrder ya es List<OrderItemEntity>
  final updatedTable = TableModel(
    id: widget.table.id,
    status: newStatus,
    currentOrder: currentOrder, // ✅ Directo, sin conversión
  );

  Navigator.of(context).pop(updatedTable);
}

  void _clearTable() {
    showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cerrar Cuenta y Liberar'),
        content: Text(
          '¿Estás seguro de cerrar la cuenta y liberar la Mesa ${widget.table.id}? Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop(false);
            },
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop(true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    ).then((confirmed) {
      if (confirmed ?? false) {
        final clearedTable = TableModel(
          id: widget.table.id,
          status: 'Libre',
          currentOrder: const [],
        );
        Navigator.of(context).pop(clearedTable);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final menuProvider = Provider.of<MenuProvider>(context);
    final orderProvider = Provider.of<OrderProvider>(context);

    final filteredMenu = menuProvider.filteredMenu;
    final categories = menuProvider.categories;
    final selectedCategory = menuProvider.selectedCategory;

    final currentOrder = orderProvider.currentOrder;
    final total = orderProvider.total;

    return Scaffold(
      appBar: AppBar(
        title: Text('Pedido Mesa ${widget.table.id}'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          if (widget.table.currentOrder.isNotEmpty)
            IconButton(
              icon: const Icon(
                Icons.check_circle_outline,
                color: Colors.greenAccent,
              ),
              tooltip: 'Cerrar Cuenta y Liberar',
              onPressed: _clearTable,
            ),
        ],
      ),
      body: Column(
        children: [
          // 1. Selector de Categorías
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            color: Colors.grey.shade100,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Selecciona Categoría:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                DropdownButton<String>(
                  value: selectedCategory,
                  icon: const Icon(Icons.arrow_downward),
                  elevation: 16,
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  underline: Container(
                    height: 2,
                    color: Theme.of(context).primaryColor,
                  ),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      menuProvider.selectCategory(newValue);
                    }
                  },
                  items: categories.map<DropdownMenuItem<String>>((value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),

          // 2. Menú de platos (ESTO FALTABA)
          Container(
            padding: const EdgeInsets.all(16.0),
            color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Menú de $selectedCategory',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 10),
                // Muestra los platos FILTRADOS usando MenuItemCard
                ...filteredMenu.map((item) {
                  return MenuItemCard(
                    item: item,
                    onAdd: () => orderProvider.addOrUpdateItem(item),
                  );
                }).toList(),
              ],
            ),
          ),

          // 3. Separador
          const Divider(height: 1, thickness: 1),
          
          // 4. Título de Orden Actual
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'Orden Actual',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),

          // 5. Lista de pedidos
          Expanded(
            child: OrderItemList(
              items: currentOrder,
              isEditable: true,
              onDecrement: (index) => orderProvider.decrementItem(index),
              onIncrement: (index) => orderProvider.incrementItem(index),
            ),
          ),

          // 6. Total y botón guardar (usando OrderSummary)
          OrderSummary(
            items: currentOrder,
            total: total,
            onSave: _saveOrder,
            saveButtonText: 'GUARDAR Y ENVIAR PEDIDO',
            showSaveButton: true,
          ),
        ],
      ),
    );
  }
}