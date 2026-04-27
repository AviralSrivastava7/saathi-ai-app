import 'emotion_models.dart';

class EmotionDetector {
  static EmotionResult detect(String text) {
    final t = text.toLowerCase();

    int intensity = 1;
    if (t.contains('bohot') || t.contains('bahut')) intensity = 3;
    if (t.contains('zyada') || t.contains('bahut zyada')) intensity = 4;
    if (t.contains('bilkul') || t.contains('bahut hi')) intensity = 5;

    if (_has(t, ['thak', 'tired', 'exhaust'])) {
      return EmotionResult(EmotionType.tired, intensity);
    }
    if (_has(t, ['udaas', 'sad', 'down', 'rona'])) {
      return EmotionResult(EmotionType.sad, intensity);
    }
    if (_has(t, ['ghabra', 'anxious', 'dar', 'panic'])) {
      return EmotionResult(EmotionType.anxious, intensity);
    }
    if (_has(t, ['akela', 'lonely', 'koi nahi'])) {
      return EmotionResult(EmotionType.lonely, intensity);
    }
    if (_has(t, ['gussa', 'angry', 'irritated'])) {
      return EmotionResult(EmotionType.angry, intensity);
    }
    if (_has(t, ['handle', 'overwhelmed', 'sab kuch'])) {
      return EmotionResult(EmotionType.overwhelmed, intensity);
    }

    return EmotionResult(EmotionType.unknown, 1);
  }

  static bool _has(String text, List<String> keys) {
    return keys.any(text.contains);
  }
}
