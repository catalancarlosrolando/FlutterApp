// firebase_services.dart — Patrón cátedra: funciones sueltas.
//
// Colecciones:
//   usuarios/{uid}     → { nombre, email, rutinas: [ids] }
//   rutinas/{id}       → { uid, categoria, name, description, image, tiempo,
//                         finalizada: bool, ejercicios: [...] }
//   ejercicios/{id}    → { id, name, image (URL Cloudinary), tiempo, description }

import 'package:cloud_firestore/cloud_firestore.dart';

// ===================== USUARIOS =====================

/// Crea el documento del usuario al iniciar sesión con Google por primera vez.
/// Usa el uid de Firebase Auth como id del documento.
Future<void> crearUsuario({
  required String uid,
  required String email,
  required String nombre,
  String photoUrl = '',
}) async {
  final ref = FirebaseFirestore.instance.collection('usuarios').doc(uid);
  final snap = await ref.get();
  if (!snap.exists) {
    await ref.set({
      'nombre': nombre,
      'email': email,
      'photoUrl': photoUrl,
      'rutinas': [], // arranca con ninguna
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}

/// Agrega el id de una rutina al array `rutinas` del usuario.
Future<void> agregarRutinaAUsuario(String uid, String rutinaId) async {
  await FirebaseFirestore.instance.collection('usuarios').doc(uid).update({
    'rutinas': FieldValue.arrayUnion([rutinaId]),
  });
}

/// Quita el id de una rutina del array del usuario.
Future<void> quitarRutinaDeUsuario(String uid, String rutinaId) async {
  await FirebaseFirestore.instance.collection('usuarios').doc(uid).update({
    'rutinas': FieldValue.arrayRemove([rutinaId]),
  });
}

// ===================== RUTINAS — STREAMS =====================

/// Stream reactivo de las rutinas del usuario, agrupadas por categoría.
/// Devuelve un map: { 'push': [...], 'pull': [...], 'legs': [...], 'core': [...] }
Stream<Map<String, List>> streamRutinasPorCategoria(String uid) {
  return FirebaseFirestore.instance
      .collection('rutinas')
      .where('uid', isEqualTo: uid)
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

/// Stream reactivo de TODAS las rutinas del usuario (lista plana).
Stream<List<Map<String, dynamic>>> streamRutinas(String uid) {
  return FirebaseFirestore.instance
      .collection('rutinas')
      .where('uid', isEqualTo: uid)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((q) => q.docs.map(_rutinaFromDoc).toList());
}

/// Stream de la próxima rutina NO finalizada del usuario.
/// Devuelve null si todas están finalizadas o si no hay rutinas.
/// Útil para mostrar "la rutina siguiente" en la home.
Stream<Map<String, dynamic>?> streamProximaRutina(String uid) {
  return FirebaseFirestore.instance
      .collection('rutinas')
      .where('uid', isEqualTo: uid)
      .where('finalizada', isEqualTo: false)
      .orderBy('createdAt')
      .limit(1)
      .snapshots()
      .map((q) => q.docs.isEmpty ? null : _rutinaFromDoc(q.docs.first));
}

Map<String, dynamic> _rutinaFromDoc(DocumentSnapshot doc) {
  final data = doc.data() as Map<String, dynamic>;
  return {
    'uid_doc': doc.id,
    'uid': data['uid'] ?? '',
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

/// Crea una rutina con los ejercicios ya configurados (o vacía) y la asocia al usuario.
/// Devuelve el id del doc creado.
Future<String> addRutina({
  required String uid,
  required String categoria,
  required String name,
  required String description,
  required String image,
  required String tiempo,
  List<Map<String, dynamic>> ejercicios = const [],
}) async {
  final ref = await FirebaseFirestore.instance.collection('rutinas').add({
    'uid': uid,
    'categoria': categoria,
    'name': name,
    'description': description,
    'image': image,
    'tiempo': tiempo,
    'finalizada': false, // NUEVO CAMPO
    'ejercicios': ejercicios,
    'createdAt': FieldValue.serverTimestamp(),
  });
  await agregarRutinaAUsuario(uid, ref.id);
  return ref.id;
}

Future<void> updateRutina({
  required String uidDoc,
  required String name,
  required String description,
  required String tiempo,
}) async {
  await FirebaseFirestore.instance.collection('rutinas').doc(uidDoc).set({
    'name': name,
    'description': description,
    'tiempo': tiempo,
  }, SetOptions(merge: true));
}

Future<void> borrarRutina(String uid, String uidDoc) async {
  await FirebaseFirestore.instance.collection('rutinas').doc(uidDoc).delete();
  await quitarRutinaDeUsuario(uid, uidDoc);
}

/// Marca (o desmarca) una rutina como finalizada.
Future<void> setRutinaFinalizada(String uidDoc, bool finalizada) async {
  await FirebaseFirestore.instance.collection('rutinas').doc(uidDoc).update({
    'finalizada': finalizada,
  });
}

// ===================== EJERCICIOS DE UNA RUTINA =====================

/// Stream reactivo de los ejercicios de una rutina (como array del doc).
Stream<List<Map<String, dynamic>>> streamEjerciciosDeRutina(String rutinaId) {
  return FirebaseFirestore.instance
      .collection('rutinas')
      .doc(rutinaId)
      .snapshots()
      .map((doc) {
        if (!doc.exists) return <Map<String, dynamic>>[];
        final data = doc.data() as Map<String, dynamic>;
        return List<Map<String, dynamic>>.from(data['ejercicios'] ?? []);
      });
}

/// Añade un ejercicio (ya con series/reps/peso/descanso definidos) al array
/// `ejercicios` de la rutina.
Future<void> addEjercicioARutina({
  required String rutinaId,
  required Map<String, dynamic> ejercicio,
}) async {
  await FirebaseFirestore.instance.collection('rutinas').doc(rutinaId).update({
    'ejercicios': FieldValue.arrayUnion([ejercicio]),
  });
}

Future<void> borrarEjercicioDeRutina(
  String rutinaId,
  String ejercicioId,
) async {
  final docRef = FirebaseFirestore.instance.collection('rutinas').doc(rutinaId);
  final snap = await docRef.get();
  final data = snap.data() ?? {};
  final ejercicios = List.from(data['ejercicios'] ?? []);
  ejercicios.removeWhere((e) => e['id'] == ejercicioId);
  await docRef.update({'ejercicios': ejercicios});
}

// ===================== CATÁLOGO DE EJERCICIOS =====================

/// Stream del catálogo compartido (todos los ejercicios disponibles).
Stream<List<Map<String, dynamic>>> streamCatalogoEjercicios() {
  return FirebaseFirestore.instance
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
          };
        }).toList(),
      );
}

/// Lista única (Future) del catálogo — útil para diálogos.
Future<List<Map<String, dynamic>>> getCatalogoEjercicios() async {
  final query = await FirebaseFirestore.instance
      .collection('ejercicios')
      .orderBy('name')
      .get();
  return query.docs.map((doc) {
    final data = doc.data();
    return {
      'id': doc.id,
      'name': data['name'] ?? '',
      'image': data['image'] ?? '',
      'tiempo': data['tiempo'] ?? '',
      'description': data['description'] ?? '',
    };
  }).toList();
}
