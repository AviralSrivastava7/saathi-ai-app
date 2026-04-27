import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 🧠 BUDDY MEMORY SERVICE — On-Device Conversation Memory
/// Generates short text summaries from chat sessions and stores them locally.
/// Next session, the summary is injected as context so Buddy "remembers".
/// Data never leaves the device.
class BuddyMemoryService {
  static const String _memoryKey = 'buddy_memory_summary';
  static const String _topicsKey = 'buddy_memory_topics';
  static const String _emotionsKey = 'buddy_memory_emotions';
  static const String _factsKey = 'buddy_memory_facts';
  static const int _maxSummaryLength = 600;

  // ── Load saved memory summary ──────────────────────────
  static Future<String> loadMemorySummary() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_memoryKey) ?? '';
  }

  // ── Save session summary from chat messages ────────────
  /// Call this when the user leaves the chat screen.
  /// [messages] is the list of {'role': 'user'/'assistant', 'text': '...'}
  static Future<void> saveSessionSummary(
      List<Map<String, String>> messages) async {
    if (messages.isEmpty) return;

    // Only process user messages for memory extraction
    final userMessages = messages
        .where((m) => m['role'] == 'user')
        .map((m) => m['text'] ?? '')
        .where((t) => t.isNotEmpty)
        .toList();

    if (userMessages.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();

    // Extract insights from this session
    final sessionTopics = _extractTopics(userMessages);
    final sessionEmotions = _extractEmotions(userMessages);
    final sessionFacts = _extractFacts(userMessages);

    // Merge with existing memory
    final existingTopics =
        prefs.getStringList(_topicsKey) ?? [];
    final existingEmotions =
        prefs.getStringList(_emotionsKey) ?? [];
    final existingFacts =
        prefs.getStringList(_factsKey) ?? [];

    // Merge and deduplicate, keeping recent items first
    final mergedTopics = _mergeList(sessionTopics, existingTopics, maxItems: 8);
    final mergedEmotions =
        _mergeList(sessionEmotions, existingEmotions, maxItems: 5);
    final mergedFacts = _mergeList(sessionFacts, existingFacts, maxItems: 6);

    // Save individual lists
    await prefs.setStringList(_topicsKey, mergedTopics);
    await prefs.setStringList(_emotionsKey, mergedEmotions);
    await prefs.setStringList(_factsKey, mergedFacts);

    // Build human-readable summary
    final summary = _buildSummary(mergedTopics, mergedEmotions, mergedFacts);

    // Trim to max length
    final trimmed = summary.length > _maxSummaryLength
        ? summary.substring(0, _maxSummaryLength)
        : summary;

    await prefs.setString(_memoryKey, trimmed);
    debugPrint('[BuddyMemory] Session saved. Summary: $trimmed');
  }

  // ── Build context prompt for LLM ──────────────────────
  /// Returns a formatted context string to prepend to the system prompt.
  static Future<String> getMemoryContextPrompt() async {
    final summary = await loadMemorySummary();
    if (summary.isEmpty) return '';

    return 'MEMORY (past conversations se yaad hai): $summary\n'
        'Use this memory naturally in conversation — reference past topics gently, '
        'show ki tumhe yaad hai. But do NOT repeat the memory back word-for-word.\n\n';
  }

  // ── Clear all memory ──────────────────────────────────
  static Future<void> clearMemory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_memoryKey);
    await prefs.remove(_topicsKey);
    await prefs.remove(_emotionsKey);
    await prefs.remove(_factsKey);
    debugPrint('[BuddyMemory] Memory cleared.');
  }

  // ── Check if memory exists ────────────────────────────
  static Future<bool> hasMemory() async {
    final summary = await loadMemorySummary();
    return summary.isNotEmpty;
  }

  // ═══════════════════════════════════════════════════════
  // 🔍 EXTRACTION HELPERS
  // ═══════════════════════════════════════════════════════

  /// Extract topics from user messages
  static List<String> _extractTopics(List<String> messages) {
    final allText = messages.join(' ').toLowerCase();
    final topics = <String>[];

    final topicMap = {
      'exams': ['exam', 'paper', 'pariksha', 'test', 'marks', 'result', 'study', 'padhai'],
      'work': ['work', 'job', 'office', 'kaam', 'boss', 'salary', 'interview', 'naukri'],
      'family': ['family', 'gharwale', 'parents', 'maa', 'papa', 'bhai', 'behen', 'ghar'],
      'relationship': ['relation', 'partner', 'friend', 'dost', 'breakup', 'pyaar', 'crush', 'gf', 'bf'],
      'health': ['health', 'tabiyat', 'bimaar', 'sick', 'medicine', 'doctor', 'hospital'],
      'sleep': ['sleep', 'neend', 'insomnia', 'jagta', 'raat', 'sona'],
      'future': ['future', 'career', 'goal', 'plan', 'dream', 'sapna', 'aage'],
      'money': ['money', 'paise', 'paisa', 'loan', 'debt', 'kharcha'],
      'college': ['college', 'university', 'class', 'teacher', 'professor', 'hostel'],
      'loneliness': ['alone', 'akela', 'lonely', 'koi nahi', 'isolated'],
      'self-esteem': ['confidence', 'ugly', 'worth', 'useless', 'worthless', 'failure'],
      'anger': ['gussa', 'angry', 'irritate', 'frustrate', 'chidh'],
    };

    topicMap.forEach((topic, keywords) {
      if (keywords.any((k) => allText.contains(k))) {
        topics.add(topic);
      }
    });

    return topics;
  }

  /// Extract emotions/mood from user messages
  static List<String> _extractEmotions(List<String> messages) {
    final allText = messages.join(' ').toLowerCase();
    final emotions = <String>[];

    final emotionMap = {
      'stressed': ['stress', 'tension', 'pressure', 'dabav'],
      'anxious': ['anxiety', 'anxious', 'ghabra', 'nervous', 'panic', 'dar'],
      'sad': ['sad', 'udaas', 'dukh', 'cry', 'rona', 'hurt'],
      'happy': ['happy', 'khush', 'acha', 'great', 'wonderful', 'maza'],
      'tired': ['tired', 'thak', 'exhaust', 'drain', 'burnout'],
      'frustrated': ['frustrat', 'irritat', 'gussa', 'angry'],
      'hopeless': ['hopeless', 'umeed nahi', 'koi fayda nahi', 'give up'],
      'overwhelmed': ['overwhelm', 'bohot zyada', 'too much', 'handle nahi'],
      'grateful': ['grateful', 'thankful', 'shukriya', 'blessed'],
      'confused': ['confus', 'samajh nahi', 'pata nahi', 'kya karu'],
    };

    emotionMap.forEach((emotion, keywords) {
      if (keywords.any((k) => allText.contains(k))) {
        emotions.add(emotion);
      }
    });

    return emotions;
  }

  /// Extract personal facts (names, preferences, etc.)
  static List<String> _extractFacts(List<String> messages) {
    final facts = <String>[];

    for (final msg in messages) {
      final t = msg.toLowerCase();

      // Name patterns
      final namePatterns = [
        RegExp(r'(?:mera naam|my name is|i am|main)\s+(\w+)', caseSensitive: false),
        RegExp(r'(?:call me|bolo mujhe)\s+(\w+)', caseSensitive: false),
      ];
      for (final p in namePatterns) {
        final m = p.firstMatch(t);
        if (m != null && m.group(1) != null) {
          final name = m.group(1)!;
          if (name.length > 2 &&
              !['hoon', 'hun', 'hai', 'raha', 'rahi', 'feel', 'bohot']
                  .contains(name)) {
            facts.add('User ka naam: ${name[0].toUpperCase()}${name.substring(1)}');
          }
        }
      }

      // Age patterns
      final agePattern = RegExp(r'(?:i am|main|meri age|meri umar)\s+(\d{1,2})\s*(?:years?|saal|sal)?', caseSensitive: false);
      final ageMatch = agePattern.firstMatch(t);
      if (ageMatch != null) {
        final age = int.tryParse(ageMatch.group(1) ?? '');
        if (age != null && age > 10 && age < 100) {
          facts.add('User ki age: $age');
        }
      }

      // Hobby/interest patterns
      if (t.contains('i like') || t.contains('mujhe pasand') || t.contains('hobby')) {
        facts.add('User mentioned interests/hobbies');
      }

      // Pet patterns
      final petPattern = RegExp(r'(?:my pet|mera pet|my dog|mera dog|meri cat|my cat)\s+(\w+)', caseSensitive: false);
      final petMatch = petPattern.firstMatch(t);
      if (petMatch != null) {
        facts.add('User has a pet: ${petMatch.group(1)}');
      }
    }

    return facts;
  }

  // ═══════════════════════════════════════════════════════
  // 🛠️ HELPER METHODS
  // ═══════════════════════════════════════════════════════

  /// Merge new items with existing items, deduplicating
  static List<String> _mergeList(
      List<String> newItems, List<String> existing,
      {int maxItems = 8}) {
    final merged = <String>[...newItems];
    for (final item in existing) {
      if (!merged.contains(item)) {
        merged.add(item);
      }
    }
    if (merged.length > maxItems) {
      return merged.sublist(0, maxItems);
    }
    return merged;
  }

  /// Build a readable summary string from extracted data
  static String _buildSummary(
      List<String> topics, List<String> emotions, List<String> facts) {
    final parts = <String>[];

    if (facts.isNotEmpty) {
      parts.add('Facts: ${facts.join(", ")}.');
    }

    if (emotions.isNotEmpty) {
      parts.add('Recent mood: ${emotions.join(", ")}.');
    }

    if (topics.isNotEmpty) {
      parts.add('Topics discussed: ${topics.join(", ")}.');
    }

    return parts.join(' ');
  }
}
