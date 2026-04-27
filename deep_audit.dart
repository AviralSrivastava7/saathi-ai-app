import 'dart:io';

void main() {
  final libDir = Directory('lib');
  // Match Text('...'), Text("..."), title: '...', label: '...', hintText: '...',
  // content: Text('...'), child: Text('...'), snackBar with Text('...')
  // Also matches strings passed to Text widgets and SnackBar content
  final patterns = [
    // Text widget with single-quoted literal string (not variable, not loc.t, not interpolation)
    RegExp(r"""Text\(\s*'([^'$]{3,})'"""),
    // Text widget with double-quoted literal string
    RegExp(r'''Text\(\s*"([^"$]{3,})"'''),
    // title: Text('...')
    RegExp(r"""title:\s*(?:const\s+)?Text\(\s*'([^'$]{3,})'"""),
    // label: '...' in BottomNavigationBarItem or InputDecoration
    RegExp(r"""label:\s*'([^'$]{3,})'"""),
    // hintText: '...'
    RegExp(r"""hintText:\s*'([^'$]{3,})'"""),
    // labelText: '...'  
    RegExp(r"""labelText:\s*'([^'$]{3,})'"""),
    // tooltip: '...'
    RegExp(r"""tooltip:\s*'([^'$]{3,})'"""),
    // SnackBar(content: Text('...')
    RegExp(r"""SnackBar\([^)]*Text\(\s*'([^'$]{3,})'"""),
  ];
  
  // Exclusions: imports, comments, asset paths, color codes, font names, keys, etc.
  final excludePatterns = [
    RegExp(r"^import\s"),
    RegExp(r"^\s*//"),
    RegExp(r"assets/"),
    RegExp(r"0x[0-9A-Fa-f]+"),
    RegExp(r"package:"),
    RegExp(r"\.dart"),
    RegExp(r"\.txt"),
    RegExp(r"\.jpg"),
    RegExp(r"\.png"),
    RegExp(r"\.json"),
    RegExp(r"http"),
    RegExp(r"SharedPreferences"),
    RegExp(r"prefs\."),
    RegExp(r"Key\("),
    RegExp(r"fontFamily"),
    RegExp(r"loc\.t\("),
    RegExp(r"\.t\("),
    RegExp(r"translate\("),
    RegExp(r"Translations\."),
    RegExp(r"localizeMood"),
  ];

  int totalFound = 0;
  
  for (final f in libDir.listSync(recursive: true)) {
    if (f is File && f.path.endsWith('.dart') && !f.path.contains('translations.dart') && !f.path.contains('app_localizations.dart')) {
      final lines = f.readAsLinesSync();
      final findings = <String>[];
      
      for (int i = 0; i < lines.length; i++) {
        final line = lines[i];
        
        // Skip excluded lines
        bool skip = false;
        for (final ex in excludePatterns) {
          if (ex.hasMatch(line)) { skip = true; break; }
        }
        if (skip) continue;
        
        for (final pat in patterns) {
          for (final match in pat.allMatches(line)) {
            final text = match.group(1)!;
            // Skip if it's just emojis, numbers, punctuation, single chars
            if (RegExp(r'^[\s\d\W]+$').hasMatch(text)) continue;
            // Skip if it contains only non-latin chars (already Hindi)
            if (!RegExp(r'[a-zA-Z]').hasMatch(text)) continue;
            // Skip map keys or variable references
            if (text.contains('_') && !text.contains(' ')) continue;
            findings.add('  L${i+1}: "$text"');
          }
        }
      }
      
      if (findings.isNotEmpty) {
        final relPath = f.path.replaceAll('\\', '/');
        print('\n=== $relPath (${findings.length} strings) ===');
        for (final finding in findings) {
          print(finding);
        }
        totalFound += findings.length;
      }
    }
  }
  
  print('\n\n========== TOTAL: $totalFound hardcoded strings found ==========');
}
