import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application/src/components/homepage/Drawer.dart';
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
  bool _ensuringProfile = false;

  User? get _user => FirebaseAuth.instance.currentUser;

  Future<void> _ensureUserProfile() async {
    if (_ensuringProfile || widget.uid.isEmpty) return;
    _ensuringProfile = true;
    try {
      final user = _user;
      await crearUsuario(
        uid: widget.uid,
        email: user?.email ?? '',
        nombre: user?.displayName ?? (user?.email ?? '').split('@').first,
        photoUrl: user?.photoURL ?? '',
      );
    } catch (_) {
      // Handled by stream state if Firestore rules deny access
    }
  }

  Widget _estado(String mensaje, {bool loading = false}) {
    final colors = Theme.of(context).colorScheme;
    final user = _user;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: colors.surface,
      appBar: AppBar(title: const Text('Tu próxima rutina')),
      drawer: MyDrawer(
        colors: colors,
        uid: widget.uid,
        photoUrl: user?.photoURL ?? '',
        displayName: user?.displayName ?? '',
        email: user?.email ?? '',
      ),
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
          _ensureUserProfile();
          return _estado('Preparando tu perfil...', loading: true);
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
