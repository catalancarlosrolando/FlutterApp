import 'package:flutter/material.dart';
import 'package:flutter_application/src/components/rutines_page/buttonWhiteRoutine.dart';
import 'package:flutter_application/src/components/custom_image_loader.dart';
import 'package:flutter_application/src/components/iconText.dart';

class CardRoutine extends StatelessWidget {
  final String rutinaName;
  final String descripcion;
  final String image;
  final VoidCallback onTap;

  const CardRoutine({
    super.key,
    required this.rutinaName,
    required this.descripcion,
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
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 16,
            children: [
              CustomImageLoader(imagePath: image),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        rutinaName,
                        style: TextStyle(
                          color: colors.onSurface,
                          fontWeight: FontWeight.bold,
                          fontSize: 12.0,
                        ),
                      ),
                      IconText(icon: Icons.timer, text: descripcion),
                    ],
                  ),
                  BotonWhiteRoutine(
                    text: "Ver Rutina",
                    iconEnable: true,
                    onTap: onTap,
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
