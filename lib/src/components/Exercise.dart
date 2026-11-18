import 'package:flutter/material.dart';
import 'package:flutter_application/src/components/custom_image_loader.dart';
import 'package:flutter_application/src/components/iconText.dart';
import 'package:flutter_application/src/pages/exerciseLive_page.dart';

class Exercise extends StatelessWidget {
  final Map<String, dynamic> exercise;
  final String? uid;
  final String? profileId;
  final String? rutinaId;
  final int? exerciseIndex;

  const Exercise({
    super.key,
    required this.exercise,
    this.uid,
    this.profileId,
    this.rutinaId,
    this.exerciseIndex,
  });

  void _goToLivePage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExerciseLivePage(
          exercise: exercise,
          uid: uid,
          profileId: profileId,
          rutinaId: rutinaId,
          exerciseIndex: exerciseIndex,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isFinalizado = exercise['finalizado'] == true;

    return InkWell(
      onTap: () => _goToLivePage(context),
      borderRadius: BorderRadius.circular(10.0),
      child: Ink(
        decoration: BoxDecoration(
          color: colors.surfaceContainer,
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(
            color: isFinalizado ? Colors.green : colors.outline,
            width: isFinalizado ? 2 : 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomImageLoader(imagePath: exercise['image']),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              exercise['name'] ?? '',
                              style: TextStyle(
                                color: colors.onSurface,
                                fontWeight: FontWeight.bold,
                                fontSize: 13.0,
                              ),
                            ),
                          ),
                          if (isFinalizado)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green.withAlpha(40),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.green, width: 1),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.check_circle, color: Colors.green, size: 14),
                                  SizedBox(width: 4),
                                  Text(
                                    'Completado',
                                    style: TextStyle(
                                      color: Colors.green,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      IconText(
                        icon: Icons.timer,
                        text: "${exercise['series']} series",
                      ),
                      IconText(icon: Icons.loop, text: "${exercise['reps']} reps"),
                      IconText(icon: Icons.add, text: "${exercise['peso']} "),
                      IconText(
                        icon: Icons.timer,
                        text: "Descanso: ${exercise['descanso']} ",
                      ),
                    ],
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
