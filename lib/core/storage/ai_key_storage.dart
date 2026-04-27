import 'package:shared_preferences/shared_preferences.dart';

class AIKeyStorage {
  static const _key = 'ai_api_key';
  static const _provider = 'ai_provider';

  static Future<void> save(String key, String provider) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, key);
    await prefs.setString(_provider, provider);
  }

  static Future<Map<String, String>> load() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'key': prefs.getString(_key) ?? '',
      'provider': prefs.getString(_provider) ?? '',
    };
  }
}
