// firebase_services.dart — Patrón cátedra: funciones sueltas.
//
// Colecciones:
//   users/{uid}                                     → { displayName, email, defaultProfileId, ... }
//   users/{uid}/profiles/{profileId}                → { nombre, image, descripcion, createdAt }
//   users/{uid}/profiles/{profileId}/rutinas/{id}   → { categoria, name, description, image, tiempo, finalizada, ejercicios: [...] }
//   ejercicios/{id}                                 → { id, name, image (URL Cloudinary), tiempo, description }

import 'package:cloud_firestore/cloud_firestore.dart';

final FirebaseFirestore _db = FirebaseFirestore.instance;

// ===================== USUARIOS Y profiles =====================

/// Obtiene el defaultProfileId activo actual (Future).
Future<String?> getPerfilActivoId(String uid) async {
  final snap = await _db.collection('users').doc(uid).get();
  if (!snap.exists) return null;
  return snap.data()?['defaultProfileId'] as String?;
}

/// Stream reactivo del profileId activo del usuario.
Stream<String?> streamPerfilActivoId(String uid) {
  return _db.collection('users').doc(uid).snapshots().map((snap) {
    if (!snap.exists) return null;
    return snap.data()?['defaultProfileId'] as String?;
  });
}

/// Stream con la lista de todos los profiles creados por el usuario.
Stream<List<Map<String, dynamic>>> streamprofiles(String uid) {
  return _db
      .collection('users')
      .doc(uid)
      .collection('profiles')
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
  final ref = await _db.collection('users').doc(uid).collection('profiles').add(
    {
      'name': nombrePerfil,
      'image': image,
      'descripcion': descripcion,
      'createdAt': FieldValue.serverTimestamp(),
    },
  );
  return ref.id;
}

/// Obtiene los datos del perfil activo.
Future<Map<String, dynamic>?> getPerfil(String uid, String profileId) async {
  final snap = await _db
      .collection('users')
      .doc(uid)
      .collection('profiles')
      .doc(profileId)
      .get();
  if (!snap.exists) return null;
  return {'id': snap.id, ...snap.data()!};
}

/// Stream de los datos del perfil activo en tiempo real.
Stream<Map<String, dynamic>?> streamPerfil(String uid, String profileId) {
  return _db
      .collection('users')
      .doc(uid)
      .collection('profiles')
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
      .collection('users')
      .doc(uid)
      .collection('profiles')
      .doc(profileId)
      .set({
        'name': nombre,
        'image': image,
        'descripcion': descripcion,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
}

/// Cambia el perfil activo del usuario.
Future<void> cambiarPerfilActivo(String uid, String profileId) async {
  await _db.collection('users').doc(uid).update({
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
      .collection('users')
      .doc(uid)
      .collection('profiles')
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
          final cat = data['category'] ?? 'push';
          out.putIfAbsent(cat, () => []);
          out[cat]!.add(_rutinaFromDoc(doc));
        }
        return out;
      });
}

/// Stream reactivo de TODAS las rutinas del perfil (lista plana).
Stream<List<Map<String, dynamic>>> streamRutinas(String uid, String profileId) {
  return _db
      .collection('users')
      .doc(uid)
      .collection('profiles')
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
      .collection('users')
      .doc(uid)
      .collection('profiles')
      .doc(profileId)
      .collection('rutinas')
      .where('completed', isEqualTo: false)
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
      .collection('users')
      .doc(uid)
      .collection('profiles')
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
    'category': data['category'] ?? 'push',
    'name': data['name'] ?? '',
    'description': data['description'] ?? '',
    'image': data['image'] ?? '',
    'time': data['time'] ?? '',
    'completed': data['completed'] ?? false,
    'exercises': data['exercises'] ?? [],
  };
}

// ===================== RUTINAS — ESCRITURA =====================

