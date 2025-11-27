import 'package:flutter/material.dart';
import '../../domain/entities/menu_item.dart';

class MenuItemCard extends StatelessWidget {
  final MenuItem item;
  final VoidCallback onAdd;
  final bool showPrice;
  final bool isCompact;

  const MenuItemCard({
    super.key,
    required this.item,
    required this.onAdd,
    this.showPrice = true,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isCompact) {
      return _buildCompactCard(context);
    }
    return _buildFullCard(context);
  }

  // Versión completa del card (la que usas actualmente)
  Widget _buildFullCard(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        title: Text(
          item.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: showPrice
            ? Text(
                'S/. ${item.price.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w500,
                ),
              )
            : null,
        trailing: IconButton(
          icon: const Icon(Icons.add_circle, color: Colors.green, size: 32),
          onPressed: onAdd,
          tooltip: 'Agregar ${item.name}',
        ),
      ),
    );
  }

  // Versión compacta (opcional, para usar en otros lugares)
  Widget _buildCompactCard(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        dense: true,
        title: Text(
          item.name,
          style: const TextStyle(fontSize: 14),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showPrice)
              Text(
                'S/. ${item.price.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
              ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.add_circle_outline, size: 20),
              onPressed: onAdd,
              color: Colors.green,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget alternativo con más información (para futuras mejoras)
class MenuItemDetailCard extends StatelessWidget {
  final MenuItem item;
  final VoidCallback onAdd;
  final String? description;
  final String? imageUrl;

  const MenuItemDetailCard({
    super.key,
    required this.item,
    required this.onAdd,
    this.description,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagen (opcional)
          if (imageUrl != null)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              child: Image.network(
                imageUrl!,
                height: 120,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 120,
                    color: Colors.grey.shade200,
                    child: const Icon(
                      Icons.restaurant,
                      size: 48,
                      color: Colors.grey,
                    ),
                  );
                },
              ),
            ),
          
          // Contenido
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        item.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'S/. ${item.price.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
                
                if (description != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    description!,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                
                const SizedBox(height: 8),
                
                // Chip de categoría
                Chip(
                  label: Text(
                    item.category,
                    style: const TextStyle(fontSize: 11),
                  ),
                  padding: EdgeInsets.zero,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                ),
                
                const SizedBox(height: 8),
                
                // Botón agregar
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: onAdd,
                    icon: const Icon(Icons.add_shopping_cart, size: 18),
                    label: const Text('Agregar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
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