import 'package:flutter/material.dart';
import 'package:flutter_application/src/components/homepage/empty.dart';
import 'package:flutter_application/src/components/homepage/rutinaCard.dart';
import 'package:flutter_application/src/services/firebase_services.dart';

// ======================================================
// PRÓXIMA RUTINA: STREAM INDEPENDIENTE
// ======================================================

class ProximaRutina extends StatelessWidget {
  final String uid;
  final String profileId;
  final ColorScheme colors;

  const ProximaRutina({
    super.key,
    required this.uid,
    required this.profileId,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map<String, dynamic>?>(
      stream: streamProximaRutina(uid, profileId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'Error: ${snapshot.error}',
                textAlign: TextAlign.center,
                style: TextStyle(color: colors.error),
              ),
            ),
          );
        }

        final rutina = snapshot.data;

        if (rutina == null) {
          return EmptyState();
        }

        return RutinaCard(
          uid: uid,
          profileId: profileId,
          rutina: rutina,
          colors: colors,
        );
      },
    );
  }
}
