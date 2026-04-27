import '../storage/mood_storage.dart';
import '../storage/journal_storage.dart';

class EmotionalContext {
  static String lastMood = '';
  static String journalTone = 'neutral';

  static Future<void> load() async {
    final moods = await MoodStorage.getRecentMoods();
    if (moods.isNotEmpty) {
      // MoodStorage recent moods are Map<String, dynamic>
      // We check for 'mood' or 'label' key
      lastMood = moods.first['mood'] ?? moods.first['label'] ?? '';
    }

    final journals = await JournalStorage.loadAll();
    // Analyze the most recent journal or combine them
    final combinedJournal = journals.map((e) => e['content'] ?? '').join(' ');
    journalTone = _analyzeJournal(combinedJournal);
  }

  static String _analyzeJournal(String text) {
    final lower = text.toLowerCase();

    if (lower.contains('tired') ||
        lower.contains('thak') ||
        lower.contains('hurt') ||
        lower.contains('sad')) {
      return 'heavy';
    }

    if (lower.contains('okay') ||
        lower.contains('better') ||
        lower.contains('fine')) {
      return 'normal';
    }

    if (lower.contains('happy') ||
        lower.contains('acha') ||
        lower.contains('progress')) {
      return 'positive';
    }

    return 'neutral';
  }
}
