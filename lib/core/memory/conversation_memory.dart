class ConversationMemory {
  static String? lastEmotion;
  static int repeatCount = 0;

  static void update(String emotion) {
    if (emotion == lastEmotion) {
      repeatCount++;
    } else {
      repeatCount = 0;
    }
    lastEmotion = emotion;
  }

  static bool isStuck() {
    return repeatCount >= 2;
  }
}
