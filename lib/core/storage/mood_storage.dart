import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'stats_storage.dart';

// MoodEntry class definition
class MoodEntry {
  final String mood;
  final DateTime timestamp;
  final String? note;
  final int? intensity;

  MoodEntry({
    required this.mood,
    required this.timestamp,
    this.note,
    this.intensity,
  });

  Map<String, dynamic> toJson() => {
        'mood': mood,
        'timestamp': timestamp.toIso8601String(),
        'note': note,
        'intensity': intensity,
      };

  factory MoodEntry.fromJson(Map<String, dynamic> json) => MoodEntry(
        mood: json['mood'],
        timestamp: DateTime.parse(json['timestamp']),
        note: json['note'],
        intensity: json['intensity'],
      );
}

class MoodStorage {
  static const String _moodKey = 'mood_entries';
  static const String _currentMoodKey = 'current_mood';

  // Save mood entry
  static Future<void> saveMood(String mood,
      {String? note, int? intensity}) async {
    final prefs = await SharedPreferences.getInstance();
    final entry = MoodEntry(
      mood: mood,
      timestamp: DateTime.now(),
      note: note,
      intensity: intensity,
    );

    final entries = await getAllMoods();
    entries.add(entry);

    final jsonList = entries.map((e) => e.toJson()).toList();
    await prefs.setString(_moodKey, jsonEncode(jsonList));
    await prefs.setString(_currentMoodKey, mood);

    // Increment activity trackers
    await StatsStorage.addGrowthPoints(10); // 10 points for logging mood
    await WeeklyActivityStorage.incrementTodayActivity();
    await MonthlyActivityStorage.incrementTodayActivity();
  }

  // Get all mood entries
  static Future<List<MoodEntry>> getAllMoods() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_moodKey);

    if (jsonString == null) return [];

    final List<dynamic> jsonList = jsonDecode(jsonString);
    return jsonList.map((json) => MoodEntry.fromJson(json)).toList();
  }

  // Get recent moods with limit - Returns Map for backward compatibility
  static Future<List<Map<String, dynamic>>> getRecentMoods(
      {int limit = 10}) async {
    final allMoods = await getAllMoods();
    if (allMoods.isEmpty) return [];

    // Sort by timestamp (newest first)
    allMoods.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return allMoods.take(limit).map((e) => e.toJson()).toList();
  }

  // Get current mood
  static Future<String?> getCurrentMood() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_currentMoodKey);
  }

  // Get moods by date range
  static Future<List<MoodEntry>> getMoodsByDateRange(
      DateTime start, DateTime end) async {
    final allMoods = await getAllMoods();
    return allMoods
        .where((entry) =>
            entry.timestamp.isAfter(start) && entry.timestamp.isBefore(end))
        .toList();
  }

  // Get today's moods
  static Future<List<MoodEntry>> getTodayMoods() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    return getMoodsByDateRange(startOfDay, endOfDay);
  }

  // Get week moods
  static Future<List<MoodEntry>> getWeekMoods() async {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final startOfWeekDay =
        DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
    return getMoodsByDateRange(
        startOfWeekDay, now.add(const Duration(days: 1)));
  }

  // Get month moods
  static Future<List<MoodEntry>> getMonthMoods() async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    return getMoodsByDateRange(startOfMonth, now.add(const Duration(days: 1)));
  }

  // Get mood streak (consecutive unique days)
  static Future<int> getMoodStreak() async {
    final allMoods = await getAllMoods();
    if (allMoods.isEmpty) return 0;

    // Extract unique days (YYYY-MM-DD) and sort newest first
    final uniqueDays = allMoods.map((m) {
      return DateTime(m.timestamp.year, m.timestamp.month, m.timestamp.day);
    }).toSet().toList();
    
    uniqueDays.sort((a, b) => b.compareTo(a));

    if (uniqueDays.isEmpty) return 0;

    // Check if streak is still active (logged today or yesterday)
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    
    if (uniqueDays[0].isBefore(yesterday)) {
      return 0; // Streak broken
    }

    int streak = 1;
    for (int i = 0; i < uniqueDays.length - 1; i++) {
      if (uniqueDays[i].difference(uniqueDays[i + 1]).inDays == 1) {
        streak++;
      } else {
        break;
      }
    }

    return streak;
  }

  // Count unique days in a given list of moods
  static int countUniqueDays(List<MoodEntry> moods) {
    return moods.map((m) {
      return DateTime(m.timestamp.year, m.timestamp.month, m.timestamp.day);
    }).toSet().length;
  }

  // Get mood distribution
  static Future<Map<String, int>> getMoodDistribution() async {
    final allMoods = await getAllMoods();
    final distribution = <String, int>{};

    for (var entry in allMoods) {
      distribution[entry.mood] = (distribution[entry.mood] ?? 0) + 1;
    }

    return distribution;
  }

  // Update mood streak
  static Future<void> updateMoodStreak() async {
    final todayMoods = await getTodayMoods();
    if (todayMoods.isNotEmpty) {
      await getMoodStreak();
    }
  }

  // Get today's mood (compatibility with Home UI)
  static Future<String> loadTodayMood() async {
    final prefs = await SharedPreferences.getInstance();
    const dateKey = 'saathi_mood_date';
    const moodKey = 'saathi_mood_today';
    final savedDate = prefs.getString(dateKey) ?? '';
    final today = DateTime.now().toString().split(' ')[0];
    if (savedDate == today) return prefs.getString(moodKey) ?? '';
    return '';
  }

  // Save today's mood (compatibility with Home UI)
  static Future<void> saveTodayMood(String mood) async {
    final prefs = await SharedPreferences.getInstance();
    const dateKey = 'saathi_mood_date';
    const moodKey = 'saathi_mood_today';
    final today = DateTime.now().toString().split(' ')[0];
    await prefs.setString(moodKey, mood);
    await prefs.setString(dateKey, today);
    
    // Also save to recent moods list
    await saveMood(mood);
  }

  // Get total mood log count for garden growth
  static Future<int> getTotalMoodCount() async {
    final allMoods = await getAllMoods();
    return allMoods.length;
  }

  static Future<void> clearAllMoods() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_moodKey);
    await prefs.remove(_currentMoodKey);
    await prefs.remove('saathi_mood_date');
    await prefs.remove('saathi_mood_today');
  }
}
