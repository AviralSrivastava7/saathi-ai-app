class AIConfig {
  static String apiKey = '';
  static String provider = ''; // openai | gemini

  static bool get isReady => apiKey.isNotEmpty;
}
