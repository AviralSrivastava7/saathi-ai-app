import 'package:flutter/material.dart';
import 'dart:ui';
import '../../core/widgets/smooth_page_route.dart';
import '../../core/theme/app_colors.dart';
import '../games/games_screen.dart';
import '../../core/theme/app_text_styles.dart';
import '../exercises/cbt_exercises_screen.dart';
import '../achievements/achievements_screen.dart';
import '../articles/articles_tips_screen.dart';
import '../../core/widgets/zen_aura_background.dart';
import '../../core/localization/app_localizations.dart';

class ResourcesScreen extends StatelessWidget {
  const ResourcesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      body: ZenAuraBackground(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Resources',
              style: AppTextStyles.headingLarge,
            ),
            const SizedBox(height: 24),

            // ✅ Games Option
            _buildResourceCard(
              context,
              icon: Icons.games_rounded,
              title: 'Mindful Games',
              description: 'Play relaxing wellness games',
              color: const Color(0xFFF97316),
              imagePath: 'assets/articles/stress.jpg',
              onTap: () {
                Navigator.push(context, smoothPageRoute(page: const GamesScreen()));
              },
            ),

            const SizedBox(height: 16),

            // ✅ CBT Exercises
            _buildResourceCard(
              context,
              icon: Icons.psychology_outlined,
              title: 'CBT Exercises',
              description: 'Science-based mental wellness techniques',
              color: const Color(0xFF43E97B),
              imagePath: 'assets/articles/mindfulness.jpg',
              onTap: () {
                Navigator.push(context, smoothPageRoute(page: const CBTExercisesScreen()));
              },
            ),

            const SizedBox(height: 16),

            // ✅ Achievements
            _buildResourceCard(
              context,
              icon: Icons.emoji_events_outlined,
              title: 'Achievements',
              description: 'Track your wellness journey',
              color: const Color(0xFF38F9D7),
              imagePath: 'assets/articles/morning.jpg',
              onTap: () {
                Navigator.push(context, smoothPageRoute(page: const AchievementsScreen()));
              },
            ),

            const SizedBox(height: 16),

            // ✅ Articles & Tips
            _buildResourceCard(
              context,
              icon: Icons.article_outlined,
              title: 'Articles & Tips',
              description: 'Read helpful articles and tips',
              color: const Color(0xFF9D50BB),
              imagePath: 'assets/articles/anxiety.jpg',
              onTap: () {
                Navigator.push(context, smoothPageRoute(page: const ArticlesTipsScreen()));
              },
            ),

            const SizedBox(height: 16),

            // ✅ Crisis Support
            _buildResourceCard(
              context,
              icon: Icons.emergency_outlined,
              title: 'Crisis Support',
              description: 'Emergency contacts and resources',
              color: Colors.red,
              imagePath: 'assets/articles/sleep.jpg',
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: AppColors.surface,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24)),
                    title: Row(
                      children: [
                        const Icon(Icons.crisis_alert_rounded, color: Colors.red),
                        const SizedBox(width: 12),
                        Text(AppLocalizations.of(context).t('emergency_helplines'),
                            style: const TextStyle(color: Colors.white)),
                      ],
                    ),
                    content: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'National Suicide Prevention\n📞 9152987821\n24/7 Available\n',
                            style: AppTextStyles.body.copyWith(
                              color: Colors.white,
                              height: 1.6,
                            ),
                          ),
                          const Divider(color: Colors.white24),
                          Text(
                            'Mental Health Helpline\n📞 08046110007\nMon-Sat, 8 AM - 10 PM\n',
                            style: AppTextStyles.body.copyWith(
                              color: Colors.white,
                              height: 1.6,
                            ),
                          ),
                          const Divider(color: Colors.white24),
                          Text(
                            'Emergency Services\n📞 112\n24/7 Available',
                            style: AppTextStyles.body.copyWith(
                              color: Colors.white,
                              height: 1.6,
                            ),
                          ),
                        ],
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(AppLocalizations.of(context).t('close_btn')),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildResourceCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required String imagePath,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          image: DecorationImage(
            image: AssetImage(imagePath),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.55),
              BlendMode.darken,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.2),
              blurRadius: 15,
              offset: const Offset(0, 8),
            )
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    color.withOpacity(0.2),
                    Colors.transparent,
                  ],
                ),
                border: Border.all(
                  color: Colors.white.withOpacity(0.15),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          title,
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          description,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.body.copyWith(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Colors.white.withOpacity(0.7),
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
