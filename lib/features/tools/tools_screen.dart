import 'package:flutter/material.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/logic/tool_recommendation_engine.dart';
import '../../core/widgets/zen_aura_background.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/smooth_page_route.dart';
import '../../core/widgets/cinematic_parallax_card.dart';

// Import ALL feature screens
import '../meditation/meditation_screen.dart';
import '../breathing/breathing_screen.dart';
import '../checklist/daily_checklist_screen.dart';
import '../sos/sos_screen.dart';
import '../exercises/exercises_screen.dart';
import '../music/music_screen.dart';
import '../diet/diet_chart_screen.dart';
import '../affirmations/affirmations_screen.dart';
import '../games/games_screen.dart';
import '../articles/articles_tips_screen.dart';
import '../articles/books_reader_screen.dart';
import 'focus_recover_screen.dart';
import 'wind_down_screen.dart';

class ToolsScreen extends StatefulWidget {
  const ToolsScreen({super.key});

  @override
  State<ToolsScreen> createState() => _ToolsScreenState();
}

class _ToolsScreenState extends State<ToolsScreen> {
  late Future<RecommendedTool> _recommendationFuture;

  @override
  void initState() {
    super.initState();
    _recommendationFuture = ToolRecommendationEngine.getRecommendation();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final loc = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Text(loc.t('wellness_tools'),
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 28, letterSpacing: -1.0)),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
      ),
      body: ZenAuraBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FutureBuilder<RecommendedTool>(
                    future: _recommendationFuture,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: _buildRecommendationHero(context, snapshot.data!, loc),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                  const SizedBox(height: 32),

                  _sectionHeader(loc.t('daily_mindfulness'), context),
                  _buildToolRow(context, [
                    _ToolItem(loc.t('meditation'), loc.t('meditation_sub'), 'assets/images/realistic_meditation.png', Colors.purple, const MeditationScreen()),
                    _ToolItem(loc.t('breathing'), loc.t('breathing_sub'), 'assets/images/realistic_breathing.png', Colors.teal, const BreathingScreen()),
                    _ToolItem(loc.t('affirmations'), loc.t('affirmations_sub'), 'assets/images/realistic_affirmations.png', Colors.pink, const AffirmationsScreen()),
                  ]),
                  const SizedBox(height: 32),

                  _sectionHeader(loc.t('self_care'), context),
                  _buildToolRow(context, [
                    _ToolItem(loc.t('exercises'), loc.t('exercises_sub'), 'assets/images/realistic_exercises.png', Colors.orange, const ExercisesScreen()),
                    _ToolItem(loc.t('diet_plan'), loc.t('diet_plan_sub'), 'assets/images/realistic_diet.png', Colors.green, const DietChartScreen()),
                    _ToolItem(loc.t('checklist'), loc.t('checklist_sub'), 'assets/images/aesthetic_checklist.png', Colors.indigo, const DailyChecklistScreen()),
                    _ToolItem(loc.t('focus_recover'), loc.t('focus_recover_sub'), 'assets/images/aesthetic_focus.png', const Color(0xFF6366F1), const FocusRecoverScreen()),
                  ]),
                  const SizedBox(height: 32),

                  _sectionHeader(loc.t('sleep_and_focus'), context),
                  _buildToolRow(context, [
                    _ToolItem(loc.t('relax_music'), loc.t('relax_music_sub'), 'assets/images/aesthetic_music.png', Colors.blue, const CalmMusicScreen()),
                    _ToolItem(loc.t('sleep_stories'), loc.t('sleep_stories_sub'), 'assets/images/aesthetic_sleep.png', Colors.indigo, const SleepStoriesScreen()),
                    _ToolItem(loc.t('wind_down'), loc.t('wind_down_sub'), 'assets/images/aesthetic_wind_down.png', const Color(0xFF8B5CF6), const WindDownScreen()),
                  ]),
                  const SizedBox(height: 32),

                  _sectionHeader(loc.t('interactive_fun'), context),
                  _buildToolRow(context, [
                    _ToolItem(loc.t('games'), loc.t('games_sub'), 'assets/images/aesthetic_games.png', Colors.deepPurple, const GamesScreen()),
                  ]),
                  const SizedBox(height: 32),

                  _sectionHeader(loc.t('knowledge'), context),
                  _buildToolRow(context, [
                    _ToolItem(loc.t('articles'), loc.t('articles_sub'), 'assets/images/aesthetic_articles.png', Colors.cyan, const ArticlesTipsScreen()),
                    _ToolItem(loc.t('books'), loc.t('books_sub'), 'assets/images/aesthetic_books.png', Colors.brown, const BooksReaderScreen()),
                  ]),
                  const SizedBox(height: 32),

                  _sectionHeader(loc.t('support'), context),
                  _buildToolRow(context, [
                    _ToolItem(loc.t('sos_help'), loc.t('sos_help_sub'), 'assets/images/aesthetic_sos.png', Colors.red, const SOSScreen()),
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

  Widget _buildRecommendationHero(BuildContext context, RecommendedTool tool, AppLocalizations loc) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [tool.color.withOpacity(0.8), tool.color.withOpacity(0.6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(color: tool.color.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle), child: Icon(tool.icon, color: Colors.white, size: 24)),
              const SizedBox(width: 12),
              Text(loc.t('recommended'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12, letterSpacing: 1.2)),
            ],
          ),
          const SizedBox(height: 20),
          Text(loc.t(tool.title), style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(loc.t(tool.description), style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14, height: 1.4)),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.push(context, smoothPageRoute(page: tool.screen)),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: tool.color, elevation: 0, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
            child: Text(loc.t('start_now'), style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      child: Text(title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface, letterSpacing: -0.5)),
    );
  }

  Widget _buildToolRow(BuildContext context, List<_ToolItem> items) {
    return SizedBox(
      height: 180, 
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24), 
        clipBehavior: Clip.none, 
        itemCount: items.length,
        itemBuilder: (context, index) {
          return Container(width: 155, margin: EdgeInsets.only(right: index == items.length - 1 ? 0 : 16), child: _toolCard(context, items[index]));
        },
      ),
    );
  }

  Widget _toolCard(BuildContext context, _ToolItem item) {
    return CinematicParallaxCard(
      imagePath: item.imagePath,
      title: item.title,
      subtitle: item.subtitle,
      themeColor: item.color,
      onTap: () => Navigator.push(context, smoothPageRoute(page: item.screen)),
    );
  }
}

