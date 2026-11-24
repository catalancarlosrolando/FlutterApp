// ======================================================
// OBTIENE LOS DATOS DEL PERFIL: UNA SOLA SUSCRIPCIÓN
// ======================================================
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/src/components/homepage/Drawer.dart';
import 'package:flutter_application/src/components/homepage/proximaRutina.dart';
import 'package:flutter_application/src/services/firebase_services.dart';

class PerfilDataContent extends StatelessWidget {
  final String uid;
  final String profileId;
  final GlobalKey<ScaffoldState> scaffoldKey;
  final User? user;

  const PerfilDataContent({
    super.key,
    required this.uid,
    required this.profileId,
    required this.scaffoldKey,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map<String, dynamic>?>(
      stream: streamPerfil(uid, profileId),
      builder: (context, snapshot) {
        final colors = Theme.of(context).colorScheme;
        final isDark = Theme.of(context).brightness == Brightness.dark;

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            key: scaffoldKey,
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            key: scaffoldKey,
            appBar: AppBar(title: const Text('FitAccess')),
            drawer: MyDrawer(
              colors: colors,
              isDark: isDark,
              uid: uid,
              photoUrl: user?.photoURL ?? '',
              displayName: user?.displayName ?? '',
              email: user?.email ?? '',
            ),
            body: Center(
              child: Text(
                'Error al obtener los datos del perfil.',
                style: TextStyle(color: colors.error),
              ),
            ),
          );
        }

        final perfilData = snapshot.data;

        if (perfilData == null) {
          return Scaffold(
            key: scaffoldKey,
            appBar: AppBar(title: const Text('FitAccess')),
            drawer: MyDrawer(
              colors: colors,
              isDark: isDark,
              uid: uid,
              photoUrl: user?.photoURL ?? '',
              displayName: user?.displayName ?? '',
              email: user?.email ?? '',
            ),
            body: const Center(
              child: Text('No se encontraron datos del perfil.'),
            ),
          );
        }

        final photoUrl = perfilData['image'] as String? ?? user?.photoURL ?? '';

        final displayName =
            perfilData['nombre'] as String? ?? user?.displayName ?? '';

        final email = user?.email ?? '';

        // Los datos del perfil se comparten entre
        // el AppBar y el Drawer.

        return Scaffold(
          key: scaffoldKey,
          backgroundColor: colors.surface,

          appBar: AppBar(
            backgroundColor: colors.surface,
            elevation: 0,
            leading: Padding(
              padding: const EdgeInsets.only(left: 12, top: 8, bottom: 8),
              child: Tooltip(
                message: 'Abrir menú',
                child: InkWell(
                  onTap: () => scaffoldKey.currentState?.openDrawer(),
                  customBorder: const CircleBorder(),
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: colors.primary, width: 2),
                    ),
                    child: CircleAvatar(
                      radius: 20,
                      backgroundColor: colors.primaryContainer,
                      backgroundImage: photoUrl.isNotEmpty
                          ? NetworkImage(photoUrl)
                          : null,
                      child: photoUrl.isEmpty
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
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  style: TextStyle(fontSize: 25.0, color: colors.onSurface),
                ),
                Text(
                  "Retoma donde lo dejaste",
                  style: TextStyle(fontSize: 16.0, color: colors.onSurface),
                ),
              ],
            ),
          ),

          // Drawer recibe los datos ya obtenidos.
          // No necesita otro StreamBuilder.
          drawer: MyDrawer(
            colors: colors,
            isDark: isDark,
            uid: uid,
            photoUrl: photoUrl,
            displayName: displayName,
            email: email,
          ),

          // La próxima rutina tiene su propia suscripción.
          body: ProximaRutina(uid: uid, profileId: profileId, colors: colors),
        );
      },
    );
  }
}
