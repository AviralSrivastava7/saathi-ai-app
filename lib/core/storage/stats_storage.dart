import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

// ============================================================
// APP STATS (in-memory cache)
// ============================================================
class AppStats {
  static int streakDays = 0;
  static int meditationMinutes = 0;
  static int journalEntries = 0;
  static int tasksCompleted = 0;
  static int growthPoints = 0;
  static String selectedMood = '';
}

// ============================================================
// PERSISTENT STATS STORAGE
// ============================================================
class StatsStorage {
  static const String _streakKey = 'saathi_streak_days';
  static const String _streakDateKey = 'saathi_streak_last_date';
  static const String _medKey = 'saathi_meditation_minutes';
  static const String _journalKey = 'saathi_journal_entries';
  static const String _tasksKey = 'saathi_tasks_completed';
  static const String _growthKey = 'saathi_growth_points';

  static Future<void> loadAllStats() async {
    final prefs = await SharedPreferences.getInstance();
    final lastDate = prefs.getString(_streakDateKey) ?? '';
    final today = DateTime.now().toString().split(' ')[0];
    final savedStreak = prefs.getInt(_streakKey) ?? 0;

    if (lastDate == today) {
      AppStats.streakDays = savedStreak;
    } else if (lastDate.isNotEmpty) {
      final lastDateTime = DateTime.parse(lastDate);
      final todayDateTime = DateTime.parse(today);
      final diff = todayDateTime.difference(lastDateTime).inDays;
      if (diff == 1) {
        AppStats.streakDays = savedStreak + 1;
      } else {
        AppStats.streakDays = 1;
      }
    } else {
      AppStats.streakDays = 1;
    }
    await prefs.setInt(_streakKey, AppStats.streakDays);
    await prefs.setString(_streakDateKey, today);

    AppStats.meditationMinutes = prefs.getInt(_medKey) ?? 0;
    AppStats.journalEntries = prefs.getInt(_journalKey) ?? 0;
    AppStats.tasksCompleted = prefs.getInt(_tasksKey) ?? 0;
    AppStats.growthPoints = prefs.getInt(_growthKey) ?? 0;
  }

  static Future<void> saveMeditationMinutes(int mins) async {
    final prefs = await SharedPreferences.getInstance();
    AppStats.meditationMinutes += mins;
    await prefs.setInt(_medKey, AppStats.meditationMinutes);
  }

  static Future<void> saveJournalEntry() async {
    final prefs = await SharedPreferences.getInstance();
    AppStats.journalEntries++;
    await prefs.setInt(_journalKey, AppStats.journalEntries);
    await WeeklyActivityStorage.incrementTodayActivity();
    await MonthlyActivityStorage.incrementTodayActivity();
  }

  static Future<void> saveTaskCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    AppStats.tasksCompleted++;
    await prefs.setInt(_tasksKey, AppStats.tasksCompleted);
    await addGrowthPoints(5); // 5 points for a task
    await WeeklyActivityStorage.incrementTodayActivity();
    await MonthlyActivityStorage.incrementTodayActivity();
  }

  static Future<void> addGrowthPoints(int points) async {
    final prefs = await SharedPreferences.getInstance();
    AppStats.growthPoints += points;
    await prefs.setInt(_growthKey, AppStats.growthPoints);
  }
}

// ============================================================
// WEEKLY ACTIVITY STORAGE
// ============================================================
class WeeklyActivityStorage {
  static const String _key = 'saathi_weekly_activity';

  static Future<Map<String, double>> loadWeeklyData() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    final now = DateTime.now();
    final currentWeekStart = _getWeekStart(now);

    if (raw == null) return _initializeWeek(currentWeekStart);

    try {
      final data = jsonDecode(raw) as Map<String, dynamic>;
      final savedWeekStart = data['weekStart'] as String;
      if (savedWeekStart == currentWeekStart) {
        return Map<String, double>.from(data['activities'] as Map);
      } else {
        return _initializeWeek(currentWeekStart);
      }
    } catch (_) {
      return _initializeWeek(currentWeekStart);
    }
  }

  static Future<void> saveWeeklyData(Map<String, double> activities) async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final currentWeekStart = _getWeekStart(now);
    final data = {
      'weekStart': currentWeekStart,
      'activities': activities,
    };
    await prefs.setString(_key, jsonEncode(data));
  }

  static Future<void> incrementTodayActivity([double amount = 1.0]) async {
    final activities = await loadWeeklyData();
    final today = _getDayKey(DateTime.now());
    activities[today] = (activities[today] ?? 0) + amount;
    await saveWeeklyData(activities);
  }

  static String _getWeekStart(DateTime date) {
    final monday = date.subtract(Duration(days: date.weekday - 1));
    return '${monday.year}-${monday.month.toString().padLeft(2, '0')}-${monday.day.toString().padLeft(2, '0')}';
  }

  static String _getDayKey(DateTime date) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[date.weekday - 1];
  }

  static Map<String, double> _initializeWeek(String weekStart) {
    return {'Mon': 0, 'Tue': 0, 'Wed': 0, 'Thu': 0, 'Fri': 0, 'Sat': 0, 'Sun': 0};
  }

  static Map<String, double> normalizeForGraph(Map<String, double> activities) {
    final values = activities.values.toList();
    final maxValue = values.fold(0.0, (a, b) => a > b ? a : b);
    if (maxValue == 0) {
      return activities.map((key, value) => MapEntry(key, 0.1));
    }
    return activities.map((key, value) =>
        MapEntry(key, (value / maxValue * 0.8) + 0.2));
  }
}

// ============================================================
// MONTHLY ACTIVITY STORAGE
// ============================================================
class MonthlyActivityStorage {
  static const String _key = 'saathi_monthly_activity';

  static Future<Map<String, double>> loadMonthlyData() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    final now = DateTime.now();
    final currentMonthKey = _getMonthKey(now);

    if (raw == null) return _initializeMonth();

    try {
      final data = jsonDecode(raw) as Map<String, dynamic>;
      final savedMonthKey = data['monthKey'] as String;
      if (savedMonthKey == currentMonthKey) {
        return Map<String, double>.from(data['activities'] as Map);
      } else {
        return _initializeMonth();
      }
    } catch (_) {
      return _initializeMonth();
    }
  }

  static Future<void> saveMonthlyData(Map<String, double> activities) async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final currentMonthKey = _getMonthKey(now);
    final data = {
      'monthKey': currentMonthKey,
      'activities': activities,
    };
    await prefs.setString(_key, jsonEncode(data));
  }

  static Future<void> incrementTodayActivity([double amount = 1.0]) async {
    final activities = await loadMonthlyData();
    final weekLabel = _getWeekLabel(DateTime.now());
    activities[weekLabel] = (activities[weekLabel] ?? 0) + amount;
    await saveMonthlyData(activities);
  }

  static String _getMonthKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}';
  }

  static String _getWeekLabel(DateTime date) {
    final weekOfMonth = ((date.day - 1) ~/ 7) + 1;
    return 'Week $weekOfMonth';
  }

  static Map<String, double> _initializeMonth() {
    return {'Week 1': 0, 'Week 2': 0, 'Week 3': 0, 'Week 4': 0, 'Week 5': 0};
  }
}
