import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/ai_config.dart';

class AIService {
  static Future<String> reply(String prompt) async {
    final response = await http.post(
      Uri.parse('https://api.openai.com/v1/chat/completions'),
      headers: {
        'Authorization': 'Bearer ${AIConfig.apiKey}',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'model': 'gpt-4o-mini',
        'messages': [
          {
            'role': 'system',
            'content':
                'You are Saathi. You listen calmly. You never judge. Short replies.'
          },
          {'role': 'user', 'content': prompt}
        ],
      }),
    );

    if (response.statusCode != 200) {
      return 'I’m having trouble responding right now.';
    }

    final data = jsonDecode(response.body);
    return data['choices'][0]['message']['content'];
  }
}
