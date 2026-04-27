enum EmotionType {
  tired,
  sad,
  anxious,
  lonely,
  angry,
  overwhelmed,
  okay,
  unknown,
}

class EmotionResult {
  final EmotionType type;
  final int intensity; // 1–5

  EmotionResult(this.type, this.intensity);
}
