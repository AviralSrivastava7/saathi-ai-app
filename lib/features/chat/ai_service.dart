import 'dart:convert';
import 'package:http/http.dart' as http;

class AiService {
  // NOTE: This service is DEPRECATED. Saathi now uses on-device Gemma 2B AI.
  // No API keys are needed — all AI runs locally on the user's phone.
  static const String _apiKey = '';

  static Future<String> getReply(String userMessage) async {
    final uri = Uri.parse('https://api.openai.com/v1/chat/completions');

    try {
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          "model": "gpt-4o-mini",
          "messages": [
            {
              "role": "system",
              "content":
                  "You are Saathi, an empathetic emotional support companion. "
                      "You listen carefully, reply kindly in Hindi, English or Hinglish, "
                      "and you never give medical advice."
            },
            {"role": "user", "content": userMessage}
          ],
          "temperature": 0.7
        }),
      );

      // 🔴 IMPORTANT: status check
      if (response.statusCode != 200) {
        print('STATUS CODE: ${response.statusCode}');
        print('BODY: ${response.body}');
        return "AI se connect nahi ho pa raha. Thoda baad try karo 💙";
      }

      final data = jsonDecode(response.body);
      return data['choices'][0]['message']['content'];
    } catch (e) {
      print('AI EXCEPTION: $e');
      return "Kuch technical issue aa raha hai. Thoda ruk ke try karo 💙";
    }
  }
}
