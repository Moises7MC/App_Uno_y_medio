import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/order_item.dart';
import '../providers/order_provider.dart';

class OrderItemList extends StatelessWidget {
  final List<OrderItemEntity> items;
  final bool isEditable;
  final Function(int)? onRemove;
  final Function(int)? onIncrement;
  final Function(int)? onDecrement;

  const OrderItemList({
    super.key,
    required this.items,
    this.isEditable = true,
    this.onRemove,
    this.onIncrement,
    this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_cart_outlined,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'Aún no hay platos',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Agrega algo del menú',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return _OrderItemTile(
          item: item,
          index: index,
          isEditable: isEditable,
          onRemove: onRemove,
          onIncrement: onIncrement,
          onDecrement: onDecrement,
        );
      },
    );
  }
}

class _OrderItemTile extends StatelessWidget {
  final OrderItemEntity item;
  final int index;
  final bool isEditable;
  final Function(int)? onRemove;
  final Function(int)? onIncrement;
  final Function(int)? onDecrement;

  const _OrderItemTile({
    required this.item,
    required this.index,
    required this.isEditable,
    this.onRemove,
    this.onIncrement,
    this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      elevation: 2,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        title: Text(
          item.item.name,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              'S/. ${item.item.price.toStringAsFixed(2)} c/u',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Subtotal: S/. ${item.subtotal.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ],
        ),
        trailing: isEditable
            ? _buildEditControls(context)
            : _buildReadOnlyQuantity(),
      ),
    );
  }

  Widget _buildEditControls(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Botón remover
        IconButton(
          icon: Icon(
            item.quantity > 1
                ? Icons.remove_circle_outline
                : Icons.delete_outline,
            color: Colors.red,
            size: 28,
          ),
          onPressed: () {
            if (onDecrement != null) {
              onDecrement!(index);
            }
          },
          tooltip: item.quantity > 1 ? 'Disminuir cantidad' : 'Eliminar',
        ),
        
        // Cantidad
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '${item.quantity}x',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        
        // Botón agregar
        IconButton(
          icon: const Icon(
            Icons.add_circle_outline,
            color: Colors.blue,
            size: 28,
          ),
          onPressed: () {
            if (onIncrement != null) {
              onIncrement!(index);
            }
          },
          tooltip: 'Aumentar cantidad',
        ),
      ],
    );
  }

  Widget _buildReadOnlyQuantity() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '${item.quantity}x',
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

// Widget para usar con Provider (versión simplificada)
class OrderItemListWithProvider extends StatelessWidget {
  const OrderItemListWithProvider({super.key});

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);
    
    return OrderItemList(
      items: orderProvider.currentOrder,
      isEditable: true,
      onDecrement: (index) => orderProvider.decrementItem(index),
      onIncrement: (index) => orderProvider.incrementItem(index),
      onRemove: (index) => orderProvider.removeItem(index),
    );
  }
}