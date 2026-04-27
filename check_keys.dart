import 'dart:io';

void main() {
  final file = File('lib/core/localization/translations.dart');
  final content = file.readAsStringSync();
  
  final keyRegex = RegExp(r"^\s*'([\w_-]+)'", multiLine: true);
  final Set<String> definedKeys = {};
  for (final match in keyRegex.allMatches(content)) {
    definedKeys.add(match.group(1)!);
  }
  
  final Set<String> usedKeys = {};
  final codeRegex = RegExp(r"t(?:ranslate)?\('([\w_-]+)'"); 
  
  final libDir = Directory('lib');
  for (final f in libDir.listSync(recursive: true)) {
    if (f is File && f.path.endsWith('.dart') && !f.path.contains('translations.dart')) {
      final code = f.readAsStringSync();
      for (final match in codeRegex.allMatches(code)) {
        usedKeys.add(match.group(1)!);
      }
    }
  }
  
  final missingKeys = usedKeys.difference(definedKeys);
  print('Missing keys in translations.dart (${missingKeys.length}):');
  for (final key in missingKeys) {
    if(!key.contains('\$')) print(key);
  }
}
