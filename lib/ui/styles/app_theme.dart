import 'package:flutter/material.dart';
import 'package:quiz_master/ui/styles/app_colors.dart';

// Uniformisation de la police Outfit pour l'ensemble du projet
const String _appFont = 'Outfit';

final theme = ThemeData.light(useMaterial3: true).copyWith(
  scaffoldBackgroundColor: AppColors.background,
  colorScheme:
      ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
      ).copyWith(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.surface,
        background: AppColors.background,
        onPrimary: AppColors.onPrimary,
        onSecondary: AppColors.onSecondary,
        onSurface: AppColors.onSurface,
      ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.transparent,
    elevation: 0,
    iconTheme: IconThemeData(color: AppColors.onSurface),
    titleTextStyle: TextStyle(
      fontFamily: _appFont, // Forcé sur l'AppBar
      color: AppColors.onSurface,
      fontSize: 20,
      fontWeight: FontWeight.w700,
    ),
  ),
  textTheme: ThemeData.light(useMaterial3: true).textTheme.apply(
    bodyColor: AppColors.onSurface,
    displayColor: AppColors.onSurface,
    fontFamily: _appFont, // Écrase la police de chaque variante du TextTheme
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.onPrimary,
      textStyle: const TextStyle(
        fontFamily: _appFont, // Forcé sur les boutons
        fontWeight: FontWeight.bold,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
    ),
  ),
);

final darkTheme = ThemeData.dark(useMaterial3: true).copyWith(
  scaffoldBackgroundColor: AppColors.backgroundDark,
  colorScheme:
      ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.dark,
      ).copyWith(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.surfaceDark,
        background: AppColors.backgroundDark,
        onPrimary: AppColors.onPrimary,
        onSecondary: AppColors.onSecondary,
        onSurface: AppColors.onSurfaceDark,
      ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.transparent,
    elevation: 0,
    iconTheme: IconThemeData(color: AppColors.onSurfaceDark),
    titleTextStyle: TextStyle(
      fontFamily: _appFont, // Forcé sur l'AppBar Dark
      color: AppColors.onSurfaceDark,
      fontSize: 20,
      fontWeight: FontWeight.w700,
    ),
  ),
  textTheme: ThemeData.dark(useMaterial3: true).textTheme.apply(
    bodyColor: AppColors.onSurfaceDark,
    displayColor: AppColors.onSurfaceDark,
    fontFamily: _appFont, // Écrase la police du TextTheme en mode sombre
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.onPrimary,
      textStyle: const TextStyle(
        fontFamily: _appFont, // Forcé sur les boutons Dark
        fontWeight: FontWeight.bold,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
    ),
  ),
);
