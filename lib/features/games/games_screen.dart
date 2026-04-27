import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/widgets/zen_aura_background.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/smooth_page_route.dart';

// Game Imports
import 'color_therapy_game.dart';
import 'breathing_game.dart';
import 'focus_dots_game.dart';
import 'calm_maze_game.dart';
import 'reflective_puzzle_game.dart';
import 'thought_popping_game.dart';
import 'tap_the_calm_game.dart';
import 'pattern_flow_game.dart';
import 'emotion_bubbles_game.dart';
import 'word_unscramble_game.dart';
import 'mindful_match_game.dart';
import 'number_zen_game.dart';
import 'catch_the_light_game.dart';
import 'gratitude_game.dart';
import 'memory_match_game.dart';
import 'zen_shapes_game.dart';

class GamesScreen extends StatelessWidget {
  const GamesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final localization = AppLocalizations.of(context);

    final List<Map<String, dynamic>> games = [
      {
        'title': localization.t('tap_the_calm'),
        'key': 'tap_the_calm',
        'icon': '🫧',
        'color': const Color(0xFF7C3AED),
        'screen': const TapTheCalmGame(),
      },
      {
        'title': localization.t('color_therapy'),
        'key': 'color_therapy',
        'icon': '🎨',
        'color': const Color(0xFFFA709A),
        'screen': const ColorTherapyGame(),
      },
      {
        'title': localization.t('pattern_flow'),
        'key': 'pattern_flow',
        'icon': '🔮',
        'color': const Color(0xFF6366F1),
        'screen': const PatternFlowGame(),
      },
      {
        'title': localization.t('emotion_bubbles'),
        'key': 'emotion_bubbles',
        'icon': '💭',
        'color': const Color(0xFF10B981),
        'screen': const EmotionBubblesGame(),
      },
      {
        'title': localization.t('breathing_bubbles'),
        'key': 'breathing_bubbles',
        'icon': '🫧',
        'color': const Color(0xFF4FACFE),
        'screen': const BreathingGame(),
      },
      {
        'title': localization.t('word_unscramble'),
        'key': 'word_unscramble',
        'icon': '🔤',
        'color': const Color(0xFFF59E0B),
        'screen': const WordUnscrambleGame(),
      },
      {
        'title': localization.t('mindful_match'),
        'key': 'mindful_match',
        'icon': '🧩',
        'color': const Color(0xFF14B8A6),
        'screen': const MindfulMatchGame(),
      },
      {
        'title': localization.t('number_zen'),
        'key': 'number_zen',
        'icon': '🎯',
        'color': const Color(0xFF8B5CF6),
        'screen': const NumberZenGame(),
      },
      {
        'title': localization.t('catch_the_light'),
        'key': 'catch_the_light',
        'icon': '🌟',
        'color': const Color(0xFFFBBF24),
        'screen': const CatchTheLightGame(),
      },
      {
        'title': localization.t('focus_dots'),
        'key': 'focus_dots',
        'icon': '🎯',
        'color': const Color(0xFF00C6FB),
        'screen': const FocusDotsGame(),
      },
      {
        'title': localization.t('calm_maze'),
        'key': 'calm_maze',
        'icon': '🌀',
        'color': const Color(0xFFE2E2E2),
        'screen': const CalmMazeGame(),
      },
      {
        'title': localization.t('thought_popping'),
        'key': 'thought_popping',
        'icon': '💭',
        'color': const Color(0xFFEC4899),
        'screen': const ThoughtPoppingGame(),
      },
      {
        'title': localization.t('reflective_puzzle'),
        'key': 'reflective_puzzle',
        'icon': '🪞',
        'color': const Color(0xFFB1F4CF),
        'screen': const ReflectivePuzzleGame(),
      },
      {
        'title': localization.t('game_gratitude'),
        'key': 'gratitude_garden',
        'icon': '🪴',
        'color': const Color(0xFF43E97B),
        'screen': const GratitudeGame(),
      },
      {
        'title': localization.t('game_memory_match'),
        'key': 'memory_match',
        'icon': '🧩',
        'color': const Color(0xFF6366F1),
        'screen': const MemoryMatchGame(),
      },
      {
        'title': localization.t('game_zen_shapes'),
        'key': 'zen_shapes',
        'icon': '📐',
        'color': const Color(0xFFFA709A),
        'screen': const ZenShapesGame(),
      },
    ];

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded, color: theme.appBarTheme.iconTheme?.color),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          localization.t('wellness_games'),
          style: theme.appBarTheme.titleTextStyle,
        ),
      ),
      body: ZenAuraBackground(
        child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: Text(
                localization.t('wellness_games_desc'),
                style: TextStyle(
                  color: colorScheme.onSurface.withOpacity(0.7),
                  fontSize: 16,
                ),
              ),
            ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.9,
                ),
                itemCount: games.length,
                itemBuilder: (context, index) {
                  final game = games[index];
                  return _buildGameCard(context, game);
                },
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

  Widget _buildGameCard(BuildContext context, Map<String, dynamic> game) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final gameColor = game['color'] as Color;
    final gameKey = game['key'] as String;

    return GlassCard(
      padding: EdgeInsets.zero,
      borderRadius: 24,
      child: InkWell(
        onTap: () async {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('played_game', true);
          await prefs.setBool('played_game_$gameKey', true);
          
          final allKeys = [
            'tap_the_calm', 'color_therapy', 'pattern_flow',
            'emotion_bubbles', 'breathing_bubbles', 'word_unscramble',
            'mindful_match', 'number_zen', 'catch_the_light',
            'focus_dots', 'calm_maze', 'thought_popping', 'reflective_puzzle',
            'gratitude_garden', 'memory_match', 'zen_shapes',
          ];
          
          bool allPlayed = true;
          for (final k in allKeys) {
            if (!(prefs.getBool('played_game_$k') ?? false)) {
              allPlayed = false;
              break;
            }
          }
          if (allPlayed) { await prefs.setBool('played_all_games', true); }

          if (context.mounted) {
            Navigator.push(context, smoothPageRoute(
              page: game['screen'] as Widget,
            ));
          }
        },
        borderRadius: BorderRadius.circular(24),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [gameColor.withOpacity(0.12), gameColor.withOpacity(0.02)],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(width: 56, height: 56, decoration: BoxDecoration(color: gameColor.withOpacity(0.1), shape: BoxShape.circle), child: Center(child: Text(game['icon'] as String, style: const TextStyle(fontSize: 28)))),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Text(game['title'] as String, textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: colorScheme.onSurface, letterSpacing: -0.2)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
