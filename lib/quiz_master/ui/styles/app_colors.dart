import 'package:flutter/material.dart';

class AppColors {
  // ==================== LIGHT THEME ====================
  static const background = Color(0xFFF9F9FF);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceVariant = Color(0xFFD8E3FB);
  static const surfaceContainer = Color(0xFFE7EEFF);
  static const surfaceContainerLow = Color(0xFFF0F3FF);
  static const surfaceContainerHigh = Color(0xFFDEE8FF);
  static const surfaceContainerHighest = Color(0xFFD8E3FB);

  static const primary = Color(0xFF4648D4);
  static const primaryContainer = Color(0xFF6063EE);
  static const accent = Color(0xFF4648D4);
  static const accentLight = Color(0xFF6063EE);

  static const secondary = Color(0xFF735C00);
  static const secondaryContainer = Color(0xFFFED01B);
  static const tertiary = Color(0xFF007DA9);

  static const onSurface = Color(0xFF111C2D);
  static const onSurfaceVariant = Color(0xFF464554);
  static const onPrimary = Color(0xFFFFFFFF);
  static const onSecondary = Color(0xFFFFFFFF);

  static const outline = Color(0xFF767586);
  static const outlineVariant = Color(0xFFC7C4D7);

  // ==================== DARK THEME (Ajouts) ====================
  static const backgroundDark = Color(
    0xFF0E1624,
  ); // Bleu nuit encore plus profond pour le fond
  static const surfaceDark = Color(
    0xFF162235,
  ); // Surfaces des cartes surélevées
  static const surfaceVariantDark = Color(0xFF233149);

  // Containers sombres étagés
  static const surfaceContainerLowDark = Color(0xFF121D2F);
  static const surfaceContainerDark = Color(0xFF1A293E);
  static const surfaceContainerHighDark = Color(0xFF22354F);
  static const surfaceContainerHighestDark = Color(0xFF2B4161);

  // Adaptation des contrastes pour le mode sombre
  static const primaryContainerDark = Color(0xFF3234A8);
  static const secondaryContainerDark = Color(
    0xFF4E3E00,
  ); // Version tamisée du jaune pour les fonds

  static const onSurfaceDark = Color(0xFFF0F3FF); // Texte principal clair
  static const onSurfaceVariantDark = Color(
    0xFF94A3B8,
  ); // Texte secondaire discret
  static const onSecondaryContainerDark = Color(
    0xFFFFE083,
  ); // Texte sur fond jaune sombre

  static const outlineDark = Color(0xFF475569);
  static const outlineVariantDark = Color(0xFF334155);

  // ==================== UTILS ====================
  static const success = Color(0xFF22C55E);
  static const error = Color(0xFFBA1A1A);
}
