import 'package:flutter/material.dart';
import 'package:flutter_application/src/components/buttonWhiteRoutine.dart';
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
    return Container(
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
                placeholder: AssetImage("assets/images/load.gif"),
                image: AssetImage(image),
                fadeInDuration: Duration(seconds: 1),
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Row(
              mainAxisAlignment: .spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: .start,
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
                BotonWhiteRoutine(text: "Ver Rutina", iconEnable: true),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
