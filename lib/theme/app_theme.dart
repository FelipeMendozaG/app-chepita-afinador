import 'package:flutter/material.dart';

class AppTheme {
  // Colores principales de la paleta Dark Acústica
  static const Color background = Color(0xFF0B1017);
  static const Color surface = Color(0xFF141D28);
  static const Color surfaceContainer = Color(0xFF1C2837);
  static const Color surfaceHighlight = Color(0xFF243447);
  static const Color border = Color(0xFF293B52);

  // Colores de afinación y acentos
  static const Color tuned = Color(0xFF00E676);       // Afinada (Verde Esmeralda Neón)
  static const Color tunedGlow = Color(0x5500E676);
  static const Color flat = Color(0xFFFFB300);        // Muy baja (Ámbar)
  static const Color flatGlow = Color(0x44FFB300);
  static const Color sharp = Color(0xFFFF5252);       // Muy alta (Rojo Coral)
  static const Color sharpGlow = Color(0x44FF5252);
  static const Color idle = Color(0xFF64748B);         // En reposo / Silencio

  // Tipografía y textos
  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      primaryColor: tuned,
      colorScheme: const ColorScheme.dark(
        primary: tuned,
        surface: surface,
        onSurface: textPrimary,
      ),
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
        iconTheme: IconThemeData(color: textPrimary),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: border, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }
}
