import 'package:flutter/material.dart';
import '../../core/widgets/zen_aura_background.dart';
import '../../core/widgets/glass_card.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/storage/mood_storage.dart';
import '../journal/services/journal_service.dart';

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  List<Achievement> _achievements = [];
  int _totalPoints = 0;
  int _unlockedCount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAchievements();
  }

  Future<void> _loadAchievements() async {
    if (mounted) setState(() => _isLoading = true);

    try {
      final rawMoods = await MoodStorage.getAllMoods();
      final moods = rawMoods.map((m) => m.toJson()).toList();

      final journalService = JournalService();
      final journalEntries = await journalService.getAllEntries();

      final prefs = await SharedPreferences.getInstance();
      final currentStreak = await MoodStorage.getMoodStreak();

      List<Achievement> achievements = [
        Achievement(id: 'first_checkin', titleKey: 'ach_first_step', descKey: 'ach_first_step_desc', icon: '🌱', points: 10, isUnlocked: moods.isNotEmpty, categoryKey: 'beginner'),
        Achievement(id: 'first_journal', titleKey: 'ach_writers_beginning', descKey: 'ach_writers_beginning_desc', icon: '✍️', points: 15, isUnlocked: journalEntries.isNotEmpty, categoryKey: 'beginner'),
        Achievement(id: 'first_game', titleKey: 'ach_playful_mind', descKey: 'ach_playful_mind_desc', icon: '🎮', points: 10, isUnlocked: prefs.getBool('played_game') ?? false, categoryKey: 'beginner'),
        Achievement(id: 'journal_5', titleKey: 'ach_journal_explorer', descKey: 'ach_journal_explorer_desc', icon: '📝', points: 20, isUnlocked: journalEntries.length >= 5, categoryKey: 'beginner'),
        Achievement(id: 'night_owl', titleKey: 'ach_night_owl', descKey: 'ach_night_owl_desc', icon: '🦉', points: 15, isUnlocked: moods.any((m) { try { final d = DateTime.tryParse((m['timestamp'] ?? '').toString()); return d != null && d.hour >= 23; } catch (_) { return false; } }), categoryKey: 'beginner'),
        Achievement(id: 'streak_3', titleKey: 'ach_3day_warrior', descKey: 'ach_3day_warrior_desc', icon: '🔥', points: 25, isUnlocked: currentStreak >= 3, categoryKey: 'consistency'),
        Achievement(id: 'streak_5', titleKey: 'ach_5day_fire', descKey: 'ach_5day_fire_desc', icon: '🔥', points: 35, isUnlocked: currentStreak >= 5, categoryKey: 'consistency'),
        Achievement(id: 'streak_7', titleKey: 'ach_week_champion', descKey: 'ach_week_champion_desc', icon: '⭐', points: 50, isUnlocked: currentStreak >= 7, categoryKey: 'consistency'),
        Achievement(id: 'streak_10', titleKey: 'ach_10day_legend', descKey: 'ach_10day_legend_desc', icon: '💪', points: 60, isUnlocked: currentStreak >= 10, categoryKey: 'consistency'),
        Achievement(id: 'streak_14', titleKey: 'ach_two_week_hero', descKey: 'ach_two_week_hero_desc', icon: '🦸', points: 70, isUnlocked: currentStreak >= 14, categoryKey: 'consistency'),
        Achievement(id: 'streak_30', titleKey: 'ach_monthly_master', descKey: 'ach_monthly_master_desc', icon: '👑', points: 100, isUnlocked: currentStreak >= 30, categoryKey: 'consistency'),
        Achievement(id: 'happy_10', titleKey: 'ach_happiness_seeker', descKey: 'ach_happiness_seeker_desc', icon: '😊', points: 30, isUnlocked: _countMood(moods, 'happy') >= 10, categoryKey: 'wellness'),
        Achievement(id: 'calm_10', titleKey: 'ach_inner_peace', descKey: 'ach_inner_peace_desc', icon: '🧘', points: 30, isUnlocked: _countMood(moods, 'calm') >= 10, categoryKey: 'wellness'),
        Achievement(id: 'sad_awareness', titleKey: 'ach_self_awareness', descKey: 'ach_self_awareness_desc', icon: '💙', points: 25, isUnlocked: _countMood(moods, 'sad') >= 5, categoryKey: 'wellness'),
        Achievement(id: 'journal_10', titleKey: 'ach_thoughtful_writer', descKey: 'ach_thoughtful_writer_desc', icon: '📓', points: 30, isUnlocked: journalEntries.length >= 10, categoryKey: 'wellness'),
        Achievement(id: 'journal_20', titleKey: 'ach_prolific_writer', descKey: 'ach_prolific_writer_desc', icon: '📖', points: 40, isUnlocked: journalEntries.length >= 20, categoryKey: 'wellness'),
        Achievement(id: 'entries_25', titleKey: 'ach_getting_serious', descKey: 'ach_getting_serious_desc', icon: '✅', points: 40, isUnlocked: moods.length >= 25, categoryKey: 'wellness'),
        Achievement(id: 'all_games', titleKey: 'ach_game_master', descKey: 'ach_game_master_desc', icon: '🏆', points: 35, isUnlocked: prefs.getBool('played_all_games') ?? false, categoryKey: 'wellness'),
        Achievement(id: 'entries_50', titleKey: 'ach_dedicated_soul', descKey: 'ach_dedicated_soul_desc', icon: '💎', points: 75, isUnlocked: moods.length >= 50, categoryKey: 'advanced'),
        Achievement(id: 'entries_100', titleKey: 'ach_century_club', descKey: 'ach_century_club_desc', icon: '🎯', points: 150, isUnlocked: moods.length >= 100, categoryKey: 'advanced'),
        Achievement(id: 'all_moods', titleKey: 'ach_emotional_explorer', descKey: 'ach_emotional_explorer_desc', icon: '🌈', points: 60, isUnlocked: _hasAllMoods(moods), categoryKey: 'advanced'),
        Achievement(id: 'streak_60', titleKey: 'ach_60day_titan', descKey: 'ach_60day_titan_desc', icon: '🏅', points: 200, isUnlocked: currentStreak >= 60, categoryKey: 'advanced'),
        Achievement(id: 'happy_25', titleKey: 'ach_joy_spreader', descKey: 'ach_joy_spreader_desc', icon: '🌟', points: 50, isUnlocked: _countMood(moods, 'happy') >= 25, categoryKey: 'advanced'),
        Achievement(id: 'journal_50', titleKey: 'ach_master_journalist', descKey: 'ach_master_journalist_desc', icon: '📚', points: 80, isUnlocked: journalEntries.length >= 50, categoryKey: 'advanced'),
        Achievement(id: 'entries_200', titleKey: 'ach_saathi_legend', descKey: 'ach_saathi_legend_desc', icon: '🔱', points: 250, isUnlocked: moods.length >= 200, categoryKey: 'advanced'),
      ];

      int points = 0;
      int unlocked = 0;
      for (var a in achievements) {
        if (a.isUnlocked) { points += a.points; unlocked++; }
      }

      if (mounted) {
        setState(() {
          _achievements = achievements;
          _totalPoints = points;
          _unlockedCount = unlocked;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  int _countMood(List<Map<String, dynamic>> moods, String type) {
    return moods.where((m) => (m['mood'] ?? '').toString().toLowerCase().contains(type)).length;
  }

  bool _hasAllMoods(List<Map<String, dynamic>> moods) {
    final types = moods.map((m) => (m['mood'] ?? '').toString().toLowerCase()).toSet();
    return types.any((t) => t.contains('happy')) && types.any((t) => t.contains('sad')) && types.any((t) => t.contains('calm')) && types.any((t) => t.contains('anxious'));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final loc = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(loc.t('achievements'), style: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.w900, fontSize: 28, letterSpacing: -1)),
        actions: [
          IconButton(
            onPressed: _loadAchievements,
            icon: Icon(Icons.refresh_rounded, color: colorScheme.onSurface),
          ),
        ],
      ),
      body: ZenAuraBackground(
        child: _isLoading
          ? Center(child: CircularProgressIndicator(color: colorScheme.primary))
          : RefreshIndicator(
              onRefresh: _loadAchievements,
              color: colorScheme.primary,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.only(left: 20, right: 20, top: 100, bottom: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Summary Hero Card
                    Container(
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [colorScheme.primary, colorScheme.primary.withOpacity(0.7)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: colorScheme.primary.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _summaryColumn('🏆', '$_unlockedCount/${_achievements.length}', loc.t('unlocked')),
                          Container(width: 1.5, height: 60, color: Colors.white.withOpacity(0.3)),
                          _summaryColumn('⭐', '$_totalPoints', loc.t('points')),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Progress Bar
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(loc.t('progress'), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: colorScheme.onSurface)),
                            Text('${(_achievements.isEmpty ? 0 : (_unlockedCount / _achievements.length * 100)).toInt()}%', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: colorScheme.primary)),
                          ],
                        ),
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: _achievements.isEmpty ? 0 : _unlockedCount / _achievements.length,
                            backgroundColor: colorScheme.onSurface.withOpacity(0.08),
                            color: colorScheme.primary,
                            minHeight: 10,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Achievement Lists by Category
                    ...['beginner', 'consistency', 'wellness', 'advanced'].map((categoryKey) {
                      final items = _achievements.where((a) => a.categoryKey == categoryKey).toList();
                      if (items.isEmpty) return const SizedBox.shrink();
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(loc.t(categoryKey), style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: colorScheme.onSurface.withOpacity(0.6), letterSpacing: -0.5)),
                          const SizedBox(height: 12),
                          ...items.map((a) => _achievementCard(context, a, loc)),
                          const SizedBox(height: 24),
                        ],
                      );
                    }),
                  ],
                ),
              ),
            ),
      ),
    );
  }

  Widget _summaryColumn(String emoji, String value, String label) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 32)),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13)),
      ],
    );
  }

  Widget _achievementCard(BuildContext context, Achievement a, AppLocalizations loc) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        borderRadius: 20,
        opacity: a.isUnlocked ? 0.12 : 0.06,
        border: Border.all(
          color: a.isUnlocked ? colorScheme.primary.withOpacity(0.25) : colorScheme.onSurface.withOpacity(0.05),
          width: 1.5,
        ),
        child: Row(
          children: [
            Container(
              width: 52, height: 52,
              decoration: BoxDecoration(
                gradient: a.isUnlocked ? LinearGradient(colors: [colorScheme.primary, colorScheme.primary.withOpacity(0.6)]) : null,
                color: a.isUnlocked ? null : colorScheme.onSurface.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Center(child: Text(a.icon, style: TextStyle(fontSize: 24, color: a.isUnlocked ? null : colorScheme.onSurface.withOpacity(0.3)))),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(loc.t(a.titleKey), style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: a.isUnlocked ? colorScheme.onSurface : colorScheme.onSurface.withOpacity(0.4))),
                  const SizedBox(height: 4),
                  Text(loc.t(a.descKey), style: TextStyle(fontSize: 13, color: colorScheme.onSurface.withOpacity(a.isUnlocked ? 0.6 : 0.3))),
                ],
              ),
            ),
            if (a.isUnlocked)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [colorScheme.primary, colorScheme.primary.withOpacity(0.7)]),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text('+${a.points}', style: const TextStyle(fontSize: 13, color: Colors.white, fontWeight: FontWeight.bold)),
              )
            else
              Icon(Icons.lock_outline, color: colorScheme.onSurface.withOpacity(0.2), size: 22),
          ],
        ),
      ),
    );
  }
}

class Achievement {
  final String id, titleKey, descKey, icon, categoryKey;
  final int points;
  final bool isUnlocked;

  Achievement({required this.id, required this.titleKey, required this.descKey, required this.icon, required this.points, required this.isUnlocked, required this.categoryKey});
}
