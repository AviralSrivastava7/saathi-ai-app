import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/storage/mood_storage.dart';
import '../../core/storage/stats_storage.dart';
import '../../core/content/daily_tips.dart';
import '../../core/content/daily_thoughts.dart';
import '../../core/widgets/zen_aura_background.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/smooth_page_route.dart';
import '../../core/widgets/animated_toast.dart';
import '../../core/config/app_language.dart';

// Modular Feature Screens
import '../journal/journal_screen.dart' as modular_journal;
import '../profile/profile_screen.dart' as modular_profile;
import '../analytics/analytics_screen.dart';
import '../achievements/achievements_screen.dart';
import '../tools/tools_screen.dart';
import './widgets/saathi_garden_widget.dart';
import '../pet/pet_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override State<HomeScreen> createState() => _HomeScreenState();
}
class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  late final PageController _pageController;
  DateTime? _lastBackPress;

  final List<Widget> _screens = const [
    _KeepAliveTab(child: MainHomeScreen()),
    _KeepAliveTab(child: ToolsScreen()),
    _KeepAliveTab(child: modular_journal.JournalScreen()),
    _KeepAliveTab(child: modular_profile.ProfileScreen()),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() => _currentIndex = index);
  }

  void _onNavTap(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  }

  /// Smart back button: go to home tab first, then double-tap to exit
  Future<bool> _handleBackPress() async {
    // If not on home tab, go to home tab
    if (_currentIndex != 0) {
      _onNavTap(0);
      return false;
    }

    // On home tab: check for double-tap
    final now = DateTime.now();
    if (_lastBackPress != null && now.difference(_lastBackPress!) < const Duration(seconds: 2)) {
      SystemNavigator.pop();
      return true;
    }

    _lastBackPress = now;
    if (mounted) {
      final loc = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.t('press_back_exit'), textAlign: TextAlign.center),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.only(bottom: 20, left: 50, right: 50),
          backgroundColor: Colors.purple.shade700,
        ),
      );
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final loc = AppLocalizations.of(context);
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        await _handleBackPress();
      },
      child: Scaffold(
        body: PageView(
          controller: _pageController,
          physics: const BouncingScrollPhysics(),
          onPageChanged: _onPageChanged,
          children: _screens,
        ),
        floatingActionButton: _AnimatedBuddyFAB(
          onPressed: () => Navigator.push(context, smoothPageRoute(page: const PetScreen())),
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onNavTap,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.purple,
          unselectedItemColor: Colors.grey,
          backgroundColor: isDark ? const Color(0xFF16213E) : Colors.white,
          items: [
            BottomNavigationBarItem(icon: const Icon(Icons.home_outlined), activeIcon: const Icon(Icons.home), label: loc.t('nav_home')),
            BottomNavigationBarItem(icon: const Icon(Icons.category_outlined), activeIcon: const Icon(Icons.category), label: loc.t('nav_tools')),
            BottomNavigationBarItem(icon: const Icon(Icons.book_outlined), activeIcon: const Icon(Icons.book), label: loc.t('nav_journal')),
            BottomNavigationBarItem(icon: const Icon(Icons.person_outline), activeIcon: const Icon(Icons.person), label: loc.t('nav_profile')),
          ],
        ),
      ),
    );
  }
}

/// Keeps tab alive so scroll position / state is preserved across switches.
class _KeepAliveTab extends StatefulWidget {
  final Widget child;
  const _KeepAliveTab({required this.child});
  @override
  State<_KeepAliveTab> createState() => _KeepAliveTabState();
}

class _KeepAliveTabState extends State<_KeepAliveTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}

class MainHomeScreen extends StatefulWidget {
  const MainHomeScreen({super.key});
  @override State<MainHomeScreen> createState() => _MainHomeScreenState();
}
class _MainHomeScreenState extends State<MainHomeScreen> {
  String _selectedMood = '';

  @override
  void initState() {
    super.initState();
    _loadMood();
  }

  Future<void> _loadMood() async {
    final mood = await MoodStorage.loadTodayMood();
    if (mounted) {
      setState(() {
        _selectedMood = mood;
        AppStats.selectedMood = mood;
      });
    }
  }

