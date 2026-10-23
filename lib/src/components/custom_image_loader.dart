import 'package:flutter/material.dart';

/// Reusable image widget with loading frameBuilder and error handling
/// Implements the pattern documented in Docs_flutter/placeholderDeImagenes.md
class CustomImageLoader extends StatelessWidget {
  final String imagePath;
  final double? height;
  final double? width;
  final double borderRadius;
  final BoxFit fit;

  const CustomImageLoader({
    super.key,
    required this.imagePath,
    this.height = 130,
    this.width = 130,
    this.borderRadius = 8.0,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Image.asset(
        imagePath,
        height: height,
        width: width,
        fit: fit,
        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
          if (wasSynchronouslyLoaded || frame != null) {
            return child;
          }
          return Container(
            height: height,
            width: width,
            color: colors.surfaceContainerHigh,
            child: const Center(
              child: CircularProgressIndicator(strokeWidth: 2.0),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: height,
            width: width,
            color: colors.surfaceContainerHigh,
            child: Icon(
              Icons.broken_image,
              size: 40,
              color: colors.onSurfaceVariant,
            ),
          );
        },
      ),
    );
  }
}
