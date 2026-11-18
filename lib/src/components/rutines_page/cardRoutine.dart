import 'package:flutter/material.dart';

import 'package:flutter_application/src/components/custom_image_loader.dart';
import 'package:flutter_application/src/components/iconText.dart';
import 'package:flutter_application/src/components/text_card.dart';

class CardRoutine extends StatelessWidget {
  final String rutinaName;
  final String descripcion;
  final String image;
  final String time;
  final String exercisesCount;
  final bool finalizada;
  final VoidCallback onTap;

  const CardRoutine({
    super.key,
    required this.rutinaName,
    required this.descripcion,
    required this.time,
    required this.exercisesCount,
    required this.image,
    this.finalizada = false,
    required this.onTap,
  });

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
          border: Border.all(
            color: finalizada ? Colors.green : colors.outline,
            width: finalizada ? 1.5 : 1.0,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Row(
            spacing: 10,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: .start,
            children: [
              Stack(
                children: [
                  CustomImageLoader(imagePath: image),
                  if (finalizada)
                    Positioned(
                      top: 4,
                      right: 4,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                ],
              ),
              Flexible(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 8,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextCard(
                            text: rutinaName,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (finalizada)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.withAlpha(40),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'Realizada',
                              style: TextStyle(
                                color: Colors.green,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    TextCard(text: descripcion),
                  ],
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.end,
                spacing: 8,
                children: [
                  IconText(icon: Icons.timer, text: time),
                  TextCard(text: "$exercisesCount ejercicios"),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
