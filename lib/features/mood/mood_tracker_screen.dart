import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../home/home_screen.dart';
import '../../core/widgets/zen_aura_background.dart';

import '../../core/storage/mood_storage.dart' as storage;
import '../../core/localization/app_localizations.dart';
class MoodTrackerScreen extends StatefulWidget {
  const MoodTrackerScreen({super.key});

  @override
  State<MoodTrackerScreen> createState() => _MoodTrackerScreenState();
}

class _MoodTrackerScreenState extends State<MoodTrackerScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<storage.MoodEntry> _moodHistory = [];
  int _currentStreak = 0;
  bool _isLoading = true;

  final List<Map<String, dynamic>> _moods = [
    {'emoji': '😊', 'name': 'Happy', 'color': const Color(0xFFFFD700)},
    {'emoji': '😌', 'name': 'Calm', 'color': const Color(0xFF14B8A6)},
    {'emoji': '😢', 'name': 'Sad', 'color': const Color(0xFF60A5FA)},
    {'emoji': '😰', 'name': 'Anxious', 'color': const Color(0xFFF87171)},
    {'emoji': '😠', 'name': 'Angry', 'color': const Color(0xFFEF4444)},
    {'emoji': '😐', 'name': 'Neutral', 'color': const Color(0xFF9CA3AF)},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadMoodHistory();
  }

  Future<void> _loadMoodHistory() async {
    final streak = await storage.MoodStorage.getMoodStreak();
    final allMoods = await storage.MoodStorage.getAllMoods();
    
    // Sort by timestamp newest first
    allMoods.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    setState(() {
      _moodHistory = allMoods;
      _currentStreak = streak;
      _isLoading = false;
    });
  }

  Future<void> _saveMoodEntry(String mood, String? note) async {
    await storage.MoodStorage.saveMood(mood, note: note);
    await _loadMoodHistory(); // Refresh list and streak
    
    setState(() {});

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).t('mood_saved')),
          backgroundColor: Color(0xFF43E97B),
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
          'Mood Tracker',
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
          tabs: const [
            Tab(text: 'Track'),
            Tab(text: 'Stats'),
            Tab(text: 'History'),
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
              'How are you feeling?',
              style: AppTextStyles.headingLarge.copyWith(
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Track your mood to understand patterns',
              style: AppTextStyles.body.copyWith(
                color: AppColors.textHint,
              ),
            ),
            const SizedBox(height: 32),

            // Mood Grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.1, // âœ… INCREASED to prevent overflow
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
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            padding: const EdgeInsets.all(16), // âœ… REDUCED padding
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withValues(alpha: 0.15),
                  Colors.white.withValues(alpha: 0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: (mood['color'] as Color).withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  mood['emoji'],
                  style: const TextStyle(fontSize: 52), // âœ… REDUCED size
                ),
                const SizedBox(height: 8), // âœ… REDUCED spacing
                Text(
                  mood['name'],
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 15, // âœ… REDUCED font size
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
          'Add a note (optional)',
          style: AppTextStyles.headingSmall.copyWith(color: Colors.white),
        ),
        content: TextField(
          controller: noteController,
          style: AppTextStyles.body.copyWith(color: Colors.white),
          maxLines: 3,
          decoration: InputDecoration(
            hintText: AppLocalizations.of(context).t('what_on_mind'),
            hintStyle: AppTextStyles.body.copyWith(color: AppColors.textHint),
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
            onPressed: () => _saveMoodEntry(mood, null),
            child: Text(AppLocalizations.of(context).t('skip')),
          ),
          ElevatedButton(
            onPressed: () => _saveMoodEntry(
                mood,
                noteController.text.trim().isEmpty
                    ? null
                    : noteController.text.trim()),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF43E97B),
            ),
            child: Text(AppLocalizations.of(context).t('save')),
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
            const Icon(Icons.bar_chart, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'No data yet',
              style: AppTextStyles.headingSmall.copyWith(color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              'Start tracking your mood to see stats',
              style: AppTextStyles.body.copyWith(color: AppColors.textHint),
            ),
          ],
        ),
      );
    }

    final moodCounts = <String, int>{};
    for (var entry in _moodHistory) {
      moodCounts[entry.mood] = (moodCounts[entry.mood] ?? 0) + 1;
    }

    final total = _moodHistory.length;
    final mostCommon =
        moodCounts.entries.reduce((a, b) => a.value > b.value ? a : b);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Mood Stats',
              style: AppTextStyles.headingLarge.copyWith(color: Colors.white),
            ),
            const SizedBox(height: 24),
            _buildStatCard(
              'Total Entries',
              total.toString(),
              Icons.event_note,
              const Color(0xFF43E97B),
            ),
            const SizedBox(height: 16),
            _buildStatCard(
              'Most Common',
              mostCommon.key,
              Icons.emoji_emotions,
              const Color(0xFF38F9D7),
            ),
            const SizedBox(height: 16),
            _buildStatCard(
              'Current Streak',
              '$_currentStreak days',
              Icons.local_fire_department,
              const Color(0xFFF97316),
            ),
            const SizedBox(height: 24),
            Text(
              'Mood Distribution',
              style: AppTextStyles.headingSmall.copyWith(color: Colors.white),
            ),
            const SizedBox(height: 16),
            ...moodCounts.entries.map((entry) {
              final percentage =
                  ((entry.value / total) * 100).toStringAsFixed(0);
              final moodData = _moods.firstWhere((m) => m['name'] == entry.key);

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(moodData['emoji'],
                                style: const TextStyle(fontSize: 24)),
                            const SizedBox(width: 12),
                            Text(
                              entry.key,
                              style: AppTextStyles.body
                                  .copyWith(color: Colors.white),
                            ),
                          ],
                        ),
                        Text(
                          '$percentage%',
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: entry.value / total,
                        backgroundColor: AppColors.backgroundMid,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(moodData['color']),
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

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white.withValues(alpha: 0.15),
                Colors.white.withValues(alpha: 0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color, color.withValues(alpha: 0.7)],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 16),
              Column(
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
                    style: AppTextStyles.headingSmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Streak is now loaded from MoodStorage in _loadMoodHistory

  Widget _buildHistoryTab() {
    if (_moodHistory.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.history, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'No history yet',
              style: AppTextStyles.headingSmall.copyWith(color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              'Start tracking your mood to see history',
              style: AppTextStyles.body.copyWith(color: AppColors.textHint),
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
          final moodData = _moods.firstWhere(
            (m) => m['name'] == entry.mood,
            orElse: () => _moods[0],
          );

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
            child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withValues(alpha: 0.15),
                        Colors.white.withValues(alpha: 0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color:
                          (moodData['color'] as Color).withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        moodData['emoji'],
                        style: const TextStyle(fontSize: 40),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              entry.mood,
                              style: AppTextStyles.bodyLarge.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _formatDateTime(entry.timestamp),
                              style: AppTextStyles.body.copyWith(
                                color: AppColors.textHint,
                                fontSize: 14,
                              ),
                            ),
                            if (entry.note != null) ...[
                              const SizedBox(height: 8),
                              Text(
                                entry.note!,
                                style: AppTextStyles.body.copyWith(
                                  color: Colors.white70,
                                  fontSize: 14,
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
          );
        },
      ),
    );
  }

  String _formatDateTime(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final entryDate = DateTime(date.year, date.month, date.day);

    if (entryDate == today) {
      return 'Today, ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } else if (entryDate == yesterday) {
      return 'Yesterday, ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } else {
      return '${date.day}/${date.month}/${date.year}, ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _page = 0;
  final PageController _controller = PageController();

  final List<Map<String, String>> _data = [
    {
      "emoji": "ðŸ’™",
      "title": "Namaste, Main Saathi hoon.",
      "desc": "Main sunungi, samjhungi, par kabhi judge nahi karungi."
    },
    {
      "emoji": "ðŸŒ±",
      "title": "Tumhara Safe Space",
      "desc":
          "Chahe mann bhaari ho ya khush, yahan sab kuch share kar sakte ho."
    },
    {
      "emoji": "âœ¨",
      "title": "Chalo shuru karein",
      "desc": "Tum akele nahi ho. Main yahin hoon."
    },
  ];

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_seen', true);

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder: (_, __, ___) => const HomeScreen(),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.1, 0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ZenAuraBackground(
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  onPageChanged: (index) => setState(() => _page = index),
                  itemCount: _data.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(40),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // âœ¨ EMOJI WITH GLOW
                          Container(
                            width: 140,
                            height: 140,
                            decoration: BoxDecoration(
                              gradient: AppColors.primaryGradient,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      AppColors.primary.withValues(alpha: 0.4),
                                  blurRadius: 40,
                                  spreadRadius: 10,
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                _data[index]['emoji']!,
                                style: const TextStyle(fontSize: 64),
                              ),
                            ),
                          ),
                          const SizedBox(height: 60),

                          // ðŸ“ TITLE
                          Text(
                            _data[index]['title']!,
                            style: AppTextStyles.display.copyWith(fontSize: 32),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),

                          // ðŸ’¬ DESCRIPTION
                          ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                              child: Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.05),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.1),
                                  ),
                                ),
                                child: Text(
                                  _data[index]['desc']!,
                                  style: AppTextStyles.bodyLarge.copyWith(
                                    height: 1.6,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // ðŸ”˜ BOTTOM NAVIGATION
              Padding(
                padding: const EdgeInsets.all(32),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // ðŸ“ PAGE INDICATORS
                    Row(
                      children: List.generate(
                        _data.length,
                        (index) => AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.only(right: 8),
                          width: _page == index ? 32 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            gradient: _page == index
                                ? AppColors.primaryGradient
                                : null,
                            color: _page == index
                                ? null
                                : Colors.white.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),

                    // âž¡ï¸ NEXT BUTTON
                    GestureDetector(
                      onTap: () {
                        if (_page < _data.length - 1) {
                          _controller.nextPage(
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeOutCubic,
                          );
                        } else {
                          _finish();
                        }
                      },
                      child: Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.4),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.arrow_forward_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
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
}
