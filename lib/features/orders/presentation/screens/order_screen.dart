import 'dart:convert'; // Necesario para json.encode
import 'package:http/http.dart' as http; // Necesario para la llamada PUT
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uno_y_medio/features/tables/data/models/table_model.dart';
import 'package:uno_y_medio/features/menu/presentation/providers/menu_provider.dart';
import 'package:uno_y_medio/features/orders/presentation/providers/order_provider.dart';
import 'package:uno_y_medio/features/orders/domain/entities/order_item.dart';

import 'package:uno_y_medio/features/menu/presentation/widgets/menu_item_card.dart';
import 'package:uno_y_medio/features/orders/presentation/widgets/order_summary.dart';
import 'package:uno_y_medio/features/tables/presentation/providers/table_provider.dart'; // Importación Faltante

class OrderScreen extends StatefulWidget {
  final TableModel table;

  const OrderScreen({super.key, required this.table});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  // URL del endpoint de pedidos del backend (POST para guardar la orden)
  final String _orderApiUrl = 'http://localhost:8080/api/pedidos';
  
  // URL del endpoint de CAJA del backend (PUT para registrar la venta)
  // Base: http://localhost:8080/api/caja
  final String _cajaApiUrl = 'http://localhost:8080/api/caja'; 

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final orderProvider = Provider.of<OrderProvider>(context, listen: false);

      final existingOrder = widget.table.currentOrder.map((oldItem) {
        return OrderItemEntity(
          item: oldItem.item,
          quantity: oldItem.quantity,
        );
      }).toList();

