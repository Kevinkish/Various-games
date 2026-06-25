import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quiz_master/ui/styles/app_colors.dart';

// --- THÈME CLAIR ---
final theme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  scaffoldBackgroundColor: AppColors.background,

  // Configuration du ColorScheme
  colorScheme:
      ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
      ).copyWith(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.surface,
        onPrimary: AppColors.onPrimary,
        onSecondary: AppColors.onSecondary,
        onSurface: AppColors.onSurface,
      ),

  // Application globale de la police Outfit sur le texte de base
  textTheme: GoogleFonts.outfitTextTheme(
    ThemeData.light(useMaterial3: true).textTheme,
  ).apply(bodyColor: AppColors.onSurface, displayColor: AppColors.onSurface),

  // Configuration de l'AppBar
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.transparent,
    elevation: 0,
    iconTheme: IconThemeData(color: AppColors.onSurface),
    titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
  ),

  // Configuration des boutons (Le style hérite automatiquement d'Outfit)
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.onPrimary,
      textStyle: const TextStyle(fontWeight: FontWeight.bold),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
    ),
  ),
);

// --- THÈME SOMBRE ---
final darkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark, // Corrigé ici (était .light dans ton code)
  scaffoldBackgroundColor: AppColors.backgroundDark,

  // Configuration du ColorScheme Dark
  colorScheme:
      ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.dark,
      ).copyWith(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.surfaceDark,
        onPrimary: AppColors.onPrimary,
        onSecondary: AppColors.onSecondary,
        onSurface: AppColors.onSurfaceDark,
      ),

  // Application globale de la police Outfit sur le texte sombre
  textTheme:
      GoogleFonts.outfitTextTheme(
        ThemeData.dark(useMaterial3: true).textTheme,
      ).apply(
        bodyColor: AppColors.onSurfaceDark,
        displayColor: AppColors.onSurfaceDark,
      ),

  // Configuration de l'AppBar Dark
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.transparent,
    elevation: 0,
    iconTheme: IconThemeData(color: AppColors.onSurfaceDark),
    titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
  ),

  // Configuration des boutons Dark
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.onPrimary,
      textStyle: const TextStyle(fontWeight: FontWeight.bold),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
    ),
  ),
);
