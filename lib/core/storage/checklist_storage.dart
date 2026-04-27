import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ChecklistStorage {
  static const String _key = 'saathi_checklist';
  
  static Future<List<Map<String, dynamic>>> loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return _defaultTasks();
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list.map((e) => Map<String, dynamic>.from(e)).toList();
    } catch (_) { return _defaultTasks(); }
  }
  
  static Future<void> saveAll(List<Map<String, dynamic>> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(tasks));
  }
  
  static List<Map<String, dynamic>> _defaultTasks() {
    return [
      {'title': 'Morning meditation', 'done': false},
      {'title': 'Drink 8 glasses of water', 'done': false},
      {'title': '30 minutes exercise', 'done': false},
      {'title': 'Journal my thoughts', 'done': false},
      {'title': 'Connect with a friend', 'done': false},
      {'title': 'Practice gratitude', 'done': false},
    ];
  }
}
