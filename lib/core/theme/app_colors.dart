import 'package:flutter/material.dart';

class AppColors {
  // --- Primary Brand Colors ---
  static const Color primaryPurple = Color(0xFF6366F1); // Indigo-Indigo (M3)
  static const Color primaryBlue = Color(0xFF3B82F6);
  static const Color primaryTeal = Color(0xFF0D9488);
  static const Color primary = primaryPurple;
  static const Color onPrimary = Colors.white;
  static const Color primaryLight = Color(0xFFE0E7FF); // Indigo-50

  // --- Background Colors ---
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color backgroundDark = Color(0xFF0F172A);
  static const Color surface = Colors.white;
  static const Color surfaceDark = Color(0xFF1E293B);
  static const Color onSurface = Color(0xFF334155);
  static const Color onSurfaceDark = Colors.white;
  static const Color background = backgroundLight;
  static const Color backgroundMid = Color(0xFF1E293B); // Map to surfaceDark

  // --- Legacy Compatibility Colors (Required for existing screens) ---
  static const Color textPrimary = Color(0xFF1F2937);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textHint = Color(0xFF9CA3AF);
  static const Color accent = Color(0xFF7C3AED);
  static const Color accentOrange = Color(0xFFF59E0B);
  static const Color accentBlue = Color(0xFF3B82F6);
  static const Color accentGreen = Color(0xFF10B981);
  static const Color accentPink = Color(0xFFEC4899);
  static const Color accentTeal = Color(0xFF14B8A6);
  static const Color textMuted = Color(0xFF9CA3AF);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color star = Color(0xFFFBBF24);
  
  static const Color moodHappy = Color(0xFFFFD700);
  static const Color moodCalm = Color(0xFF4FACFE);
  static const Color moodSad = Color(0xFF764BA2);
  static const Color moodAnxious = Color(0xFFFA709A);

  // --- Glassmorphism ---
  static const Color cardGlass = Color(0x1AFFFFFF);
  static const Color glassBorder = Color(0x33FFFFFF);
  static const Color cardShadow = Color(0x1A000000);
  
  static final List<BoxShadow> softShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.05),
      blurRadius: 15,
      offset: const Offset(0, 5),
    ),
  ];

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient brandGradient = primaryGradient;
  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [backgroundDark, Color(0xFF1E293B)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