      orderProvider.loadOrderForTable(widget.table.id, existingOrder);
    });
  }

  void _saveOrder() async { 
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    final currentOrder = orderProvider.currentOrder;
    final totalAmount = orderProvider.total;

    if (currentOrder.isEmpty) {
      final updatedTable = TableModel(
        id: widget.table.id,
        status: 'Libre',
        currentOrder: const [],
      );
      Navigator.of(context).pop(updatedTable);
      return;
    }

    // 1. Preparar el cuerpo del pedido para Spring Boot
    final List<Map<String, dynamic>> detallesJson = 
        currentOrder.map((item) => item.toJson()).toList();
        
    final Map<String, dynamic> pedidoBody = {
      "mesaId": widget.table.id,
      "total": totalAmount.toStringAsFixed(2),
      "detalles": detallesJson,
    };

    // 2. Enviar a Spring Boot
    try {
      final response = await http.post(
        Uri.parse(_orderApiUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(pedidoBody),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // ÉXITO: La orden se guardó en el backend. 
        final updatedTable = TableModel(
          id: widget.table.id,
          status: 'Ocupada', 
          currentOrder: currentOrder,
        );
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Pedido guardado en el servidor!'), 
            backgroundColor: Colors.green,
          ),
        );
        
        // Volver a la lista de mesas y actualizar el estado local
        Navigator.of(context).pop(updatedTable);
        
      } else {
        throw Exception(
          'Fallo al guardar el pedido. Código: ${response.statusCode}. Respuesta: ${response.body}',
        );
      }
    } catch (e) {
      print('ERROR POST Pedido: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error al conectar o guardar el pedido: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _clearTable() {
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    final tableProvider = Provider.of<TableProvider>(context, listen: false);
    final totalToCollect = orderProvider.total;
    final tableId = widget.table.id;

    // Solo podemos cerrar la cuenta si hay una orden y un monto > 0
    if (totalToCollect <= 0) {
      final clearedTable = TableModel(id: tableId, status: 'Libre', currentOrder: const [],);
      tableProvider.updateTable(clearedTable);
      Navigator.of(context).pop();
      return;
    }


    showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cerrar Cuenta y Liberar'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Monto a cobrar de Mesa:'),
            const SizedBox(height: 8),
            Text(
              'S/. ${totalToCollect.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '¿Estás seguro de registrar este cobro en caja y liberar la mesa?',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(ctx).pop(true); // Cerrar diálogo

              // 1. Registrar la venta en el backend de CAJA (PUT /api/caja/sale)
              try {
                // *** CORRECCIÓN CLAVE: Concatenar _cajaApiUrl con /sale ***
                final response = await http.put(
                  Uri.parse('$_cajaApiUrl/sale'), 
                  headers: {
                    'Content-Type': 'application/json',
                  },
                  body: json.encode({
                    "amount": totalToCollect.toStringAsFixed(2),
                  }),
                );

                if (response.statusCode != 200) {
                  // Si falla la API de caja, mostramos error y NO liberamos la mesa
                  throw Exception('API Caja falló. Código: ${response.statusCode}');
                }

                // 2. ÉXITO: El cobro se registró en la DB. Ahora liberamos la mesa.
                final clearedTable = TableModel(
                  id: tableId,
                  status: 'Libre',
                  currentOrder: const [],
                );
                
                // Liberar la mesa y actualizar el estado
                // Llama implícitamente al polling para que la TableScreen se actualice
                tableProvider.updateTable(clearedTable); 
                
                // Mostrar éxito y cerrar OrderScreen
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('✅ Venta registrada y Mesa ${tableId} liberada.'),
                    backgroundColor: Colors.green,
                  ),
                );
                // El pop(clearedTable) actualizará el TableProvider en TableScreen
                Navigator.of(context).pop(clearedTable); 
                
              } catch (e) {
                print('ERROR al registrar venta en caja: $e');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('❌ Error al registrar venta: $e. Revisa la caja. (Caja debe estar abierta)'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Confirmar Cobro y Liberar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // ... (El resto del build se mantiene igual)
    final menuProvider = Provider.of<MenuProvider>(context);
    final orderProvider = Provider.of<OrderProvider>(context);

    final isLoading = menuProvider.isLoading;
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
      body: isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Cargando categorías y menú...'),
                ],
              ),
            )
          : Column(
              children: [
                // ✅ 1. SELECTOR DE CATEGORÍAS (Fijo)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  color: Colors.grey.shade100,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Selecciona Categoría:',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
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

                // ✅ 2. ÁREA SCROLLEABLE CON MENÚ Y ORDEN ACTUAL
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 📋 Sección del Menú
                        Container(
                          padding: const EdgeInsets.all(16.0),
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.05),
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
                              ...filteredMenu.map((item) {
                                return MenuItemCard(
                                  item: item,
                                  onAdd: () =>
                                      orderProvider.addOrUpdateItem(item),
                                );
                              }).toList(),
                            ],
                          ),
                        ),

                        // Separador
                        const Divider(height: 1, thickness: 1),

                        // 🛒 Título de Orden Actual
                        const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text(
                            'Orden Actual',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ),

                        // 📝 Lista de pedidos
                        currentOrder.isEmpty
                            ? Container(
                                padding: const EdgeInsets.all(40),
                                child: const Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
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
                                ),
                              )
                            : ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: currentOrder.length,
                                itemBuilder: (context, index) {
                                  final item = currentOrder[index];
                                  return Card(
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    elevation: 2,
                                    child: ListTile(
                                      contentPadding:
                                          const EdgeInsets.symmetric(
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
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
                                              color: Theme.of(context)
                                                  .primaryColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: Icon(
                                              item.quantity > 1
                                                  ? Icons.remove_circle_outline
                                                  : Icons.delete_outline,
                                              color: Colors.red,
                                              size: 28,
                                            ),
                                            onPressed: () => orderProvider
                                                .decrementItem(index),
                                            tooltip: item.quantity > 1
                                                ? 'Disminuir cantidad'
                                                : 'Eliminar',
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 12, vertical: 6),
                                            decoration: BoxDecoration(
                                              color: Theme.of(context)
                                                  .primaryColor
                                                  .withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              '${item.quantity}x',
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          IconButton(
                                            icon: const Icon(
                                              Icons.add_circle_outline,
                                              color: Colors.blue,
                                              size: 28,
                                            ),
                                            onPressed: () => orderProvider
                                                .incrementItem(index),
                                            tooltip: 'Aumentar cantidad',
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ],
                    ),
                  ),
                ),

                // ✅ 3. RESUMEN Y BOTÓN (Fijo en la parte inferior)
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