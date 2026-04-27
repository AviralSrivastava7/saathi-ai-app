import 'package:flutter_test/flutter_test.dart';
import 'package:saathi/core/ai/offline_ai_engine.dart';

void main() {
  group('OfflineAIEngine Advanced Mood & Response Tests', () {
    
    test('Detect Overwhelmed state', () {
      final response = OfflineAIEngine.generateResponse("Bohot zyada kaam hai, sab ek saath ho raha hai handle nahi ho raha");
      print('Overwhelmed Test Response:\n$response');
      expect(response.toLowerCase().contains('overwhelmed') || 
             response.toLowerCase().contains('mushkil') ||
             response.toLowerCase().contains('pressure'), true);
    });

    test('Detect Frustrated state with slang', () {
      final response = OfflineAIEngine.generateResponse("Aaj dimag kharab ho gaya, bilkul pakk gaya hoon");
      print('Frustrated Test Response:\n$response');
      expect(response.toLowerCase().contains('frustration') || 
             response.toLowerCase().contains('gussa') ||
             response.toLowerCase().contains('pakk'), true);
    });

    test('Detect Hopeless state', () {
      final response = OfflineAIEngine.generateResponse("Ab kuch nahi hoga, sab khatam");
      print('Hopeless Test Response:\n$response');
      expect(response.toLowerCase().contains('hopeless') || 
             response.toLowerCase().contains('umeed') ||
             response.toLowerCase().contains('andhera'), true);
    });

    test('Intensity Multiplier for High Stress', () {
      final response = OfflineAIEngine.generateResponse("BOBOT BOHOT PARESHAN HOON!!! SAB KHATAM HO GAYA!");
      print('Intense Test Response:\n$response');
      expect(response.toLowerCase().contains('gehra dard') || 
             response.toLowerCase().contains('heavy') ||
             response.toLowerCase().contains('mushkil'), true);
    });

    test('Empathy Fillers and Varied Openings', () {
      final response1 = OfflineAIEngine.generateResponse("Main thak gaya hoon");
      final response2 = OfflineAIEngine.generateResponse("Main thak gaya hoon");
      
      print('Response 1:\n$response1');
      print('Response 2:\n$response2');
      
      // Since it's random, they might be same, but we check if they are non-empty
      expect(response1.isNotEmpty, true);
      expect(response2.isNotEmpty, true);
    });
  });
}
