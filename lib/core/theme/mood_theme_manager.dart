// lib/core/theme/mood_theme_manager.dart
import 'package:flutter/material.dart';
import 'app_colors.dart';

class MoodTheme {
  final Gradient background;
  final Color primary;
  final Color accent;

  MoodTheme({
    required this.background,
    required this.primary,
    required this.accent,
  });
}

class MoodThemeManager {
  static MoodTheme getThemeForMood(String mood) {
    switch (mood.toLowerCase()) {
      case 'happy':
      case 'joyful':
      case 'excited':
        return MoodTheme(
          background: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.yellow.shade400,
              Colors.orange.shade500,
              AppColors.primaryPurple,
            ],
          ),
          primary: Colors.yellow.shade400,
          accent: Colors.orange.shade500,
        );

      case 'calm':
      case 'peaceful':
      case 'relaxed':
        return MoodTheme(
          background: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue.shade400,
              Colors.teal.shade500,
              AppColors.backgroundDark,
            ],
          ),
          primary: Colors.blue.shade400,
          accent: Colors.teal.shade500,
        );

      case 'sad':
      case 'down':
      case 'depressed':
        return MoodTheme(
          background: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.indigo.shade700,
              Colors.purple.shade800,
              AppColors.backgroundDark,
            ],
          ),
          primary: Colors.indigo.shade700,
          accent: Colors.purple.shade800,
        );

      case 'anxious':
      case 'worried':
      case 'stressed':
        return MoodTheme(
          background: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.orange.shade600,
              Colors.red.shade700,
              AppColors.backgroundDark,
            ],
          ),
          primary: Colors.orange.shade600,
          accent: Colors.red.shade700,
        );

      case 'angry':
      case 'frustrated':
        return MoodTheme(
          background: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.red.shade600,
              Colors.deepOrange.shade700,
              AppColors.backgroundDark,
            ],
          ),
          primary: Colors.red.shade600,
          accent: Colors.deepOrange.shade700,
        );

      case 'neutral':
      default:
        return MoodTheme(
          background: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primaryPurple,
              AppColors.accentPink,
              AppColors.backgroundDark,
            ],
          ),
          primary: AppColors.primaryPurple,
          accent: AppColors.accentPink,
        );
    }
  }

  static Color getColorForMood(String mood) {
    switch (mood.toLowerCase()) {
      case 'happy':
      case 'joyful':
      case 'excited':
        return Colors.yellow.shade400;
      case 'calm':
      case 'peaceful':
      case 'relaxed':
        return Colors.blue.shade400;
      case 'sad':
      case 'down':
      case 'depressed':
        return Colors.indigo.shade700;
      case 'anxious':
      case 'worried':
      case 'stressed':
        return Colors.orange.shade600;
      case 'angry':
      case 'frustrated':
        return Colors.red.shade600;
      default:
        return AppColors.primaryPurple;
    }
  }
}
