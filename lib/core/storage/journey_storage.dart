// lib/core/storage/journey_storage.dart
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class JourneyEntry {
  final String id;
  final String title;
  final String content;
  final DateTime timestamp;
  final String mood;
  final List<String> tags;

  JourneyEntry({
    required this.id,
    required this.title,
    required this.content,
    required this.timestamp,
    required this.mood,
    this.tags = const [],
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'content': content,
        'timestamp': timestamp.toIso8601String(),
        'mood': mood,
        'tags': tags,
      };

  factory JourneyEntry.fromJson(Map<String, dynamic> json) => JourneyEntry(
        id: json['id'],
        title: json['title'],
        content: json['content'],
        timestamp: DateTime.parse(json['timestamp']),
        mood: json['mood'],
        tags: List<String>.from(json['tags'] ?? []),
      );
}

class JourneyStorage {
  static const String _journeyKey = 'journey_entries';

  static Future<void> saveJourneyEntry(JourneyEntry entry) async {
    final prefs = await SharedPreferences.getInstance();
    final entries = await getAllJourneys();
    entries.add(entry);

    final jsonList = entries.map((e) => e.toJson()).toList();
    await prefs.setString(_journeyKey, jsonEncode(jsonList));
  }

  static Future<List<JourneyEntry>> getAllJourneys() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_journeyKey);

    if (jsonString == null) return [];

    final List<dynamic> jsonList = jsonDecode(jsonString);
    return jsonList.map((json) => JourneyEntry.fromJson(json)).toList();
  }

  static Future<List<JourneyEntry>> getJourneysByDateRange(
      DateTime start, DateTime end) async {
    final allJourneys = await getAllJourneys();
    return allJourneys
        .where((entry) =>
            entry.timestamp.isAfter(start) && entry.timestamp.isBefore(end))
        .toList();
  }

  static Future<void> deleteJourney(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final entries = await getAllJourneys();
    entries.removeWhere((entry) => entry.id == id);

    final jsonList = entries.map((e) => e.toJson()).toList();
    await prefs.setString(_journeyKey, jsonEncode(jsonList));
  }

  static Future<void> clearAllJourneys() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_journeyKey);
  }

  static Future<dynamic> load() async {}

  static Future<void> save(
      {required moodEmoji,
      required moodLabel,
      required String journal,
      required String lastChat}) async {}
}
