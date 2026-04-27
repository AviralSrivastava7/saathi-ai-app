import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class JournalStorage {
  static const String _key = 'saathi_journal_entries_list';

  static Future<List<Map<String, String>>> loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list.map((e) => Map<String, String>.from(e)).toList();
    } catch (_) { return []; }
  }

  static Future<void> saveAll(List<Map<String, String>> entries) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(entries));
  }
}
