import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:flutter_application/main.dart';
import 'package:flutter_application/src/pages/profile_selection_page.dart';
import 'package:flutter_application/src/pages/edit_profile_page.dart';
import 'package:flutter_application/src/pages/routine_details_page.dart';
import 'package:flutter_application/src/components/Exercise.dart';
import 'package:flutter_application/src/services/firebase_services.dart';

/// Home: muestra la PRÓXIMA rutina no finalizada (la "siguiente").
/// Usa StreamBuilder para que reaccione en tiempo real a cambios en Firestore.
///
/// Si todas están finalizadas o no hay rutinas → estado vacío.
class HomePage extends StatefulWidget {
  final String uid;
  const HomePage({super.key, required this.uid});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Clave del Scaffold para abrir el Drawer desde el Avatar del AppBar.
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  /// Usuario actual de Firebase (trae photoURL, displayName y email de Google).
  User? get _user => FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = _user;
    final photoUrl = user?.photoURL;
    final displayName = user?.displayName ?? '';
    final email = user?.email ?? '';

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: colors.surface,
      appBar: AppBar(
        backgroundColor: colors.surface,
        elevation: 0,
        // Reemplaza el ícono hamburguesa por el Avatar del usuario.
        // Al tocarlo se abre el Drawer.
        leading: Padding(
          padding: const EdgeInsets.only(left: 12.0, top: 8.0, bottom: 8.0),
          child: Tooltip(
            message: 'Abrir menú',
            child: InkWell(
              onTap: () => _scaffoldKey.currentState?.openDrawer(),
              borderRadius: BorderRadius.circular(20),
              child: CircleAvatar(
                radius: 20,
                backgroundColor: colors.primaryContainer,
                backgroundImage: (photoUrl != null && photoUrl.isNotEmpty)
                    ? NetworkImage(photoUrl)
                    : null,
                child: (photoUrl == null || photoUrl.isEmpty)
                    ? Icon(
                        Icons.person,
                        size: 22,
                        color: colors.onPrimaryContainer,
                      )
                    : null,
              ),
            ),
          ),
        ),
        title: const Text('Tu próxima rutina'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: colors.primary),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CircleAvatar(
                    backgroundColor: colors.onPrimary,
                    radius: 28,
                    backgroundImage: (photoUrl != null && photoUrl.isNotEmpty)
                        ? NetworkImage(photoUrl)
                        : null,
                    child: (photoUrl == null || photoUrl.isEmpty)
                        ? Icon(Icons.person, size: 36, color: colors.primary)
                        : null,
                  ),
                  const SizedBox(height: 12),
                  if (displayName.isNotEmpty)
                    Text(
                      displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: colors.onPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  if (email.isNotEmpty)
                    Text(
                      email,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: colors.onPrimary.withAlpha(200),
                        fontSize: 13,
                      ),
                    ),
                  if (displayName.isEmpty && email.isEmpty)
                    Text(
                      'Menú',
                      style: TextStyle(
                        color: colors.onPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.switch_account),
              title: const Text('Elección de perfil'),
              onTap: () {
                Navigator.pop(context); // Cierra el Drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfileSelectionPage(uid: widget.uid),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Editar perfil'),
              onTap: () {
                Navigator.pop(context); // Cierra el Drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditProfilePage(uid: widget.uid),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
              title: Text(isDark ? 'Modo claro' : 'Modo oscuro'),
              trailing: Switch(
                value: isDark,
                onChanged: (val) {
                  themeNotifier.value = val ? ThemeMode.dark : ThemeMode.light;
                },
              ),
              onTap: () {
                themeNotifier.value = isDark ? ThemeMode.light : ThemeMode.dark;
              },
            ),
            const Divider(),
            ListTile(
              leading: IconButton(
                icon: Icon(Icons.logout, color: colors.error),
                onPressed: () async {
                  Navigator.pop(context);
                  await GoogleSignIn.instance.disconnect();
                  await FirebaseAuth.instance.signOut();
                },
              ),
              title: Text(
                'Cerrar sesión',
                style: TextStyle(color: colors.error),
              ),
              onTap: () async {
                Navigator.pop(context);
                await GoogleSignIn.instance.disconnect();
                await FirebaseAuth.instance.signOut();
              },
            ),
          ],
        ),
      ),
      body: StreamBuilder<String?>(
        stream: streamPerfilActivoId(widget.uid),
        builder: (context, activeSnap) {
          if (activeSnap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final profileId = activeSnap.data;
          if (profileId == null || profileId.isEmpty) {
            return const Center(child: Text('No hay perfil seleccionado.'));
          }

          return StreamBuilder<Map<String, dynamic>?>(
            stream: streamProximaRutina(widget.uid, profileId),
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snap.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      'Error: ${snap.error}',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: colors.error),
                    ),
                  ),
                );
              }
              final rutina = snap.data;
              if (rutina == null) {
                return _EmptyState(colors: colors);
              }
              return _RutinaCard(
                uid: widget.uid,
                profileId: profileId,
                rutina: rutina,
                colors: colors,
              );
            },
          );
        },
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final ColorScheme colors;
  const _EmptyState({required this.colors});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.fitness_center,
              size: 80,
              color: colors.onSurfaceVariant.withAlpha(120),
            ),
            const SizedBox(height: 16),
            Text(
              'No tenés rutinas pendientes',
              style: TextStyle(
                color: colors.onSurface,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Creá una nueva rutina con el botón + de abajo\npara empezar a entrenar.',
              textAlign: TextAlign.center,
              style: TextStyle(color: colors.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

class _RutinaCard extends StatelessWidget {
  final String uid;
  final String profileId;
  final Map<String, dynamic> rutina;
  final ColorScheme colors;

  const _RutinaCard({
    required this.uid,
    required this.profileId,
    required this.rutina,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    final ejercicios = List.from(rutina['ejercicios'] ?? []);
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Header de la rutina clickeable
        InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => RoutineDetails(
                  rutina: rutina,
                  uid: uid,
                  profileId: profileId,
                ),
              ),
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  children: [
                    (rutina['image'] as String).isNotEmpty
                        ? Image.network(
                            rutina['image'],
                            width: double.infinity,
                            height: 180,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              width: double.infinity,
                              height: 180,
                              color: colors.surfaceContainerHigh,
                              child: Icon(
                                Icons.fitness_center,
                                size: 60,
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                          )
                        : Container(
                            width: double.infinity,
                            height: 180,
                            color: colors.surfaceContainerHigh,
                            child: Icon(
                              Icons.fitness_center,
                              size: 60,
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: colors.primary,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          (rutina['categoria'] ?? '').toString().toUpperCase(),
                          style: TextStyle(
                            color: colors.onPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      rutina['name'] ?? '',
                      style: TextStyle(
                        color: colors.onSurface,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 18,
                    color: colors.onSurfaceVariant,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '${rutina['tiempo']} · ${ejercicios.length} ejercicios · Ver detalles',
                style: TextStyle(color: colors.primary, fontSize: 14),
              ),
              const SizedBox(height: 12),
              if ((rutina['description'] as String).isNotEmpty)
                Text(
                  rutina['description'],
                  style: TextStyle(
                    color: colors.onSurfaceVariant,
                    fontSize: 14,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Lista de ejercicios
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Ejercicios',
              style: TextStyle(
                color: colors.onSurface,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RoutineDetails(
                      rutina: rutina,
                      uid: uid,
                      profileId: profileId,
                    ),
                  ),
                );
              },
              child: const Text('Ver todos'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...ejercicios.asMap().entries.map(
          (entry) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Exercise(
              exercise: Map<String, dynamic>.from(entry.value),
              uid: uid,
              profileId: profileId,
              rutinaId: rutina['uid_doc'],
              exerciseIndex: entry.key,
            ),
          ),
        ),
      ],
    );
  }
}
