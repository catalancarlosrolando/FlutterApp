// firebase_services.dart — Patrón cátedra: funciones sueltas.
//
// Colecciones:
//   usuarios/{uid}                                  → { nombre, email, defaultProfileId }
//   usuarios/{uid}/perfiles/{profileId}             → { nombre, createdAt }
//   usuarios/{uid}/perfiles/{profileId}/rutinas/{id} → { categoria, name, description, image, tiempo, finalizada, ejercicios: [...] }
//   ejercicios/{id}                                 → { id, name, image (URL Cloudinary), tiempo, description }

import 'package:cloud_firestore/cloud_firestore.dart';

final FirebaseFirestore _db = FirebaseFirestore.instance;

// ===================== USUARIOS Y PERFILES =====================

/// Flujo completo:
/// 1. Si el usuario ya existe en Firestore, devuelve su defaultProfileId.
/// 2. Si no existe, crea perfil inicial "Principal" en subcolección perfiles
///    y guarda su id en defaultProfileId del usuario.
Future<String> crearUsuario({
  required String uid,
  required String email,
  required String nombre,
  String photoUrl = '',
}) async {
  final userRef = _db.collection('usuarios').doc(uid);
  final snap = await userRef.get();

  if (snap.exists) {
    final data = snap.data();
    final profileId = data?['defaultProfileId'] as String?;
    if (profileId != null && profileId.isNotEmpty) {
      return profileId;
    }
  }

  // Crear perfil predeterminado en subcolección
  final perfilRef = userRef.collection('perfiles').doc();
  await perfilRef.set({
    'nombre': 'Principal',
    'image': photoUrl,
    'descripcion': 'Perfil predeterminado',
    'createdAt': FieldValue.serverTimestamp(),
  });

  // Guardar documento del usuario con su perfil activo
  await userRef.set({
    'nombre': nombre,
    'email': email,
    'photoUrl': photoUrl,
    'defaultProfileId': perfilRef.id,
    'createdAt': FieldValue.serverTimestamp(),
  }, SetOptions(merge: true));

  return perfilRef.id;
}

/// Obtiene el defaultProfileId activo actual (Future).
Future<String?> getPerfilActivoId(String uid) async {
  final snap = await _db.collection('usuarios').doc(uid).get();
  if (!snap.exists) return null;
  return snap.data()?['defaultProfileId'] as String?;
}

/// Stream reactivo del profileId activo del usuario.
Stream<String?> streamPerfilActivoId(String uid) {
  return _db.collection('usuarios').doc(uid).snapshots().map((snap) {
    if (!snap.exists) return null;
    return snap.data()?['defaultProfileId'] as String?;
  });
}

/// Stream con la lista de todos los perfiles creados por el usuario.
Stream<List<Map<String, dynamic>>> streamPerfiles(String uid) {
  return _db
      .collection('usuarios')
      .doc(uid)
      .collection('perfiles')
      .orderBy('createdAt', descending: false)
      .snapshots()
      .map((q) => q.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList());
}

/// Crea un nuevo perfil en la subcolección del usuario.
Future<String> crearNuevoPerfil(
  String uid,
  String nombrePerfil, {
  String image = '',
  String descripcion = '',
}) async {
  final ref = await _db
      .collection('usuarios')
      .doc(uid)
      .collection('perfiles')
      .add({
        'nombre': nombrePerfil,
        'image': image,
        'descripcion': descripcion,
        'createdAt': FieldValue.serverTimestamp(),
      });
  return ref.id;
}

/// Obtiene los datos del perfil activo.
Future<Map<String, dynamic>?> getPerfil(String uid, String profileId) async {
  final snap = await _db
      .collection('usuarios')
      .doc(uid)
      .collection('perfiles')
      .doc(profileId)
      .get();
  if (!snap.exists) return null;
  return {'id': snap.id, ...snap.data()!};
}

/// Stream de los datos del perfil activo en tiempo real.
Stream<Map<String, dynamic>?> streamPerfil(String uid, String profileId) {
  return _db
      .collection('usuarios')
      .doc(uid)
      .collection('perfiles')
      .doc(profileId)
      .snapshots()
      .map((snap) => snap.exists ? {'id': snap.id, ...snap.data()!} : null);
}

