import 'package:flutter/material.dart';

class MyEndDrawer extends StatefulWidget {
  const MyEndDrawer({super.key});

  @override
  State<MyEndDrawer> createState() => _MyEndDrawerState();
}

class _MyEndDrawerState extends State<MyEndDrawer> {
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Drawer(
      backgroundColor: colors.surface,
      child: SafeArea(
        child: Column(
          children: [
            // 1. Header personalizado compacto con botón de cierre
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Menú',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      color: colors.onSurface,
                    ),
                  ),
                  // Botón para cerrar el Drawer
                  IconButton(
                    icon: Icon(Icons.close, color: colors.onSurface),
                    onPressed: () {
                      Navigator.pop(context); // 👈 Cierra el Drawer
                    },
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // 2. Lista de opciones
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                children: [
                  ListTile(
                    leading: Icon(Icons.person, color: colors.primary),
                    title: Text(
                      'Mi Perfil',
                      style: TextStyle(color: colors.onSurface),
                    ),
                    onTap: () {
                      Navigator.pop(context); // Cierra el drawer al seleccionar
                      //lógica de navegación
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.fitness_center, color: colors.primary),
                    title: Text(
                      'Mis Rutinas',
                      style: TextStyle(color: colors.onSurface),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.settings, color: colors.primary),
                    title: Text(
                      'Configuración',
                      style: TextStyle(color: colors.onSurface),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),

            // 3. Opción al pie (ej. Cerrar sesión)
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.redAccent),
              title: const Text(
                'Cerrar sesión',
                style: TextStyle(color: Colors.redAccent),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, '/login');
              },
            ),
          ],
        ),
      ),
    );
  }
}
