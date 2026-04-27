// ========================================
// FIXED FILE: mood_tracker_screen.dart
// ========================================
// Location: lib/features/mood/mood_tracker_screen.dart

import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/zen_aura_background.dart';
import '../../core/localization/app_localizations.dart';

class MoodTrackerScreen extends StatefulWidget {
  const MoodTrackerScreen({super.key});

  @override
  State<MoodTrackerScreen> createState() => _MoodTrackerScreenState();
}

class _MoodTrackerScreenState extends State<MoodTrackerScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<MoodEntry> _moodHistory = [];
  bool _isLoading = true;

  // ✅✅✅ EMOJI FIX - Proper Unicode emojis ✅✅✅
  final List<Map<String, dynamic>> _moods = [
    {
      'emoji': '😊',
      'name': 'Happy',
      'color': const Color(0xFFFFD700)
    }, // ✅ FIXED
    {
      'emoji': '😌',
      'name': 'Calm',
      'color': const Color(0xFF14B8A6)
    }, // ✅ FIXED
    {'emoji': '😢', 'name': 'Sad', 'color': const Color(0xFF60A5FA)}, // ✅ FIXED
    {
      'emoji': '😰',
      'name': 'Anxious',
      'color': const Color(0xFFF87171)
    }, // ✅ FIXED
    {
      'emoji': '😠',
      'name': 'Angry',
      'color': const Color(0xFFEF4444)
    }, // ✅ FIXED
    {
      'emoji': '😐',
      'name': 'Neutral',
      'color': const Color(0xFF9CA3AF)
    }, // ✅ FIXED
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadMoodHistory();
  }

  Future<void> _loadMoodHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final String? historyJson = prefs.getString('mood_history');

    if (historyJson != null) {
      final List<dynamic> decoded = jsonDecode(historyJson);
      setState(() {
        _moodHistory = decoded.map((e) => MoodEntry.fromMap(e)).toList();
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveMoodEntry(String mood, String? note) async {
    final entry = MoodEntry(mood: mood, date: DateTime.now(), note: note);
    _moodHistory.insert(0, entry);

    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(_moodHistory.map((e) => e.toMap()).toList());
    await prefs.setString('mood_history', encoded);

    setState(() {});

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).t('mood_saved')),
          backgroundColor: const Color(0xFF43E97B),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          AppLocalizations.of(context).t('mood_tracker_title'),
          style: AppTextStyles.headingLarge.copyWith(
            fontSize: 22,
            color: Colors.white,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF43E97B),
          labelColor: Colors.white,
          unselectedLabelColor: AppColors.textHint,
          tabs: [
            Tab(text: AppLocalizations.of(context).t('tab_track')),
            Tab(text: AppLocalizations.of(context).t('tab_stats')),
            Tab(text: AppLocalizations.of(context).t('tab_history')),
          ],
        ),
      ),
      body: ZenAuraBackground(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF43E97B)),
                ),
              )
            : TabBarView(
                controller: _tabController,
                children: [
                  _buildTrackTab(),
                  _buildStatsTab(),
                  _buildHistoryTab(),
                ],
              ),
      ),
    );
  }

  Widget _buildTrackTab() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context).t('mood_question'),
              style: AppTextStyles.headingLarge.copyWith(
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context).t('mood_subtitle'),
              style: AppTextStyles.body.copyWith(
                color: AppColors.textHint,
              ),
            ),
            const SizedBox(height: 32),

            // ✅ FIXED: Mood Grid with proper overflow prevention
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio:
                    1.15, // ✅ FIXED: Increased to prevent overflow
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: _moods.length,
              itemBuilder: (context, index) {
                final mood = _moods[index];
                return _buildMoodCard(mood);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodCard(Map<String, dynamic> mood) {
    return GestureDetector(
      onTap: () => _showNoteDialog(mood['name']),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withValues(alpha: 0.15), // ✅ FIXED
                  Colors.white.withValues(alpha: 0.05), // ✅ FIXED
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color:
                    (mood['color'] as Color).withValues(alpha: 0.3), // ✅ FIXED
                width: 2,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  mood['emoji'], // ✅ Now showing proper emojis!
                  style: const TextStyle(fontSize: 48), // ✅ Slightly reduced
                ),
                const SizedBox(height: 8),
                Text(
                  AppLocalizations.of(context).t(mood['name'].toString().toLowerCase()),
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showNoteDialog(String mood) {
    final TextEditingController noteController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(
          AppLocalizations.of(context).t('add_note_title'),
          style: AppTextStyles.headingSmall.copyWith(color: Colors.white),
        ),
        content: TextField(
          controller: noteController,
          style: const TextStyle(color: Colors.white),
          maxLines: 3,
          decoration: InputDecoration(
            hintText: AppLocalizations.of(context).t('mood_note_hint'),
            hintStyle: const TextStyle(color: AppColors.textHint),
            filled: true,
            fillColor: AppColors.backgroundMid,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              AppLocalizations.of(context).t('cancel'),
              style: const TextStyle(color: AppColors.textHint),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              _saveMoodEntry(
                  mood,
                  noteController.text.trim().isEmpty
                      ? null
                      : noteController.text);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF43E97B),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(AppLocalizations.of(context).t('save'), style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsTab() {
    if (_moodHistory.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.insert_chart_outlined,
              size: 80,
              color: AppColors.textHint,
            ),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context).t('no_mood_data'),
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textHint,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context).t('start_tracking_stats'),
              style: AppTextStyles.body.copyWith(
                color: AppColors.textHint.withValues(alpha: 0.7), // ✅ FIXED
              ),
            ),
          ],
        ),
      );
    }

    // Calculate stats
    final moodCounts = <String, int>{};
    for (var entry in _moodHistory) {
      moodCounts[entry.mood] = (moodCounts[entry.mood] ?? 0) + 1;
    }

    final mostCommonMood =
        moodCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key;
    final totalEntries = _moodHistory.length;

    // Calculate current streak
    int currentStreak = 0;
    DateTime? lastDate;
    for (var entry in _moodHistory) {
      if (lastDate == null ||
          (lastDate.difference(entry.date).inDays == 0 ||
              lastDate.difference(entry.date).inDays == 1)) {
        currentStreak++;
        lastDate = entry.date;
      } else {
        break;
      }
    }

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context).t('mood_stats_title'),
              style: AppTextStyles.headingLarge.copyWith(
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),

            // Stats Cards
            _buildStatCard(
              icon: Icons.calendar_today,
              title: AppLocalizations.of(context).t('total_entries'),
              value: totalEntries.toString(),
              color: const Color(0xFF43E97B),
            ),
            const SizedBox(height: 16),
            _buildStatCard(
              icon: Icons.mood,
              title: AppLocalizations.of(context).t('most_common'),
              value: AppLocalizations.of(context).t(mostCommonMood.toLowerCase()),
              color: const Color(0xFFFFD700),
            ),
            const SizedBox(height: 16),
            _buildStatCard(
              icon: Icons.local_fire_department,
              title: AppLocalizations.of(context).t('current_streak'),
              value: '$currentStreak ${AppLocalizations.of(context).t('days_label')}',
              color: const Color(0xFFF97316),
            ),
            const SizedBox(height: 32),

            // Mood Distribution
            Text(
              AppLocalizations.of(context).t('mood_distribution'),
              style: AppTextStyles.headingSmall.copyWith(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),

            ...moodCounts.entries.map((entry) {
              final percentage =
                  (entry.value / totalEntries * 100).toStringAsFixed(0);
              final moodData = _moods.firstWhere((m) => m['name'] == entry.key);

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          moodData['emoji'],
                          style: const TextStyle(fontSize: 20),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          AppLocalizations.of(context).t(entry.key.toLowerCase()),
                          style: AppTextStyles.body.copyWith(
                            color: Colors.white,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '$percentage%',
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.textHint,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: entry.value / totalEntries,
                        backgroundColor: AppColors.backgroundMid,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          moodData['color'] as Color,
                        ),
                        minHeight: 8,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white.withValues(alpha: 0.15), // ✅ FIXED
                Colors.white.withValues(alpha: 0.05), // ✅ FIXED
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: color.withValues(alpha: 0.3), // ✅ FIXED
              width: 2,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2), // ✅ FIXED
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.textHint,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryTab() {
    if (_moodHistory.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.history,
              size: 80,
              color: AppColors.textHint,
            ),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context).t('no_mood_history'),
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textHint,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context).t('start_tracking_history'),
              style: AppTextStyles.body.copyWith(
                color: AppColors.textHint.withValues(alpha: 0.7), // ✅ FIXED
              ),
            ),
          ],
        ),
      );
    }

    return SafeArea(
      child: ListView.builder(
        padding: const EdgeInsets.all(24),
        itemCount: _moodHistory.length,
        itemBuilder: (context, index) {
          final entry = _moodHistory[index];
          final moodData = _moods.firstWhere((m) => m['name'] == entry.mood);

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withValues(alpha: 0.15), // ✅ FIXED
                        Colors.white.withValues(alpha: 0.05), // ✅ FIXED
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: (moodData['color'] as Color)
                          .withValues(alpha: 0.3), // ✅ FIXED
                      width: 2,
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        moodData['emoji'],
                        style: const TextStyle(fontSize: 32),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppLocalizations.of(context).t(entry.mood.toLowerCase()),
                              style: AppTextStyles.bodyLarge.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _formatDate(context, entry.date),
                              style: AppTextStyles.body.copyWith(
                                color: AppColors.textHint,
                                fontSize: 13,
                              ),
                            ),
                            if (entry.note != null &&
                                entry.note!.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Text(
                                entry.note!,
                                style: AppTextStyles.body.copyWith(
                                  color: Colors.white
                                      .withValues(alpha: 0.8), // ✅ FIXED
                                  fontSize: 13,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  String _formatDate(BuildContext context, DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    final localization = AppLocalizations.of(context);

    if (difference.inDays == 0) {
      return '${localization.t('today')}, ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return localization.t('yesterday');
    } else if (difference.inDays < 7) {
      return localization.t('days_ago', {'val': difference.inDays.toString()});
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}

// ============ MOOD ENTRY MODEL ============
class MoodEntry {
  final String mood;
  final DateTime date;
  final String? note;

  MoodEntry({
    required this.mood,
    required this.date,
    this.note,
  });

  Map<String, dynamic> toMap() {
    return {
      'mood': mood,
      'date': date.toIso8601String(),
      'note': note,
    };
  }

  factory MoodEntry.fromMap(Map<String, dynamic> map) {
    return MoodEntry(
      mood: map['mood'],
      date: DateTime.parse(map['date']),
      note: map['note'],
    );
  }
}
