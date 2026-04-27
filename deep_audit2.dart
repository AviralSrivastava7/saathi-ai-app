import 'dart:io';

void main() {
  final libDir = Directory('lib');
  final patterns = [
    RegExp(r"""Text\(\s*(?:const\s+)?'([^'$]{3,})'"""),
    RegExp(r'''Text\(\s*(?:const\s+)?"([^"$]{3,})"'''),
    RegExp(r"""label:\s*'([^'$]{3,})'"""),
    RegExp(r"""hintText:\s*'([^'$]{3,})'"""),
    RegExp(r"""labelText:\s*'([^'$]{3,})'"""),
    RegExp(r"""tooltip:\s*'([^'$]{3,})'"""),
  ];

  for (final f in libDir.listSync(recursive: true)) {
    if (f is File && f.path.endsWith('.dart') && !f.path.contains('translations.dart') && !f.path.contains('app_localizations.dart')) {
      final lines = f.readAsLinesSync();
      for (int i = 0; i < lines.length; i++) {
        final line = lines[i];
        if (line.trimLeft().startsWith('//') || line.trimLeft().startsWith('import')) continue;
        if (line.contains('loc.t(') || line.contains('.t(') || line.contains('translate(')) continue;
        if (line.contains('assets/') || line.contains('http') || line.contains('.dart') || line.contains('.txt') || line.contains('.jpg') || line.contains('.png')) continue;
        if (line.contains('fontFamily') || line.contains('package:') || line.contains('Key(')) continue;
        
        for (final pat in patterns) {
          for (final match in pat.allMatches(line)) {
            final text = match.group(1)!;
            if (RegExp(r'^[\s\d\W]+$').hasMatch(text)) continue;
            if (!RegExp(r'[a-zA-Z]').hasMatch(text)) continue;
            if (text.contains('_') && !text.contains(' ')) continue;
            if (text.length < 3) continue;
            final relPath = f.path.replaceAll('\\', '/').replaceAll('lib/', '');
            print('$relPath:${i+1}|$text');
          }
        }
      }
    }
  }
}
