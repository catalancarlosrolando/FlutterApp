import 'package:flutter/material.dart';
import 'package:flutter_application/src/pages/home_page.dart';
import 'package:flutter_application/src/pages/landing_page.dart';
import 'package:google_fonts/google_fonts.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    const brandColor = Color(0xFF2563EB);
    return MaterialApp(
      title: 'Flutter Demo',
      initialRoute: '/login',

      // Diccionario de rutas de la app
      routes: {
        '/login': (BuildContext context) =>
            const MyHomePage(title: 'Login Page'),
        '/landing': (BuildContext context) =>
            const LandingPage(title: "Landing Page"),
      },

      // 1. Tema Claro
      theme: ThemeData(
        useMaterial3: true,

        colorScheme:
            ColorScheme.fromSeed(
              seedColor: brandColor,
              brightness: Brightness.light,
            ).copyWith(
              primary: brandColor, // 👈 Tu azul saturado exacto
              onPrimary: Colors.white,
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
              onPrimary: Colors.white,
            ),
        scaffoldBackgroundColor: Colors.black,
      ),

      themeMode: ThemeMode.system,
      home: const MyHomePage(title: 'Login Page'),
    );
  }
}
