import 'package:flutter/material.dart';

class EjercicioPreviewImage extends StatelessWidget {
  final String? imageUrl;
  final String? title;

  const EjercicioPreviewImage({super.key, required this.imageUrl, this.title});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            imageUrl!,
            width: double.infinity,
            height: 280,
            fit: BoxFit.fill,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) {
                return child;
              }
              return Container(
                width: double.infinity,
                height: 280,
                color: colors.surfaceContainerHigh,
                child: Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                        : null,
                  ),
                ),
              );
            },
            errorBuilder: (_, _, _) => Container(
              width: double.infinity,
              height: 180,
              color: colors.surfaceContainerHigh,
              child: Icon(
                Icons.broken_image,
                size: 60,
                color: colors.onSurfaceVariant,
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      height: 140,
      decoration: BoxDecoration(
        color: colors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.qr_code_2, size: 44, color: colors.onSurfaceVariant),
          const SizedBox(height: 8),
          Text(
            title?.isNotEmpty == true ? title! : 'Vista Previa',
            textAlign: TextAlign.center,
            style: TextStyle(color: colors.onSurfaceVariant, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
