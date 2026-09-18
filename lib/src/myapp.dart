import 'package:flutter/material.dart';
import 'package:flutter_application/src/pages/landing_page.dart';
import 'package:flutter_application/src/pages/login_page.dart';
import 'package:flutter_application/src/pages/main_navigation.dart';
import 'package:google_fonts/google_fonts.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    const brandColor = Color(0xFF2563EB);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      initialRoute: '/login',

      // Diccionario de rutas de la app
      routes: {
        '/login': (BuildContext context) => const LoginPage(),
        '/main': (BuildContext context) => const MainNavigationPage(),
      },

      // 1. Tema Claro
      theme: ThemeData(
        useMaterial3: true,

        colorScheme:
            ColorScheme.fromSeed(
              seedColor: brandColor,
              brightness: Brightness.light,
            ).copyWith(
              primary: brandColor, // azul exacto
            ),
        textTheme: GoogleFonts.nunitoTextTheme(),
        scaffoldBackgroundColor:
            Colors.grey[300], // Color de fondo para el tema claro
      ),

      // 2. Tema Oscuro
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme:
            ColorScheme.fromSeed(
              seedColor: brandColor,
              brightness: Brightness.dark,
            ).copyWith(
              primary: brandColor, // Mantiene mi branColor
            ),
        textTheme: GoogleFonts.nunitoTextTheme(),
        scaffoldBackgroundColor: Colors.black,
      ),

      themeMode: ThemeMode.system,
      home: const LoginPage(),
    );
  }
}
