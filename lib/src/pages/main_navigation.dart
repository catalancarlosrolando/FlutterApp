import 'package:flutter/material.dart';
import 'package:flutter_application/src/components/myNavigatorbar.dart';
import 'package:flutter_application/src/pages/createRoutines_page.dart';
import 'package:flutter_application/src/pages/landing_page.dart';
import 'package:flutter_application/src/pages/routines_page.dart';

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _selectedIndex = 0;

  // 1. Claves de navegación independientes por cada pestaña
  final List<GlobalKey<NavigatorState>> _navigatorKeys = [
    GlobalKey<NavigatorState>(), // Pestaña 0
    GlobalKey<NavigatorState>(), // Pestaña 1
    GlobalKey<NavigatorState>(), // Pestaña 2
  ];

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return NavigatorPopHandler(
      // Control del botón "Atrás" de Android para retroceder en la pestaña activa
      onPopWithResult: (void result) {
        final NavigatorState? currentNavigator =
            _navigatorKeys[_selectedIndex].currentState;
        if (currentNavigator != null && currentNavigator.canPop()) {
          currentNavigator.pop();
        }
      },
      child: Scaffold(
        // Body con IndexedStack (instantáneo, sin animaciones y guarda el estado)
        body: IndexedStack(
          index: _selectedIndex,
          children: [
            _buildTabNavigator(
              _navigatorKeys[0],
              const LandingPage(title: "Landing Page"),
            ),
            _buildTabNavigator(_navigatorKeys[1], const MyRoutines()),
            _buildTabNavigator(_navigatorKeys[2], const CreateRoutine()),
          ],
        ),

        floatingActionButton: FloatingActionButton(
          shape: const CircleBorder(), // Círculo perfecto
          backgroundColor: colors.primary,
          onPressed: () {
            // Acción rápida (Crear nueva rutina)
          },
          child: const Icon(Icons.add, color: Colors.white, size: 28),
        ),

        // 2. 👈 Esta línea mágica lo coloca flotando en el medio de la barra:
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

        // 3. Barra de navegación inferior
        bottomNavigationBar: MyNavigationBar(
          currentIndex: _selectedIndex,
          onDestinationSelected: (int index) {
            setState(() {
              _selectedIndex = index;
            });
          },
        ),
      ),
    );
  }

  // Genera el sub-navegador para que cada pestaña tenga su propia pila de navegación
  Widget _buildTabNavigator(GlobalKey<NavigatorState> key, Widget initialPage) {
    return Navigator(
      key: key,
      onGenerateRoute: (RouteSettings settings) {
        return MaterialPageRoute(builder: (context) => initialPage);
      },
    );
  }
}
