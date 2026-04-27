/// On-Device Sentiment Analyzer - Zero Cloud Risk
/// All processing happens locally on the device.
/// Uses keyword-based NLP scoring for mood detection.
/// No data ever leaves the phone.
class SentimentAnalyzer {
  // Sentiment score: -1.0 (very negative) to +1.0 (very positive)

  static const Map<String, double> _positiveWords = {
    // English
    'happy': 0.8, 'joy': 0.9, 'love': 0.8, 'great': 0.7, 'amazing': 0.9,
    'wonderful': 0.9, 'fantastic': 0.9, 'good': 0.6, 'nice': 0.5,
    'beautiful': 0.7, 'awesome': 0.8, 'excellent': 0.9, 'blessed': 0.8,
    'grateful': 0.8, 'thankful': 0.7, 'peaceful': 0.7, 'calm': 0.6,
    'excited': 0.7, 'proud': 0.7, 'confident': 0.7, 'hopeful': 0.7,
    'smile': 0.6, 'laugh': 0.7, 'fun': 0.6, 'celebrate': 0.8,
    'success': 0.8, 'achieve': 0.7, 'win': 0.7, 'enjoy': 0.6,
    'relaxed': 0.6, 'content': 0.6, 'satisfied': 0.6, 'motivated': 0.7,
    'inspired': 0.7, 'strong': 0.6, 'brave': 0.7, 'positive': 0.6,
    // Hindi/Hinglish
    'khushi': 0.8, 'khush': 0.8, 'accha': 0.6, 'badiya': 0.7,
    'mast': 0.7, 'mazaa': 0.7, 'pyaar': 0.8, 'sukoon': 0.7,
    'shanti': 0.7, 'umeed': 0.7, 'himmat': 0.7, 'hausla': 0.7,
    'jeet': 0.8, 'safal': 0.8, 'dhanyavaad': 0.7, 'shukriya': 0.7,
  };

  static const Map<String, double> _negativeWords = {
    // English - tracked for mood alerts
    'sad': -0.7, 'depressed': -0.9, 'anxious': -0.8, 'worried': -0.7,
    'stress': -0.8, 'stressed': -0.8, 'lonely': -0.8, 'alone': -0.6,
    'fail': -0.7, 'failed': -0.8, 'failure': -0.9, 'hopeless': -0.9,
    'worthless': -0.9, 'useless': -0.8, 'tired': -0.5, 'exhausted': -0.7,
    'angry': -0.7, 'frustrated': -0.7, 'hate': -0.8, 'crying': -0.7,
    'cry': -0.6, 'pain': -0.7, 'hurt': -0.7, 'scared': -0.7,
    'afraid': -0.7, 'panic': -0.8, 'terrible': -0.8, 'horrible': -0.8,
    'awful': -0.8, 'miserable': -0.9, 'broken': -0.7, 'empty': -0.7,
    'numb': -0.6, 'lost': -0.6, 'confused': -0.5, 'overwhelmed': -0.7,
    'burnout': -0.8, 'suicide': -1.0, 'die': -0.9, 'dead': -0.8,
    'give up': -0.9, 'cant go on': -0.9, 'no point': -0.8,
    // Hindi/Hinglish - tracked for mood alerts
    'akela': -0.8, 'udaas': -0.7, 'dukhi': -0.8, 'rona': -0.6,
    'darr': -0.7, 'gussa': -0.7, 'thak': -0.5, 'thaka': -0.5,
    'haar': -0.7, 'naakaam': -0.8, 'pareshaan': -0.7, 'tension': -0.7,
    'toot': -0.7, 'majboor': -0.7, 'bekar': -0.7, 'bezaar': -0.7,
    'tang': -0.6, 'mushkil': -0.6, 'takleef': -0.7, 'dard': -0.7,
  };

  /// Analyze text and return a score between -1.0 and 1.0
  static double analyze(String text) {
    if (text.trim().isEmpty) return 0.0;

    final words = text.toLowerCase().replaceAll(RegExp(r'[^\w\s]'), ' ').split(RegExp(r'\s+'));
    double totalScore = 0;
    int matchCount = 0;

    for (final word in words) {
      if (_positiveWords.containsKey(word)) {
        totalScore += _positiveWords[word]!;
        matchCount++;
      }
      if (_negativeWords.containsKey(word)) {
        totalScore += _negativeWords[word]!;
        matchCount++;
      }
    }

    if (matchCount == 0) return 0.0;
    return (totalScore / matchCount).clamp(-1.0, 1.0);
  }

  /// Get mood label from sentiment score
  static String getMoodLabel(double score) {
    if (score >= 0.5) return 'Very Positive 😊';
    if (score >= 0.2) return 'Positive 🙂';
    if (score > -0.2) return 'Neutral 😐';
    if (score > -0.5) return 'Low 😔';
    return 'Very Low 😢';
  }

  /// Get mood color from sentiment score
  static int getMoodColorValue(double score) {
    if (score >= 0.5) return 0xFF43E97B;
    if (score >= 0.2) return 0xFF4FACFE;
    if (score > -0.2) return 0xFF9CA3AF;
    if (score > -0.5) return 0xFFF97316;
    return 0xFFEF4444;
  }

  /// Detect if text contains concerning patterns (for weekly alert only)
  static bool hasConcerningPattern(String text) {
    final lower = text.toLowerCase();
    final concerningPhrases = [
      'give up', 'cant go on', 'no point', 'end it', 'want to die',
      'suicide', 'harm myself', 'self harm', 'worthless',
      'haar maan', 'koi faayda nahi', 'jeene ka mann nahi',
    ];
    return concerningPhrases.any((phrase) => lower.contains(phrase));
  }

  /// Count negative keyword frequency for weekly reports
  static Map<String, int> getNegativeWordFrequency(List<String> texts) {
    final frequency = <String, int>{};
    for (final text in texts) {
      final words = text.toLowerCase().replaceAll(RegExp(r'[^\w\s]'), ' ').split(RegExp(r'\s+'));
      for (final word in words) {
        if (_negativeWords.containsKey(word)) {
          frequency[word] = (frequency[word] ?? 0) + 1;
        }
      }
    }
    // Sort by frequency
    final sorted = Map.fromEntries(
      frequency.entries.toList()..sort((a, b) => b.value.compareTo(a.value)),
    );
    return sorted;
  }
}