class _ToolItem {
  final String title, subtitle, imagePath;
  final Color color;
  final Widget screen;
  _ToolItem(this.title, this.subtitle, this.imagePath, this.color, this.screen);
}

class SleepStoriesScreen extends StatelessWidget {
  const SleepStoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final loc = AppLocalizations.of(context);

    final stories = [
      _Story(
        loc.t('story_1_t'),
        loc.t('story_1_s'),
        '🌙', Colors.indigo, '10 min',
        loc.t('story_1_c'),
      ),
      _Story(
        loc.t('story_2_t'),
        loc.t('story_2_s'),
        '🌊', Colors.blue, '12 min',
        loc.t('story_2_c'),
      ),
      _Story(
        loc.t('story_3_t'),
        loc.t('story_3_s'),
        '☁️', Colors.purple, '8 min',
        loc.t('story_3_c'),
      ),
      _Story(
        loc.t('story_4_t'),
        loc.t('story_4_s'),
        '🌾', Colors.teal, '9 min',
        loc.t('story_4_c'),
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0, leading: IconButton(icon: Icon(Icons.arrow_back_ios_new_rounded, color: colorScheme.onSurface), onPressed: () => Navigator.pop(context)), title: Text(loc.t('sleep_stories'), style: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.w900, fontSize: 24, letterSpacing: -0.5))),
      body: ZenAuraBackground(
        child: SafeArea(
          child: ListView.builder(
            padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 20),
            itemCount: stories.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) return _buildStoriesHero(loc);
              return _storyCard(context, stories[index - 1]);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildStoriesHero(AppLocalizations loc) {
    return Container(
      margin: const EdgeInsets.only(bottom: 28),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.indigo.shade700, Colors.deepPurple.shade400], begin: Alignment.topLeft, end: Alignment.bottomRight), borderRadius: BorderRadius.circular(28), boxShadow: [BoxShadow(color: Colors.indigo.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle), child: const Icon(Icons.nightlight_round, color: Colors.white, size: 28)),
        const SizedBox(height: 16),
        Text(loc.t('bedtime_stories'), style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        Text(loc.t('bedtime_stories_desc'), style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14, height: 1.5)),
      ]),
    );
  }

  Widget _storyCard(BuildContext context, _Story story) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: GlassCard(
        padding: const EdgeInsets.all(18),
        borderRadius: 22,
        child: InkWell(
          onTap: () => Navigator.push(context, smoothPageRoute(
            page: _SleepStoryDetailScreen(story: story),
          )),
          borderRadius: BorderRadius.circular(22),
          child: Row(
            children: [
              Container(width: 52, height: 52, decoration: BoxDecoration(color: story.color.withOpacity(0.12), borderRadius: BorderRadius.circular(16)), child: Center(child: Text(story.emoji, style: const TextStyle(fontSize: 24)))),
              const SizedBox(width: 16),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(story.title, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: colorScheme.onSurface)),
                const SizedBox(height: 4),
                Text(story.subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: colorScheme.onSurface.withOpacity(0.5), fontSize: 13)),
              ])),
              Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), decoration: BoxDecoration(color: story.color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: Text(story.duration, style: TextStyle(color: story.color, fontSize: 12, fontWeight: FontWeight.bold))),
            ],
          ),
        ),
      ),
    );
  }
}

class _SleepStoryDetailScreen extends StatelessWidget {
  final _Story story;
  const _SleepStoryDetailScreen({required this.story});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(story.title, style: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.w700, fontSize: 18)),
      ),
      body: ZenAuraBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Story hero
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [story.color, story.color.withOpacity(0.6)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [BoxShadow(color: story.color.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))],
                  ),
                  child: Column(
                    children: [
                      Text(story.emoji, style: const TextStyle(fontSize: 56)),
                      const SizedBox(height: 16),
                      Text(story.title, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(story.subtitle, textAlign: TextAlign.center, style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14, height: 1.5)),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                        child: Text(AppLocalizations.of(context).t('read_count').replaceAll('{val}', story.duration), style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                // Story content
                GlassCard(
                  padding: const EdgeInsets.all(24),
                  borderRadius: 24,
                  child: Text(
                    story.content,
                    style: TextStyle(
                      color: colorScheme.onSurface.withOpacity(0.85),
                      fontSize: 17,
                      height: 1.9,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Sweet dreams footer
                Center(
                  child: Column(
                    children: [
                      const Text('🌙', style: TextStyle(fontSize: 32)),
                      const SizedBox(height: 8),
                      Text(AppLocalizations.of(context).t('sweet_dreams'), style: TextStyle(color: colorScheme.onSurface.withOpacity(0.4), fontSize: 16, fontWeight: FontWeight.w600, fontStyle: FontStyle.italic)),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Story {
  final String title, subtitle, emoji, duration, content;
  final Color color;
  _Story(this.title, this.subtitle, this.emoji, this.color, this.duration, this.content);
}
