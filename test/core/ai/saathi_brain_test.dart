import 'dart:io';
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:saathi/core/ai/saathi_brain.dart';

void main() {
  test('Verify SaathiBrain knowledge base integration', () async {
    // 1. Manually load the JSON for the test environment
    final file = File('assets/ai/knowledge_base.json');
    final String content = await file.readAsString();
    final List<dynamic> kb = json.decode(content);
    
    print('Knowledge base loaded with ${kb.length} entries.');
    
    // 2. Test a known FAQ from Mental Health FAQ
    const q1 = "What does it mean to have a mental illness?";
    final a1 = SaathiBrain.reply(q1);
    
    print('Q: $q1');
    print('A: $a1');
    
    expect(a1.isNotEmpty, true);
    expect(a1.toLowerCase().contains('mental'), true);

    // 3. Test an empathetic dialogue context
    const q2 = "I am feeling very lonely lately";
    final a2 = SaathiBrain.reply(q2);
    
    print('Q: $q2');
    print('A: $a2');
    
    expect(a2.isNotEmpty, true);
  });
}
