import 'package:flutter/material.dart';
import 'package:flutter_application/src/services/firebase_services.dart';

class EditProfilePage extends StatefulWidget {
  final String uid;
  const EditProfilePage({super.key, required this.uid});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();
  final _imagenCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  String? _profileId;
  bool _cargando = true;
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    _cargarDatosPerfil();
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _imagenCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _cargarDatosPerfil() async {
    try {
      final pid = await getPerfilActivoId(widget.uid);
      if (pid != null && pid.isNotEmpty) {
        final data = await getPerfil(widget.uid, pid);
        if (data != null && mounted) {
          _profileId = pid;
          _nombreCtrl.text = data['nombre'] ?? '';
          _imagenCtrl.text = data['image'] ?? '';
          _descCtrl.text = data['descripcion'] ?? '';
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al cargar perfil: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _cargando = false);
      }
    }
  }

  Future<void> _guardarCambios() async {
    if (!_formKey.currentState!.validate() || _profileId == null) return;

    setState(() => _guardando = true);
    try {
      await updatePerfil(
        uid: widget.uid,
        profileId: _profileId!,
        nombre: _nombreCtrl.text.trim(),
        image: _imagenCtrl.text.trim(),
        descripcion: _descCtrl.text.trim(),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Perfil actualizado con éxito!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _guardando = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    if (_cargando) {
      return Scaffold(
        appBar: AppBar(title: const Text('Editar Perfil Activo')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_profileId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Editar Perfil Activo')),
        body: const Center(
          child: Text('No hay un perfil activo seleccionado.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Editar Perfil Activo')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Vista previa de imagen de perfil
              Center(
                child: ValueListenableBuilder<TextEditingValue>(
                  valueListenable: _imagenCtrl,
                  builder: (context, val, child) {
                    final url = val.text.trim();
                    return CircleAvatar(
                      radius: 54,
                      backgroundColor: colors.surfaceContainerHighest,
                      backgroundImage: url.isNotEmpty
                          ? NetworkImage(url)
                          : null,
                      child: url.isEmpty
                          ? Icon(
                              Icons.person,
                              size: 54,
                              color: colors.onSurfaceVariant,
                            )
                          : null,
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),

              // Campo Nombre
              TextFormField(
                controller: _nombreCtrl,
                style: TextStyle(color: colors.primary),
                decoration: const InputDecoration(
                  labelText: 'Nombre del perfil',
                  prefixIcon: Icon(Icons.badge_outlined),
                  border: OutlineInputBorder(),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Ingresá un nombre';
                  }
                  if (val.trim().length < 3) {
                    return 'El nombre debe tener al menos 3 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Campo Imagen URL
              TextFormField(
                controller: _imagenCtrl,
                keyboardType: TextInputType.url,
                decoration: InputDecoration(
                  labelText: 'URL de imagen / Avatar',
                  prefixIcon: const Icon(Icons.image_outlined),
                  border: const OutlineInputBorder(),
                  suffixIcon: _imagenCtrl.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            setState(() => _imagenCtrl.clear());
                          },
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 16),

              // Campo Descripción
              TextFormField(
                controller: _descCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Descripción / Objetivo',
                  hintText: 'Ej. Enfoque hipertrofia, 4 días a la semana.',
                  prefixIcon: Icon(Icons.notes_outlined),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 32),

              // Botón Guardar
              FilledButton.icon(
                onPressed: _guardando ? null : _guardarCambios,
                icon: _guardando
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: colors.onSurface,
                        ),
                      )
                    : const Icon(Icons.save),
                label: Text(
                  _guardando ? 'Guardando...' : 'Guardar Cambios',
                  style: const TextStyle(fontSize: 16),
                ),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