  String _getGreeting(AppLocalizations loc) {
    final hour = DateTime.now().hour;
    if (hour < 12) return loc.t('good_morning');
    if (hour < 17) return loc.t('good_afternoon');
    return loc.t('good_evening');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final todayTip = DailyTips.today(AppLanguage.instance.current);
    final todayThought = DailyThoughts.today(AppLanguage.instance.current);
    final loc = AppLocalizations.of(context);

    final moodItems = [
      {'emoji': '😊', 'key': 'happy', 'id': 'Happy'},
      {'emoji': '😌', 'key': 'calm', 'id': 'Calm'},
      {'emoji': '😐', 'key': 'neutral', 'id': 'Neutral'},
      {'emoji': '😔', 'key': 'sad', 'id': 'Sad'},
      {'emoji': '😰', 'key': 'anxious', 'id': 'Anxious'},
      {'emoji': '😠', 'key': 'angry', 'id': 'Angry'},
    ];
    
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ZenAuraBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 32),
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_getGreeting(loc), style: TextStyle(fontSize: 16, color: colorScheme.onSurface.withOpacity(0.6))),
                          Text(loc.t('saathi_user'), style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: colorScheme.onSurface, letterSpacing: -0.5)),
                        ],
                      ),
                      GlassCard(
                        padding: EdgeInsets.zero,
                        borderRadius: 24,
                        child: CircleAvatar(radius: 24, backgroundColor: Colors.transparent, child: Icon(Icons.person, color: colorScheme.primary)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  SaathiGardenWidget(key: ValueKey('garden_$_selectedMood')),
                  const SizedBox(height: 32),
                  // Mood Check
                  _sectionHeader(loc.t('how_are_you'), context),
                  const SizedBox(height: 16),
                  GlassCard(
                    padding: const EdgeInsets.all(24),
                    child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: moodItems.map((m) => _moodIcon(m['emoji']!, m['id']!, loc.t(m['key']!))).toList()),
                  ),
                  const SizedBox(height: 32),
                  // Daily Inspiration
                  _sectionHeader(loc.t('daily_mindfulness'), context),
                  const SizedBox(height: 16),
                  GlassCard(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Icon(Icons.auto_awesome, color: colorScheme.primary, size: 20),
                          const SizedBox(width: 12),
                          Text(loc.t('daily_thought_label'), style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: colorScheme.primary, letterSpacing: 1.2)),
                        ]),
                        const SizedBox(height: 16),
                        Text(todayThought, style: TextStyle(fontSize: 18, color: colorScheme.onSurface, fontWeight: FontWeight.w500, height: 1.5)),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                          child: Row(
                            children: [
                              const Text('💡', style: TextStyle(fontSize: 20)),
                              const SizedBox(width: 12),
                              Expanded(child: Text(todayTip, style: TextStyle(fontSize: 13, color: colorScheme.onSurface.withOpacity(0.8)))),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Analytics & Achievements
                  Row(children: [
                    Expanded(child: _navCard(context, loc.t('analytics'), Icons.bar_chart, Colors.indigo, const AnalyticsScreen())),
                    const SizedBox(width: 12),
                    Expanded(child: _navCard(context, loc.t('achievements'), Icons.emoji_events, Colors.amber, const AchievementsScreen())),
                  ]),
                  const SizedBox(height: 48),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader(String title, BuildContext context) {
    return Text(title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface, letterSpacing: -0.5));
  }

  Widget _moodIcon(String emoji, String moodId, String displayLabel) {
    final sel = _selectedMood == moodId;
    final colorScheme = Theme.of(context).colorScheme;
    final loc = AppLocalizations.of(context);
    return GestureDetector(
      onTap: () async {
        setState(() { _selectedMood = moodId; AppStats.selectedMood = moodId; });
        await MoodStorage.saveTodayMood(moodId);
        await WeeklyActivityStorage.incrementTodayActivity();
        if (mounted) AnimatedToast.show(context, message: '${loc.t('mood_logged')}: $displayLabel', emoji: emoji, accentColor: Colors.purple);
      },
      child: Column(children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 50, height: 50,
          decoration: BoxDecoration(
            color: sel ? Colors.purple.withOpacity(0.2) : Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(15),
            border: sel ? Border.all(color: Colors.purple, width: 2) : Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Center(child: Text(emoji, style: const TextStyle(fontSize: 28))),
        ),
        const SizedBox(height: 6),
        Text(displayLabel, style: TextStyle(fontSize: 11, color: sel ? Colors.purple : colorScheme.onSurface.withOpacity(0.5), fontWeight: sel ? FontWeight.bold : FontWeight.normal)),
      ]),
    );
  }

  Widget _navCard(BuildContext context, String title, IconData icon, Color color, Widget screen) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: () => Navigator.push(context, smoothPageRoute(page: screen)),
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        borderRadius: 22,
        child: Row(children: [
          Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: color, size: 22)),
          const SizedBox(width: 10),
          Flexible(child: Text(title, overflow: TextOverflow.ellipsis, maxLines: 1, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: colorScheme.onSurface))),
        ]),
      ),
    );
  }
}

/// Animated Buddy FAB with 3D paw icon and subtle bounce
class _AnimatedBuddyFAB extends StatefulWidget {
  final VoidCallback onPressed;
  const _AnimatedBuddyFAB({required this.onPressed});

  @override
  State<_AnimatedBuddyFAB> createState() => _AnimatedBuddyFABState();
}

class _AnimatedBuddyFABState extends State<_AnimatedBuddyFAB>
    with SingleTickerProviderStateMixin {
  late final AnimationController _bounceController;
  late final Animation<double> _bounceAnim;

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _bounceAnim = Tween<double>(begin: 0, end: -6).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _bounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _bounceAnim,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _bounceAnim.value),
          child: child,
        );
      },
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.purple.shade300, Colors.purple.shade600],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.purple.withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onPressed,
            borderRadius: BorderRadius.circular(20),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(
                'assets/images/realistic_buddy_paw.png',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Center(
                  child: Text('🐾', style: TextStyle(fontSize: 30)),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
