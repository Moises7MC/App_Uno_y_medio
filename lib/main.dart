import 'package:flutter/material.dart';
import 'package:uno_y_medio/screens/table_screen.dart';

void main() {

  runApp(const RestaurantApp());

}



class RestaurantApp extends StatelessWidget {

  const RestaurantApp({super.key});

  @override

  Widget build(BuildContext context) {

    // Definimos una paleta de colores cálida y moderna

    const MaterialColor primaryColor = MaterialColor(

      0xFFE55812, // Color Naranja/Terracota

      <int, Color>{

        50: Color(0xFFFAEBE5),

        100: Color(0xFFF4D2C0),

        200: Color(0xFFECAAA0),

        300: Color(0xFFE58170),

        400: Color(0xFFE2614B),

        500: Color(0xFFE55812), // Color principal

        600: Color(0xFFE35010),

        700: Color(0xFFDF450D),

        800: Color(0xFFDB3B0A),

        900: Color(0xFFD52A05),

      },

    );



    return MaterialApp(

      title: 'Gestión de Mesas',

      // Ocultamos el banner de debug

      debugShowCheckedModeBanner: false, 

      theme: ThemeData(

        primarySwatch: primaryColor,

        primaryColor: primaryColor,

        colorScheme: ColorScheme.fromSeed(

          seedColor: primaryColor,

          // Un fondo ligeramente crema para mayor calidez

          background: const Color(0xFFFCFAF9), 

        ),

        useMaterial3: true,

        // Estilo de texto para la app

        textTheme: const TextTheme(

          titleLarge: TextStyle(fontWeight: FontWeight.bold),

          bodyMedium: TextStyle(fontSize: 14.0),

        ),

      ),

      // Usamos la pantalla de Mesas como el home

      home: const TableScreen(), 

    );

  }

}

