import 'package:flutter/material.dart';
import 'package:flutter_application/src/components/myNavigatorbar.dart';
import 'package:flutter_application/src/pages/add_rutina_page.dart';
//import 'package:flutter_application/src/pages/createRoutines_page.dart';
import 'package:flutter_application/src/pages/home_page.dart';
import 'package:flutter_application/src/pages/routines_page.dart';
import 'package:flutter/services.dart' show SystemNavigator;

/// Navegador principal con 3 pestañas: Home, Ver Rutinas, Crear Rutina.
/// Requiere `uid` del usuario logueado para pasarlo a HomePage y MyRoutines.
class MainNavigationPage extends StatefulWidget {
  final String uid;
  const MainNavigationPage({super.key, required this.uid});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _selectedIndex = 0;

  // 1. Claves de navegación independientes por cada pestaña
  final List<GlobalKey<NavigatorState>> _navigatorKeys = [
    GlobalKey<NavigatorState>(), // Pestaña 0 - Home
    GlobalKey<NavigatorState>(), // Pestaña 1 - Ver Rutinas
    GlobalKey<NavigatorState>(), // Pestaña 2 - Crear Rutina
  ];

  void _goToCreateTab() {
    setState(() => _selectedIndex = 2);
  }

  /// Diálogo de confirmación antes de salir de la app.
  /// Se muestra solo cuando la pestaña activa está en su raíz
  /// (no hay nada que retroceder dentro de la pestaña).
  Future<void> _confirmarSalida() async {
    final colors = Theme.of(context).colorScheme;
    final salir = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          backgroundColor: colors.surfaceContainer,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            '¿Salir de la aplicación?',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: colors.onSurface,
            ),
          ),
          content: Text(
            '¿Está seguro que quiere salir de la aplicación?',
            style: TextStyle(
              fontWeight: FontWeight.normal,
              color: colors.onSurface,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogCtx, true),
              child: const Text('Salir'),
            ),
          ],
        );
      },
    );

    if (salir == true) {
      // Cierra la app (equivale a salir con el botón atrás del sistema)
      await SystemNavigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return PopScope(
      // La app nunca se cierra automáticamente: el pop se decide a mano.
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;

        // 1. Si la pestaña activa tiene páginas apiladas, retrocede en ella.
        final NavigatorState? currentNavigator =
            _navigatorKeys[_selectedIndex].currentState;
        if (currentNavigator != null && currentNavigator.canPop()) {
          currentNavigator.pop();
          return;
        }

        // 2. Estamos en la raíz de la pestaña: pedir confirmación antes de salir.
        _confirmarSalida();
      },
      child: Scaffold(
        // Body con IndexedStack (instantáneo, sin animaciones y guarda el estado)
        body: IndexedStack(
          index: _selectedIndex,
          children: [
            _buildTabNavigator(_navigatorKeys[0], HomePage(uid: widget.uid)),
            _buildTabNavigator(_navigatorKeys[1], MyRoutines(uid: widget.uid)),
            _buildTabNavigator(
              _navigatorKeys[2],
              AddRutinaPage(
                uid: widget.uid,
                onRutinaCreada: () {
                  setState(() => _selectedIndex = 0);
                },
              ),
            ),
          ],
        ),

        floatingActionButton: FloatingActionButton(
          shape: const CircleBorder(), // Círculo perfecto
          backgroundColor: colors.primary,
          onPressed: _goToCreateTab, // Cambia a la pestaña "Crear Rutina"
          child: Icon(Icons.add, color: colors.onPrimary, size: 28),
        ),

        // Boton en el medio de la barra:
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

        // Barra de navegación inferior
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
