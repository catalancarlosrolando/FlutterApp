import 'package:flutter/material.dart';

/// Paleta de colores .
class AppColors {
  AppColors._();

  // ==========================================
  // Brand & Primarios
  // ==========================================
  static const Color primary = Color(0xFF111111);
  static const Color primaryActive = Color(0xFF242424);
  static const Color brandAccent = Color(0xFF3B82F6);

  // ==========================================
  // Superficies & Fondos (Light Mode)
  // ==========================================
  static const Color canvas = Color(0xFFFFFFFF);
  static const Color surfaceSoft = Color(0xFFF8F9FA);
  static const Color surfaceCard = Color(0xFFF5F5F5);
  static const Color surfaceStrong = Color(0xFFE5E7EB);

  // ==========================================
  // Superficies & Fondos (Dark Mode)
  // ==========================================
  static const Color surfaceDark = Color(0xFF101010);
  static const Color surfaceDarkElevated = Color(0xFF1A1A1A);
  static const Color surfaceDarkSubtle = Color(0xFF242427);
  static const Color surfaceDarkActive = Color(0xFF2E2E33);

  // ==========================================
  // Bordes & Líneas divisorias
  // ==========================================
  static const Color hairline = Color(0xFFE5E7EB);
  static const Color hairlineSoft = Color(0xFFF3F4F6);
  static const Color hairlineDark = Color(0xFF2E2E33);

  // ==========================================
  // Tipografía & Textos (Light Mode)
  // ==========================================
  static const Color ink = Color(0xFF111111);
  static const Color body = Color(0xFF374151);
  static const Color muted = Color(0xFF6B7280);
  static const Color mutedSoft = Color(0xFF898989);

  // ==========================================
  // Tipografía & Textos (Dark Mode / Sobre fondo oscuro)
  // ==========================================
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onDark = Color(0xFFFFFFFF);
  static const Color onDarkSoft = Color(0xFFA1A1AA);

  // ==========================================
  // Estados & Feedback
  // ==========================================
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);

  // ==========================================
  // Badges & Acentos (Light)
  // ==========================================
  static const Color badgeOrange = Color(0xFFFB923C);
  static const Color badgePink = Color(0xFFEC4899);
  static const Color badgeViolet = Color(0xFF8B5CF6);
  static const Color badgeEmerald = Color(0xFF34D399);

  // ==========================================
  // Badges & Acentos (Dark)
  // ==========================================
  static const Color darkBadgeBlue = Color(0xFF1E293B);
  static const Color darkBadgeIndigo = Color(0xFF1E1B4B);
  static const Color darkBadgeEmerald = Color(0xFF064E3B);
  static const Color darkBadgePurple = Color(0xFF2E1065);
}
