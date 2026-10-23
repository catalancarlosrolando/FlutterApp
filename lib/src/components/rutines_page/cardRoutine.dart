import 'package:flutter/material.dart';

import 'package:flutter_application/src/components/custom_image_loader.dart';
import 'package:flutter_application/src/components/iconText.dart';

class CardRoutine extends StatelessWidget {
  final String rutinaName;
  final String descripcion;
  final String image;
  final String time;
  final String exercisesCount;
  final VoidCallback onTap;

  const CardRoutine({
    super.key,
    required this.rutinaName,
    required this.descripcion,
    required this.time,
    required this.exercisesCount,
    required this.image,
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
          border: Border.all(color: colors.outline),
        ),
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: .start,
            children: [
              CustomImageLoader(imagePath: image),
              SizedBox(
                width: 180,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 8,
                  children: [
                    Text(
                      rutinaName,
                      style: TextStyle(
                        color: colors.onSurface,
                        fontWeight: FontWeight.bold,
                        fontSize: 12.0,
                      ),
                    ),
                    Text(
                      descripcion,
                      style: TextStyle(
                        color: colors.onSurface,
                        fontWeight: FontWeight.normal,
                        fontSize: 12.0,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 8,
                children: [IconText(icon: Icons.timer, text: time)],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