/// Actualiza los datos de un perfil (nombre, imagen, descripción).
Future<void> updatePerfil({
  required String uid,
  required String profileId,
  required String nombre,
  required String image,
  required String descripcion,
}) async {
  await _db
      .collection('usuarios')
      .doc(uid)
      .collection('perfiles')
      .doc(profileId)
      .set({
        'nombre': nombre,
        'image': image,
        'descripcion': descripcion,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
}

/// Cambia el perfil activo del usuario.
Future<void> cambiarPerfilActivo(String uid, String profileId) async {
  await _db.collection('usuarios').doc(uid).update({
    'defaultProfileId': profileId,
  });
}

// ===================== RUTINAS — STREAMS =====================

/// Stream reactivo de las rutinas del perfil, agrupadas por categoría.
/// Devuelve un map: { 'push': [...], 'pull': [...], 'legs': [...], 'core': [...] }
Stream<Map<String, List>> streamRutinasPorCategoria(
  String uid,
  String profileId,
) {
  return _db
      .collection('usuarios')
      .doc(uid)
      .collection('perfiles')
      .doc(profileId)
      .collection('rutinas')
      .snapshots()
      .map((query) {
        final out = <String, List>{
          'push': [],
          'pull': [],
          'legs': [],
          'core': [],
        };
        for (var doc in query.docs) {
          final data = doc.data();
          final cat = data['categoria'] ?? 'push';
          out.putIfAbsent(cat, () => []);
          out[cat]!.add(_rutinaFromDoc(doc));
        }
        return out;
      });
}

/// Stream reactivo de TODAS las rutinas del perfil (lista plana).
Stream<List<Map<String, dynamic>>> streamRutinas(String uid, String profileId) {
  return _db
      .collection('usuarios')
      .doc(uid)
      .collection('perfiles')
      .doc(profileId)
      .collection('rutinas')
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((q) => q.docs.map(_rutinaFromDoc).toList());
}

/// Stream de la próxima rutina NO finalizada del perfil.
Stream<Map<String, dynamic>?> streamProximaRutina(
  String uid,
  String profileId,
) {
  return _db
      .collection('usuarios')
      .doc(uid)
      .collection('perfiles')
      .doc(profileId)
      .collection('rutinas')
      .where('finalizada', isEqualTo: false)
      .orderBy('createdAt')
      .limit(1)
      .snapshots()
      .map((q) => q.docs.isEmpty ? null : _rutinaFromDoc(q.docs.first));
}

/// Stream reactivo de una rutina específica por su ID.
Stream<Map<String, dynamic>?> streamRutina({
  required String uid,
  required String profileId,
  required String rutinaId,
}) {
  return _db
      .collection('usuarios')
      .doc(uid)
      .collection('perfiles')
      .doc(profileId)
      .collection('rutinas')
      .doc(rutinaId)
      .snapshots()
      .map((doc) => doc.exists ? _rutinaFromDoc(doc) : null);
}

Map<String, dynamic> _rutinaFromDoc(DocumentSnapshot doc) {
  final data = doc.data() as Map<String, dynamic>;
  return {
    'uid_doc': doc.id,
    'categoria': data['categoria'] ?? 'push',
    'name': data['name'] ?? '',
    'description': data['description'] ?? '',
    'image': data['image'] ?? '',
    'tiempo': data['tiempo'] ?? '',
    'finalizada': data['finalizada'] ?? false,
    'ejercicios': data['ejercicios'] ?? [],
  };
}

// ===================== RUTINAS — ESCRITURA =====================

/// Crea una rutina con ejercicios dentro del perfil activo.
Future<String> addRutina({
  required String uid,
  required String profileId,
  required String categoria,
  required String name,
  required String description,
  required String image,
  required String tiempo,
  List<Map<String, dynamic>> ejercicios = const [],
}) async {
  final ref = await _db
      .collection('usuarios')
      .doc(uid)
      .collection('perfiles')
      .doc(profileId)
      .collection('rutinas')
      .add({
        'categoria': categoria,
        'name': name,
        'description': description,
        'image': image,
        'tiempo': tiempo,
        'finalizada': false,
        'ejercicios': ejercicios,
        'createdAt': FieldValue.serverTimestamp(),
      });
  return ref.id;
}

Future<void> updateRutina({
  required String uid,
  required String profileId,
  required String uidDoc,
  required String name,
  required String description,
  required String tiempo,
  String? categoria,
  String? image,
  List<Map<String, dynamic>>? ejercicios,
}) async {
  final Map<String, dynamic> data = {
    'name': name,
    'description': description,
    'tiempo': tiempo,
    'updatedAt': FieldValue.serverTimestamp(),
  };
  if (categoria != null) data['categoria'] = categoria;
  if (image != null) data['image'] = image;
  if (ejercicios != null) data['ejercicios'] = ejercicios;

  await _db
      .collection('usuarios')
      .doc(uid)
      .collection('perfiles')
      .doc(profileId)
      .collection('rutinas')
      .doc(uidDoc)
      .set(data, SetOptions(merge: true));
}

Future<void> borrarRutina({
  required String uid,
  required String profileId,
  required String uidDoc,
}) async {
  await _db
      .collection('usuarios')
      .doc(uid)
      .collection('perfiles')
      .doc(profileId)
      .collection('rutinas')
      .doc(uidDoc)
      .delete();
}

/// Marca (o desmarca) una rutina como finalizada.
Future<void> setRutinaFinalizada({
  required String uid,
  required String profileId,
  required String uidDoc,
  required bool finalizada,
}) async {
  await _db
      .collection('usuarios')
      .doc(uid)
      .collection('perfiles')
      .doc(profileId)
      .collection('rutinas')
      .doc(uidDoc)
      .update({'finalizada': finalizada});
}

// ===================== EJERCICIOS DE UNA RUTINA =====================

/// Stream reactivo de los ejercicios de una rutina del perfil.
Stream<List<Map<String, dynamic>>> streamEjerciciosDeRutina({
  required String uid,
  required String profileId,
  required String rutinaId,
}) {
  return _db
      .collection('usuarios')
      .doc(uid)
      .collection('perfiles')
      .doc(profileId)
      .collection('rutinas')
      .doc(rutinaId)
      .snapshots()
      .map((doc) {
        if (!doc.exists) return <Map<String, dynamic>>[];
        final data = doc.data() as Map<String, dynamic>;
        return List<Map<String, dynamic>>.from(data['ejercicios'] ?? []);
      });
}

/// Añade un ejercicio a una rutina del perfil.
Future<void> addEjercicioARutina({
  required String uid,
  required String profileId,
  required String rutinaId,
  required Map<String, dynamic> ejercicio,
}) async {
  await _db
      .collection('usuarios')
      .doc(uid)
      .collection('perfiles')
      .doc(profileId)
      .collection('rutinas')
      .doc(rutinaId)
      .update({
        'ejercicios': FieldValue.arrayUnion([ejercicio]),
      });
}

Future<void> borrarEjercicioDeRutina({
  required String uid,
  required String profileId,
  required String rutinaId,
  required String ejercicioId,
}) async {
  final docRef = _db
      .collection('usuarios')
      .doc(uid)
      .collection('perfiles')
      .doc(profileId)
      .collection('rutinas')
      .doc(rutinaId);
  final snap = await docRef.get();
  final data = snap.data() ?? {};
  final ejercicios = List.from(data['ejercicios'] ?? []);
  ejercicios.removeWhere((e) => e['id'] == ejercicioId);
  await docRef.update({'ejercicios': ejercicios});
}

/// Actualiza un ejercicio específico o la lista de ejercicios de una rutina,
/// permitiendo modificar campos como finalizado, series, peso, reps, etc.
Future<void> updateEjercicioEnRutina({
  required String uid,
  required String profileId,
  required String rutinaId,
  required Map<String, dynamic> ejercicioActualizado,
  int? ejercicioIndex,
}) async {
  final docRef = _db
      .collection('usuarios')
      .doc(uid)
      .collection('perfiles')
      .doc(profileId)
      .collection('rutinas')
      .doc(rutinaId);
  final snap = await docRef.get();
  if (!snap.exists) return;
  final data = snap.data() ?? {};
  final ejercicios = List<Map<String, dynamic>>.from(
    (data['ejercicios'] as List<dynamic>? ?? []).map(
      (e) => Map<String, dynamic>.from(e as Map),
    ),
  );

  int targetIndex = -1;
  if (ejercicioIndex != null && ejercicioIndex >= 0 && ejercicioIndex < ejercicios.length) {
    targetIndex = ejercicioIndex;
  } else {
    final ejId = ejercicioActualizado['id'];
    if (ejId != null) {
      targetIndex = ejercicios.indexWhere((e) => e['id'] == ejId);
    }
  }

  if (targetIndex != -1) {
    ejercicios[targetIndex] = ejercicioActualizado;
    await docRef.update({'ejercicios': ejercicios});
  }
}

// ===================== CATÁLOGO DE EJERCICIOS =====================

/// Stream del catálogo compartido (todos los ejercicios disponibles).
Stream<List<Map<String, dynamic>>> streamCatalogoEjercicios() {
  return _db
      .collection('ejercicios')
      .orderBy('name')
      .snapshots()
      .map(
        (q) => q.docs.map((doc) {
          final data = doc.data();
          return {
            'id': doc.id,
            'name': data['name'] ?? '',
            'image': data['image'] ?? '',
            'tiempo': data['tiempo'] ?? '',
            'description': data['description'] ?? '',
            'finalizado': false,
          };
        }).toList(),
      );
}

/// Lista única (Future) del catálogo — útil para diálogos.
Future<List<Map<String, dynamic>>> getCatalogoEjercicios() async {
  final query = await _db.collection('ejercicios').orderBy('name').get();
  return query.docs.map((doc) {
    final data = doc.data();
    return {
      'id': doc.id,
      'name': data['name'] ?? '',
      'image': data['image'] ?? '',
      'tiempo': data['tiempo'] ?? '',
      'description': data['description'] ?? '',
      'finalizado': false,
    };
  }).toList();
}
