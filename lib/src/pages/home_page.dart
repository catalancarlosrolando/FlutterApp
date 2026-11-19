import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter_application/src/components/homepage/perfilDataContent.dart';

import 'package:flutter_application/src/services/firebase_services.dart';

class HomePage extends StatefulWidget {
  final String uid;

  const HomePage({super.key, required this.uid});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  User? get _user => FirebaseAuth.instance.currentUser;

  Widget _estado(String mensaje, {bool loading = false}) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: colors.surface,
      appBar: AppBar(title: const Text('Tu próxima rutina')),
      body: Center(
        child: loading ? const CircularProgressIndicator() : Text(mensaje),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<String?>(
      stream: streamPerfilActivoId(widget.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _estado('Cargando...', loading: true);
        }

        if (snapshot.hasError) {
          return _estado('Error al obtener el perfil activo.');
        }

        final profileId = snapshot.data;

        if (profileId == null || profileId.isEmpty) {
          return _estado('No hay perfil seleccionado.');
        }

        return PerfilDataContent(
          uid: widget.uid,
          profileId: profileId,
          scaffoldKey: _scaffoldKey,
          user: _user,
        );
      },
    );
  }
}
