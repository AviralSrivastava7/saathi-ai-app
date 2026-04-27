import 'dart:io';

void main() {
  final libDir = Directory('lib');
  final regex = RegExp(r"Text\(\s*['" '"' r"]([A-Z][A-Za-z0-9\s!?,.]+)['" '"' r"]\s*\)");
  
  for (final f in libDir.listSync(recursive: true)) {
    if (f is File && f.path.endsWith('.dart') && !f.path.contains('translations.dart')) {
      final content = f.readAsStringSync();
      final matches = regex.allMatches(content);
      if (matches.isNotEmpty) {
        print('\n--- ${f.path}');
        for (final m in matches) {
          print('  ${m.group(1)}');
        }
      }
    }
  }
}
