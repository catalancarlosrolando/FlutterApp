import 'package:flutter/material.dart';
import 'package:flutter_application/src/pages/routine_details_page.dart';

class RutinaCard extends StatelessWidget {
  final String uid;
  final String profileId;
  final Map<String, dynamic> rutina;
  final ColorScheme colors;

  const RutinaCard({
    super.key,
    required this.uid,
    required this.profileId,
    required this.rutina,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    final ejercicios = List.from(rutina['exercises'] ?? []);
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header de la rutina clickeable
          InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RoutineDetails(
                    rutina: rutina,
                    uid: uid,
                    profileId: profileId,
                  ),
                ),
              );
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    children: [
                      (rutina['image'] as String).isNotEmpty
                          ? Image.network(
                              rutina['image'],
                              width: double.infinity,
                              height: 180,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => Container(
                                width: double.infinity,
                                height: 180,
                                color: colors.surfaceContainerHigh,
                                child: Icon(
                                  Icons.fitness_center,
                                  size: 60,
                                  color: colors.onSurfaceVariant,
                                ),
                              ),
                            )
                          : Container(
                              width: double.infinity,
                              height: 180,
                              color: colors.surfaceContainerHigh,
                              child: Icon(
                                Icons.fitness_center,
                                size: 60,
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                      Positioned(
                        top: 12,
                        left: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: colors.primary,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            (rutina['category'] ?? 'nada')
                                .toString()
                                .toUpperCase(),
                            style: TextStyle(
                              color: colors.onPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        rutina['name'] ?? '',
                        style: TextStyle(
                          color: colors.onSurface,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 18,
                      color: colors.onSurfaceVariant,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${rutina['time']} · ${ejercicios.length} ejercicios · Ver detalles',
                  style: TextStyle(color: colors.primary, fontSize: 14),
                ),
                const SizedBox(height: 12),
                if ((rutina['description'] as String).isNotEmpty)
                  Text(
                    rutina['description'],
                    style: TextStyle(color: colors.onSurface, fontSize: 14),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
