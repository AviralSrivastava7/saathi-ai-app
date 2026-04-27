class EmotionDetector {
  static String detect(String text) {
    final t = text.toLowerCase();

    // 1. Tired / Burnout
    if (t.contains('thak') ||
        t.contains('tired') ||
        t.contains('exhaust') ||
        t.contains('drain') ||
        t.contains('burnout')) {
      return 'tired';
    }

    // 2. Sad / Depressed
    if (t.contains('sad') ||
        t.contains('udaas') ||
        t.contains('cry') ||
        t.contains('rona') ||
        t.contains('worthless') ||
        t.contains('low')) {
      return 'sad';
    }

    // 3. Anxious / Fear
    if (t.contains('anx') ||
        t.contains('dar') ||
        t.contains('fear') ||
        t.contains('ghabra') ||
        t.contains('panic') ||
        t.contains('tension')) {
      return 'anxious';
    }

    // 4. Lonely
    if (t.contains('alone') ||
        t.contains('akela') ||
        t.contains('lonely') ||
        t.contains('koi nahi')) {
      return 'lonely';
    }

    // Default
    return 'general';
  }
}
