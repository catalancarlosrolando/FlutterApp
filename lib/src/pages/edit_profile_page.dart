import 'package:flutter/material.dart';

class EditProfilePage extends StatelessWidget {
  final String uid;
  const EditProfilePage({super.key, required this.uid});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Perfil'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.edit_outlined, size: 80, color: colors.primary),
              const SizedBox(height: 16),
              const Text(
                'Editar Datos de Perfil',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                '// PENDIENTE: Cargar y actualizar datos del perfil actual en Firebase.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
