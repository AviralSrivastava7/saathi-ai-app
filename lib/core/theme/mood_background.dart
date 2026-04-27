import 'package:flutter/material.dart';

class MoodBackground {
  /// Returns an image path for the given mood, or null if no image exists.
  /// Callers should use gradient fallbacks when null is returned.
  static String? imageFor(String? moodLabel) {
    if (moodLabel == null || moodLabel.isEmpty) return null;

    switch (moodLabel.toLowerCase()) {
      case 'happy':
      case 'excited':
        return 'assets/icon/app_icon.png';
      case 'calm':
      case 'peaceful':
        return 'assets/images/profile_calm.jpg';
      case 'sad':
      case 'depressed':
      case 'angry':
      case 'frustrated':
      default:
        return null; // Use gradient fallback
    }
  }

  static double overlayFor(String? moodLabel) {
    // Har mood ke liye brightness alag rakh sakte hain
    if (moodLabel == 'Happy') return 0.2; // Thoda bright
    if (moodLabel == 'Sad') return 0.5; // Thoda dark
    return 0.3;
  }
}

class MoodTheme {
  static Color background(String mood) {
    final m = mood.toLowerCase();

    if (m.contains('heavy')) {
      return const Color(0xFF0E1621); // deep calm dark
    }

    if (m.contains('ok') || m.contains('theek')) {
      return const Color(0xFF101B17); // soft green dark
    }

    return const Color(0xFF0C0F14); // default dark
  }
}
