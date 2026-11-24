import 'package:flutter/material.dart';

// ============================================================================
//  Paleta 70-30-10
//
//  70%  #1A1B25  -> surface              (fondo dominante)
//  30%  #34364B  -> surfaceContainer     (superficies elevadas)
//  10%  #2563EB  -> primary              (acciones y elementos activos)
//  success #7EAD20 -> fuera del ColorScheme (M3 no define roles semánticos)
//
//  El tema claro invierte los neutros y mantiene el acento idéntico.
//  Todos los pares X/onX verificados WCAG (texto >= 4.5:1, outline >= 3:1).
// ============================================================================

// suface alternative: ECE4D4
// Surface alternative 2: F2F1EE
// CONTAINER E2DCEBN

const lightColorScheme = ColorScheme(
  brightness: Brightness.light,
  // ===== 10% — acento (idéntico en ambos modos) =====
  primary: Color(0xFF2563EB),
  onPrimary: Color(0xFFFFFFFF), // 5.17:1
  primaryContainer: Color(0xFFD6E3FF),
  onPrimaryContainer: Color(0xFF0B3B8C), // 8.07:1
  // Sin tercer matiz: secondary/tertiary repiten las familias
  // para no introducir colores nuevos que rompan la regla.
  secondary: Color(0xFF4B5675),
  onSecondary: Color(0xFFFFFFFF), // 7.27:1
  secondaryContainer: Color(0xFFE0E3F0),
  onSecondaryContainer: Color(0xFF262C40), // 10.82:1
  tertiary: Color(0xFF4B5675),
  onTertiary: Color(0xFFFFFFFF),
  tertiaryContainer: Color(0xFFE0E3F0),
  onTertiaryContainer: Color(0xFF262C40),
  error: Color(0xFFB3261E),
  onError: Color(0xFFFFFFFF),
  errorContainer: Color(0xFFF9DEDC),
  onErrorContainer: Color(0xFF410E0B),
  // ===== 70% — papel cálido #F2F1EE + contenedores blanco roto =====
  // La tinta también se calienta para acompañar al papel.
  surface: Color(0xFFF2F1EE),
  surfaceContainerHighest: Color(0xFFFEFEFD),
  surfaceContainerHigh: Color(0xFFFDFDFB),
  surfaceContainer: Color(0xFFFCFBF9), // 30%: blanco, pero no pleno
  onSurface: Color(0xFF1F1D1A), // 14.89:1
  onSurfaceVariant: Color(0xFF67635A), // 5.30:1 (5.79 sobre el 30%)
  outline: Color(0xFF8A857B), // 3.25:1
);

// ---------------------------------------------------------------------------
// Alternativa B — contenedores con toque de azul (dirección M3 clásica:
// las capas se oscurecen hacia surfaceContainerHighest, como en el oscuro).
// Si la preferís, reemplazá los valores del 70% por estos:
//
//   surface:                 Color(0xFFF2F1EE),  (igual)
//   surfaceContainer:        Color(0xFFE7EBF2),  30%
//   surfaceContainerHigh:    Color(0xFFDFE4EE),
//   surfaceContainerHighest: Color(0xFFD6DCE8),
//   onSurface:               Color(0xFF1A1C24),  15.05:1
//   onSurfaceVariant:        Color(0xFF5C6272),  5.40:1 (5.10 sobre el 30%)
//   outline:                 Color(0xFF7E869C),  3.22:1
// ---------------------------------------------------------------------------

const darkColorScheme = ColorScheme(
  brightness: Brightness.dark,
  // ===== 10% — acento =====
  primary: Color(0xFF2563EB),
  onPrimary: Color(0xFFFFFFFF), // 5.17:1 (el blanco pasa sobre #2563EB)
  primaryContainer: Color(0xFF1E3A8A),
  onPrimaryContainer: Color(0xFFD6E3FF), // 8.04:1
  // Sin tercer matiz; secondaryContainer reutiliza el 30%.
  secondary: Color(0xFFB4BDD4),
  onSecondary: Color(0xFF1F202B), // 8.59:1
  secondaryContainer: Color(0xFF34364B),
  onSecondaryContainer: Color(0xFFDDE0EA), // 8.97:1
  tertiary: Color(0xFFB4BDD4),
  onTertiary: Color(0xFF1F202B),
  tertiaryContainer: Color(0xFF34364B),
  onTertiaryContainer: Color(0xFFDDE0EA),
  error: Color(0xFFE69490),
  onError: Color(0xFF4C100D),
  errorContainer: Color(0xFF661511),
  onErrorContainer: Color(0xFFE6ACA9),
  // ===== 70% — fondo dominante =====
  surface: Color(0xFF1A1B25),
  surfaceContainerHighest: Color(0xFF474B63),
  surfaceContainerHigh: Color(0xFF3D4056),
  surfaceContainer: Color(0xFF34364B), // 30%
  onSurface: Color(0xFFE4E5EC), // 13.62:1
  onSurfaceVariant: Color(0xFFA2A6B8), // 7.07:1 (4.89:1 sobre el 30%)
  outline: Color(0xFF666A80), // 3.21:1
);

/// Acceso al tema y a los colores que ColorScheme no tiene.
///
///   context.colors.primary      -> 10%
///   context.colors.surface      -> 70%
///   context.colors.surfaceContainer -> 30%
///   context.success / context.onSuccess
extension ThemeX on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colors => theme.colorScheme;
  TextTheme get texts => theme.textTheme;

  /// Tinta para iconos/textos de estado exitoso.
  /// #7EAD20 sobre #1A1B25 da 6.42:1; sobre fondo claro se oscurece
  /// a #4E7011 (5.37:1), porque tal cual da 2.49:1.
  Color get success => theme.brightness == Brightness.dark
      ? const Color(0xFF7EAD20)
      : const Color(0xFF4E7011);

  /// Texto sobre un relleno success: el blanco falla sobre #7EAD20 (2.66:1),
  /// así que en oscuro la tinta es casi negra.
  Color get onSuccess => theme.brightness == Brightness.dark
      ? const Color(0xFF0F1600)
      : const Color(0xFFFFFFFF);
}

// Wiring (en tu main, donde ya alternás themeMode):
//
//   MaterialApp(
//     theme: ThemeData(
//       useMaterial3: true,
//       colorScheme: lightColorScheme,
//       scaffoldBackgroundColor: lightColorScheme.surface,
//     ),
//     darkTheme: ThemeData(
//       useMaterial3: true,
//       colorScheme: darkColorScheme,
//       scaffoldBackgroundColor: darkColorScheme.surface,
//     ),
//     themeMode: themeMode,
//     home: ...
//   )
