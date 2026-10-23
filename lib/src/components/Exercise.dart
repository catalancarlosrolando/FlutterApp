import 'package:flutter/material.dart';
import 'package:flutter_application/src/components/custom_image_loader.dart';
import 'package:flutter_application/src/components/iconText.dart';
import 'package:flutter_application/src/pages/exerciseLive_page.dart';

class Exercise extends StatelessWidget {
  final Map<String, dynamic> exercise;
  const Exercise({super.key, required this.exercise});

  void _goToLivePage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExerciseLivePage(exercise: exercise),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return InkWell(
      onTap: () => _goToLivePage(context),
      borderRadius: BorderRadius.circular(10.0),
      child: Ink(
        //margin: EdgeInsets.all(14),
        //height: 325.0,
        decoration: BoxDecoration(
          color: colors.surfaceContainer,
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(color: colors.outline),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: .start,
            children: [
              CustomImageLoader(imagePath: exercise['image']),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exercise['name'],
                    style: TextStyle(
                      color: colors.onSurface,
                      fontWeight: FontWeight.bold,
                      fontSize: 12.0,
                    ),
                  ),
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
            ],
          ),
        ),
      ),
    );
  }
}
