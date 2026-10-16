import 'package:flutter/material.dart';
import 'package:flutter_application/src/components/iconText.dart';

class Exercise extends StatelessWidget {
  final Map<String, dynamic> exercise;
  final VoidCallback onTap;
  const Exercise({super.key, required this.exercise, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 16,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10.0),

                child: FadeInImage(
                  placeholder: const AssetImage("assets/images/load.gif"),
                  image: AssetImage(exercise['image']),
                  fadeInDuration: const Duration(seconds: 1),
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
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
                      IconText(
                        icon: Icons.loop,
                        text: "${exercise['reps']} reps",
                      ),
                      IconText(icon: Icons.add, text: "${exercise['peso']} "),
                      IconText(
                        icon: Icons.timer,
                        text: "Descanso: ${exercise['descanso']} ",
                      ),
                    ],
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
