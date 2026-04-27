import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'offline_ai_engine.dart';

/// 🧠 SAATHI BRAIN — Smart On-Device AI Engine
/// Handles greetings, questions, emotions, crisis, topics
class SaathiBrain {
  static final _r = Random();
  static final List<Map<String, dynamic>> _history = [];
  static String _userName = '';
  static int _msgCount = 0;

  static String get userName => _userName;

  static Future<void> updateUserName(String name) async {
    _userName = name[0].toUpperCase() + name.substring(1).toLowerCase();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('saathi_user_name', _userName);
  }

  /// Load user data from SharedPreferences
  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _userName = prefs.getString('saathi_user_name') ?? '';
    await OfflineAIEngine.init(); // Initialize the new engine
  }

  /// Main entry — generates smart response
  static String reply(String input) {
    _msgCount++;
    final text = input.trim();

    // 0. Check for Name
    checkForName(text.toLowerCase());

    // Delegate ALL response logic to the consolidated OfflineAIEngine
    final response = OfflineAIEngine.generateResponse(text);

    // Add name personalization if available
    if (_userName.isNotEmpty && !response.contains(_userName)) {
      if (response.contains('Namaste!')) return response.replaceAll('Namaste!', 'Namaste $_userName! ');
      if (response.contains('Hey!')) return response.replaceAll('Hey!', 'Hey $_userName! ');
      if (response.contains('Hello!')) return response.replaceAll('Hello!', 'Hello $_userName! ');
    }

    return response;
  }

  // ════════════════════════════════════════
  // 🛠️ HELPERS
  // ════════════════════════════════════════
  static bool _has(String t, List<String> words) => words.any((w) => t.contains(w));
  static String _pick(List<String> l) => l[_r.nextInt(l.length)];

  static void checkForName(String t) {
    final patterns = [
      RegExp(r'(?:mera naam|my name is|i am|main|mai)\s+(\w+)', caseSensitive: false),
      RegExp(r'(?:call me|bolo mujhe)\s+(\w+)', caseSensitive: false),
    ];
    for (final p in patterns) {
      final m = p.firstMatch(t);
      if (m != null && m.group(1) != null) {
        final name = m.group(1)!;
        if (name.length > 2 && !_has(name.toLowerCase(), ['hoon', 'hun', 'hai', 'raha', 'rahi', 'feel', 'bohot', 'bahut'])) {
          _userName = name[0].toUpperCase() + name.substring(1).toLowerCase();
          SharedPreferences.getInstance().then((p) => p.setString('saathi_user_name', _userName));
        }
      }
    }
  }

  static void clearHistory() {
    _history.clear();
    _msgCount = 0;
  }
}
