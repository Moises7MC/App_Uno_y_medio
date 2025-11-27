import 'package:flutter/material.dart';
import '../../data/models/table_model.dart';

class TableCard extends StatelessWidget {
  final TableModel table;
  final VoidCallback onTap;
  final bool showItemCount;
  final double? width;
  final double? height;

  const TableCard({
    super.key,
    required this.table,
    required this.onTap,
    this.showItemCount = true,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final isOccupied = table.currentOrder.isNotEmpty;
    final color = isOccupied ? Colors.red.shade400 : Colors.green.shade400;
    
    String statusText;
    if (isOccupied) {
      statusText = showItemCount 
          ? 'Ocupada (${table.currentOrder.length} ${table.currentOrder.length == 1 ? 'ítem' : 'ítems'})'
          : 'Ocupada';
    } else {
      statusText = 'Libre';
    }

    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            gradient: LinearGradient(
              colors: [color.withOpacity(0.8), color],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.table_bar,
                size: 40,
                color: Colors.white,
              ),
              const SizedBox(height: 10),
              Text(
                'Mesa ${table.id}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                statusText,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
              if (isOccupied && table.totalAmount > 0) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'S/. ${table.totalAmount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// Widget compacto para listas
class TableCardCompact extends StatelessWidget {
  final TableModel table;
  final VoidCallback onTap;

  const TableCardCompact({
    super.key,
    required this.table,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isOccupied = table.currentOrder.isNotEmpty;
    final color = isOccupied ? Colors.red : Colors.green;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color,
          child: const Icon(
            Icons.table_bar,
            color: Colors.white,
          ),
        ),
        title: Text(
          'Mesa ${table.id}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          isOccupied
              ? '${table.currentOrder.length} ítems - S/. ${table.totalAmount.toStringAsFixed(2)}'
              : 'Disponible',
        ),
        trailing: Icon(
          isOccupied ? Icons.shopping_cart : Icons.check_circle_outline,
          color: color,
        ),
        onTap: onTap,
      ),
    );
  }
}

// Widget con detalles extendidos
class TableCardDetailed extends StatelessWidget {
  final TableModel table;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  const TableCardDetailed({
    super.key,
    required this.table,
    required this.onTap,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final isOccupied = table.currentOrder.isNotEmpty;
    final color = isOccupied ? Colors.red.shade400 : Colors.green.shade400;

    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            gradient: LinearGradient(
              colors: [color.withOpacity(0.8), color],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.table_bar,
                        color: Colors.white,
                        size: 32,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Mesa ${table.id}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      isOccupied ? 'Ocupada' : 'Libre',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              
              if (isOccupied) ...[
                const SizedBox(height: 16),
                const Divider(color: Colors.white24),
                const SizedBox(height: 8),
                
                // Detalles de la orden
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${table.currentOrder.length} ${table.currentOrder.length == 1 ? 'plato' : 'platos'}',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Total: S/. ${table.totalAmount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    if (onClear != null)
                      IconButton(
                        icon: const Icon(
                          Icons.clear_all,
                          color: Colors.white,
                        ),
                        onPressed: onClear,
                        tooltip: 'Limpiar mesa',
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}