/// Crea una rutina con ejercicios dentro del perfil activo.
Future<String> addRutina({
  required String uid,
  required String profileId,
  required String category,
  required String name,
  required String description,
  required String image,
  required String time,
  List<Map<String, dynamic>> ejercicios = const [],
}) async {
  final ref = await _db
      .collection('users')
      .doc(uid)
      .collection('profiles')
      .doc(profileId)
      .collection('rutinas')
      .add({
        'category': category,
        'name': name,
        'description': description,
        'image': image,
        'time': time,
        'completed': false,
        'exercises': ejercicios,
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
  required String time,
  String? categoria,
  String? image,
  List<Map<String, dynamic>>? exercises,
}) async {
  final Map<String, dynamic> data = {
    'name': name,
    'description': description,
    'time': time,
    'updatedAt': FieldValue.serverTimestamp(),
  };
  if (categoria != null) data['category'] = categoria;
  if (image != null) data['image'] = image;
  if (exercises != null) data['exercises'] = exercises;

  await _db
      .collection('users')
      .doc(uid)
      .collection('profiles')
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
      .collection('users')
      .doc(uid)
      .collection('profiles')
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
      .collection('users')
      .doc(uid)
      .collection('profiles')
      .doc(profileId)
      .collection('rutinas')
      .doc(uidDoc)
      .update({'completed': finalizada});
}

/// Resetea una rutina: la marca como no finalizada y pone todos sus
/// ejercicios con [finalizado: false].
Future<void> resetRutina({
  required String uid,
  required String profileId,
  required String uidDoc,
}) async {
  final docRef = _db
      .collection('users')
      .doc(uid)
      .collection('profiles')
      .doc(profileId)
      .collection('rutinas')
      .doc(uidDoc);

  final snap = await docRef.get();
  if (!snap.exists) return;

  final data = snap.data() ?? {};
  final exercises = List<Map<String, dynamic>>.from(
    (data['exercises'] as List<dynamic>? ?? []).map(
      (e) => Map<String, dynamic>.from(e as Map)..['finalizado'] = false,
    ),
  );

  await docRef.update({'completed': false, 'exercises': exercises});
}

/// Verifica si todos los ejercicios de la rutina están finalizados y,
/// en ese caso, marca la rutina como finalizada automáticamente.
Future<void> checkAndFinalizarRutina({
  required String uid,
  required String profileId,
  required String rutinaId,
}) async {
  final docRef = _db
      .collection('users')
      .doc(uid)
      .collection('profiles')
      .doc(profileId)
      .collection('rutinas')
      .doc(rutinaId);

  final snap = await docRef.get();
  if (!snap.exists) return;

  final data = snap.data() ?? {};
  final exercises = List<dynamic>.from(data['exercises'] ?? []);

  if (exercises.isEmpty) return;

  final allDone = exercises.every((e) => (e as Map)['completed'] == true);

  if (allDone) {
    await docRef.update({'completed': true});
  }
}

// ===================== EJERCICIOS DE UNA RUTINA =====================

/// Stream reactivo de los ejercicios de una rutina del perfil.
Stream<List<Map<String, dynamic>>> streamEjerciciosDeRutina({
  required String uid,
  required String profileId,
  required String rutinaId,
}) {
  return _db
      .collection('users')
      .doc(uid)
      .collection('profiles')
      .doc(profileId)
      .collection('rutinas')
      .doc(rutinaId)
      .snapshots()
      .map((doc) {
        if (!doc.exists) return <Map<String, dynamic>>[];
        final data = doc.data() as Map<String, dynamic>;
        return List<Map<String, dynamic>>.from(data['exercises'] ?? []);
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
      .collection('users')
      .doc(uid)
      .collection('profiles')
      .doc(profileId)
      .collection('rutinas')
      .doc(rutinaId)
      .update({
        'exercises': FieldValue.arrayUnion([ejercicio]),
      });
}

Future<void> borrarEjercicioDeRutina({
  required String uid,
  required String profileId,
  required String rutinaId,
  required String ejercicioId,
}) async {
  final docRef = _db
      .collection('users')
      .doc(uid)
      .collection('profiles')
      .doc(profileId)
      .collection('rutinas')
      .doc(rutinaId);
  final snap = await docRef.get();
  final data = snap.data() ?? {};
  final ejercicios = List.from(data['exercises'] ?? []);
  ejercicios.removeWhere((e) => e['id'] == ejercicioId);
  await docRef.update({'exercises': ejercicios});
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
      .collection('users')
      .doc(uid)
      .collection('profiles')
      .doc(profileId)
      .collection('rutinas')
      .doc(rutinaId);
  final snap = await docRef.get();
  if (!snap.exists) return;
  final data = snap.data() ?? {};
  final ejercicios = List<Map<String, dynamic>>.from(
    (data['exercises'] as List<dynamic>? ?? []).map(
      (e) => Map<String, dynamic>.from(e as Map),
    ),
  );

  int targetIndex = -1;
  if (ejercicioIndex != null &&
      ejercicioIndex >= 0 &&
      ejercicioIndex < ejercicios.length) {
    targetIndex = ejercicioIndex;
  } else {
    final ejId = ejercicioActualizado['id'];
    if (ejId != null) {
      targetIndex = ejercicios.indexWhere((e) => e['id'] == ejId);
    }
  }

  if (targetIndex != -1) {
    ejercicios[targetIndex] = ejercicioActualizado;
    await docRef.update({'exercises': ejercicios});
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
            'time': data['tiempo'] ?? '',
            'description': data['description'] ?? '',
            'completed': false,
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
      'time': data['time'] ?? '',
      'description': data['description'] ?? '',
      'completed': false,
    };
  }).toList();
}

// ===================== HISTORIAL DE SESIONES =====================

/// Guarda el registro de una sesión de entrenamiento completada o finalizada
/// en la subcolección `users/{uid}/profiles/{profileId}/historial`.
Future<String> guardarHistorialSesion({
  required String uid,
  required String profileId,
  required Map<String, dynamic> sesion,
}) async {
  final ref = await _db
      .collection('users')
      .doc(uid)
      .collection('profiles')
      .doc(profileId)
      .collection('historial')
      .add({...sesion, 'createdAt': FieldValue.serverTimestamp()});
  return ref.id;
}

/// Stream reactivo del historial de sesiones de un perfil, ordenado por fecha descendente.
Stream<List<Map<String, dynamic>>> streamHistorialSesiones({
  required String uid,
  required String profileId,
}) {
  return _db
      .collection('users')
      .doc(uid)
      .collection('profiles')
      .doc(profileId)
      .collection('historial')
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((q) => q.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList());
}
