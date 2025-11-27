import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uno_y_medio/features/tables/data/models/table_screen.dart';

// Importaciones del feature Menu
import 'package:uno_y_medio/features/menu/data/datasources/menu_local_datasource.dart';
import 'package:uno_y_medio/features/menu/data/repositories/menu_repository_impl.dart';
import 'package:uno_y_medio/features/menu/presentation/providers/menu_provider.dart';

// Importaciones del feature Tables
import 'package:uno_y_medio/features/tables/data/datasources/table_local_datasource.dart';
import 'package:uno_y_medio/features/tables/data/repositories/table_repository_impl.dart';
import 'package:uno_y_medio/features/tables/presentation/providers/table_provider.dart';

// Importaciones del feature Orders
import 'package:uno_y_medio/features/orders/data/datasources/order_local_datasource.dart';
import 'package:uno_y_medio/features/orders/data/repositories/order_repository_impl.dart';
import 'package:uno_y_medio/features/orders/presentation/providers/order_provider.dart';

// 👇 AÑADE ESTAS IMPORTACIONES del feature Cash Management
import 'package:uno_y_medio/features/cash_management/data/datasources/cash_flow_local_datasource.dart';
import 'package:uno_y_medio/features/cash_management/data/repositories/cash_flow_repository_impl.dart';
import 'package:uno_y_medio/features/cash_management/presentation/providers/cash_flow_provider.dart';

void main() {
  runApp(const RestaurantApp());
}

class RestaurantApp extends StatelessWidget {
  const RestaurantApp({super.key});

  @override
  Widget build(BuildContext context) {
    const MaterialColor primaryColor = MaterialColor(
      0xFFE55812,
      <int, Color>{
        50: Color(0xFFFAEBE5),
        100: Color(0xFFF4D2C0),
        200: Color(0xFFECAAA0),
        300: Color(0xFFE58170),
        400: Color(0xFFE2614B),
        500: Color(0xFFE55812),
        600: Color(0xFFE35010),
        700: Color(0xFFDF450D),
        800: Color(0xFFDB3B0A),
        900: Color(0xFFD52A05),
      },
    );

    return MultiProvider(
      providers: [
        // Provider para el feature Menu
        ChangeNotifierProvider(
          create: (_) => MenuProvider(
            repository: MenuRepositoryImpl(
              dataSource: MenuLocalDataSourceImpl(),
            ),
          ),
        ),
        // Provider para el feature Tables
        ChangeNotifierProvider(
          create: (_) => TableProvider(
            repository: TableRepositoryImpl(
              dataSource: TableLocalDataSourceImpl(),
            ),
          ),
        ),
        // Provider para el feature Orders
        ChangeNotifierProvider(
          create: (_) => OrderProvider(
            repository: OrderRepositoryImpl(
              dataSource: OrderLocalDataSourceImpl(),
            ),
          ),
        ),
        // 👇 AÑADE ESTE Provider para el feature Cash Management
        ChangeNotifierProvider(
          create: (_) => CashFlowProvider(
            repository: CashFlowRepositoryImpl(
              dataSource: CashFlowLocalDataSourceImpl(),
            ),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Gestión de Mesas',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: primaryColor,
          primaryColor: primaryColor,
          colorScheme: ColorScheme.fromSeed(
            seedColor: primaryColor,
            background: const Color(0xFFFCFAF9),
          ),
          useMaterial3: true,
          textTheme: const TextTheme(
            titleLarge: TextStyle(fontWeight: FontWeight.bold),
            bodyMedium: TextStyle(fontSize: 14.0),
          ),
        ),
        home: const TableScreen(),
      ),
    );
  }
}