import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/order_item.dart';
import '../providers/order_provider.dart';

class OrderSummary extends StatelessWidget {
  final List<OrderItemEntity> items;
  final double total;
  final VoidCallback? onSave;
  final String? saveButtonText;
  final bool showSaveButton;
  final bool isCompact;

  const OrderSummary({
    super.key,
    required this.items,
    required this.total,
    this.onSave,
    this.saveButtonText,
    this.showSaveButton = true,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isCompact) {
      return _buildCompactSummary(context);
    }
    return _buildFullSummary(context);
  }

  Widget _buildFullSummary(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Detalles del pedido
          _buildSummaryDetails(context),
          
          const SizedBox(height: 16),
          
          // Total
          _buildTotalRow(context),
          
          if (showSaveButton) ...[
            const SizedBox(height: 16),
            _buildSaveButton(context),
          ],
        ],
      ),
    );
  }

  Widget _buildCompactSummary(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Total (${items.length} ${items.length == 1 ? 'item' : 'items'})',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                Text(
                  'S/. ${total.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
          ),
          if (showSaveButton && onSave != null)
            ElevatedButton(
              onPressed: items.isEmpty ? null : onSave,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              child: Text(saveButtonText ?? 'Guardar'),
            ),
        ],
      ),
    );
  }

  Widget _buildSummaryDetails(BuildContext context) {
    final itemCount = items.length;
    final totalQuantity = items.fold(0, (sum, item) => sum + item.quantity);

    return Column(
      children: [
        _buildDetailRow(
          'Platos diferentes:',
          '$itemCount',
          Colors.grey.shade700,
        ),
        const SizedBox(height: 8),
        _buildDetailRow(
          'Cantidad total:',
          '$totalQuantity',
          Colors.grey.shade700,
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: color,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildTotalRow(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.grey.shade300, width: 2),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Total a Pagar:',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            'S/. ${total.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: items.isEmpty ? null : onSave,
        icon: const Icon(Icons.send),
        label: Text(saveButtonText ?? 'GUARDAR Y ENVIAR PEDIDO'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

// Widget para usar con Provider (versión simplificada)
class OrderSummaryWithProvider extends StatelessWidget {
  final VoidCallback? onSave;
  final String? saveButtonText;
  final bool showSaveButton;
  final bool isCompact;

  const OrderSummaryWithProvider({
    super.key,
    this.onSave,
    this.saveButtonText,
    this.showSaveButton = true,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);
    
    return OrderSummary(
      items: orderProvider.currentOrder,
      total: orderProvider.total,
      onSave: onSave,
      saveButtonText: saveButtonText,
      showSaveButton: showSaveButton,
      isCompact: isCompact,
    );
  }
}