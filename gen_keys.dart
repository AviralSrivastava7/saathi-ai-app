import 'dart:io';

void main() {
  final keys = File('keys_output_utf8.txt').readAsLinesSync();
  
  Map<String, Map<String, String>> existing = {};
  final currentContent = File('lib/core/localization/translations.dart').readAsStringSync();
  // Very simple parsing of existing
  final re = RegExp(r"'([^']+)':\s*\{\s*'en':\s*'([^']*)',\s*'hi':\s*'([^']*)',\s*'hn':\s*'([^']*)'\s*\}");
  for (var m in re.allMatches(currentContent)) {
    existing[m.group(1)!] = { 'en': m.group(2)!, 'hi': m.group(3)!, 'hn': m.group(4)! };
  }
  
  String toTitleCase(String snake) {
    if (snake.startsWith('game_')) snake = snake.substring(5);
    if (snake.startsWith('str_')) snake = snake.substring(4);
    return snake.split('_').map((word) => word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1)).join(' ');
  }

  // Pre-translated high-priority ones
  Map<String, Map<String, String>> preTranslates = {
    'well_done': {'en': 'Well Done', 'hi': 'बहुत बढ़िया', 'hn': 'Bahut Badhiya'},
    'done': {'en': 'Done', 'hi': 'हो गया', 'hn': 'Ho gaya'},
    'start_exercise': {'en': 'Start Exercise', 'hi': 'व्यायाम शुरू करें', 'hn': 'Vyayam shuru karein'},
    'duration': {'en': 'Duration', 'hi': 'अवधि', 'hn': 'Duration'},
    'select_technique': {'en': 'Select Technique', 'hi': 'तकनीक चुनें', 'hn': 'Technique chunein'},
    'new_game': {'en': 'New Game', 'hi': 'नया खेल', 'hn': 'Naya Khel'},
    'play_again': {'en': 'Play Again', 'hi': 'फिर से खेलें', 'hn': 'Phir se khelein'},
    'total': {'en': 'Total', 'hi': 'कुल', 'hn': 'Total'},
    'progress': {'en': 'Progress', 'hi': 'प्रगति', 'hn': 'Progress'},
    'unlocked': {'en': 'Unlocked', 'hi': 'खुला गया', 'hn': 'Unlock ho gaya'},
    'streak': {'en': 'Streak', 'hi': 'लगातार दिन', 'hn': 'Streak'},
    'cancel': {'en': 'Cancel', 'hi': 'रद्द करें', 'hn': 'Cancel karein'},
    'save_btn': {'en': 'Save', 'hi': 'सहेजें', 'hn': 'Save'},
    // Adding more manually if needed...
  };

  var out = StringBuffer();
  out.writeln("class Translations {");
  out.writeln("  static const Map<String, Map<String, String>> translations = {");
  
  Set<String> processed = {};
  
  for (var k in existing.keys) {
    var v = existing[k]!;
    out.writeln("    '$k': { 'en': '${v['en']}', 'hi': '${v['hi']}', 'hn': '${v['hn']}' },");
    processed.add(k);
  }
  
  for (var key in preTranslates.keys) {
    if (!processed.contains(key)) {
      var v = preTranslates[key]!;
      out.writeln("    '$key': { 'en': '${v['en']}', 'hi': '${v['hi']}', 'hn': '${v['hn']}' },");
      processed.add(key);
    }
  }
  
  for (var key in keys) {
    if (key.trim().isEmpty) continue;
    if (!processed.contains(key)) {
      String enText = toTitleCase(key).replaceAll("'", "\\'");
      // Provide English for now so at least it's not underscores!
      out.writeln("    '$key': { 'en': '$enText', 'hi': '$enText', 'hn': '$enText' },");
      processed.add(key);
    }
  }

  out.writeln("  };");
  out.writeln("");
  out.writeln("  static String get(String key, String lang, [Object? val]) {");
  out.writeln("    String text = translations[key]?[lang] ?? translations[key]?['en'] ?? key;");
  out.writeln("    if (val != null) {");
  out.writeln("      if (val is Map) {");
  out.writeln("        val.forEach((k, v) {");
  out.writeln("          text = text.replaceAll('\\{\$k}', v.toString());");
  out.writeln("        });");
  out.writeln("      } else {");
  out.writeln("        text = text.replaceAll('{val}', val.toString());");
  out.writeln("      }");
  out.writeln("    }");
  out.writeln("    return text;");
  out.writeln("  }");
  out.writeln("}");
  
  File('lib/core/localization/translations.dart').writeAsStringSync(out.toString());
  print("Updated translations.dart with ${processed.length} keys!");
}
