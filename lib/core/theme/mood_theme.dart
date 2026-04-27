import 'package:flutter/material.dart';

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
