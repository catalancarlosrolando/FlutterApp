import 'package:flutter/material.dart';
import 'package:flutter_application/src/components/custom_image_loader.dart';
import 'package:flutter_application/src/components/exercise_live/exercise_preview_card.dart';

/// Expandable card displaying exercise details and image (utilizing CustomImageLoader)
class ExerciseDetailsExpansionCard extends StatefulWidget {
  final String estimatedTime;
  final String? imagePath;
  final String? description;

  const ExerciseDetailsExpansionCard({
    super.key,
    required this.estimatedTime,
    this.imagePath,
    this.description,
  });

  @override
  State<ExerciseDetailsExpansionCard> createState() =>
      _ExerciseDetailsExpansionCardState();
}

class _ExerciseDetailsExpansionCardState
    extends State<ExerciseDetailsExpansionCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ExercisePreviewCard(
          title: 'Detalles e Instrucciones',
          subtitle: 'Duración estimada: ${widget.estimatedTime}',
          isExpanded: _isExpanded,
          onTap: () {
            setState(() {
              _isExpanded = !_isExpanded;
            });
          },
        ),
        if (_isExpanded) ...[
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: colors.surfaceContainer,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colors.outlineVariant, width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.imagePath != null && widget.imagePath!.isNotEmpty) ...[
                  CustomImageLoader(
                    imagePath: widget.imagePath!,
                    height: 150,
                    borderRadius: 8.0,
                  ),
                  const SizedBox(height: 12),
                ],
                Text(
                  'Descripción:',
                  style: TextStyle(
                    color: colors.onSurface,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.description ?? 'Sin descripción adicional.',
                  style: TextStyle(
                    color: colors.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
