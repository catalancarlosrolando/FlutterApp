import 'package:flutter/material.dart';
import 'package:flutter_application/src/components/homepage/empty.dart';
import 'package:flutter_application/src/components/homepage/rutinaCard.dart';
import 'package:flutter_application/src/components/statistics/home_statistics_card.dart';
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
        late final Widget routineContent;
        if (snapshot.connectionState == ConnectionState.waiting) {
          routineContent = const SizedBox(
            height: 220,
            child: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          routineContent = Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'No se pudo cargar la próxima rutina.',
              textAlign: TextAlign.center,
              style: TextStyle(color: colors.error),
            ),
          );
        } else {
          final rutina = snapshot.data;
          routineContent = rutina == null
              ? const SizedBox(height: 220, child: EmptyState())
              : RutinaCard(
                  uid: uid,
                  profileId: profileId,
                  rutina: rutina,
                  colors: colors,
                );
        }

        return ListView(
          children: [
            routineContent,
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: HomeStatisticsCard(uid: uid, profileId: profileId),
            ),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }
}
