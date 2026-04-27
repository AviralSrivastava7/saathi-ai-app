import 'package:flutter/material.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/widgets/zen_aura_background.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/smooth_page_route.dart';
import 'cbt_exercises_screen.dart';
import 'breathing_exercise.dart';
import 'muscle_relaxation_exercise.dart';
import 'body_scan_exercise.dart';
import 'visualization_exercise.dart';
import 'grounding_exercise.dart';

class ExercisesScreen extends StatelessWidget {
  const ExercisesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final List<ExerciseItem> exercises = [
      ExerciseItem(titleKey: 'breathing_exercises', descriptionKey: 'breathing_desc', icon: Icons.air, color: const Color(0xFF4CAF50), destinationBuilder: (context) => const BreathingExercise()),
      ExerciseItem(titleKey: 'muscle_relaxation', descriptionKey: 'muscle_relaxation_desc', icon: Icons.self_improvement, color: const Color(0xFF9C27B0), destinationBuilder: (context) => const MuscleRelaxationExercise()),
      ExerciseItem(titleKey: 'grounding_exercise', descriptionKey: 'grounding_desc', icon: Icons.nature_people, color: const Color(0xFF2196F3), destinationBuilder: (context) => const GroundingScreen()),
      ExerciseItem(titleKey: 'body_scan', descriptionKey: 'body_scan_desc', icon: Icons.accessibility_new, color: const Color(0xFFFF9800), destinationBuilder: (context) => const BodyScanExercise()),
      ExerciseItem(titleKey: 'visualization', descriptionKey: 'visualization_desc', icon: Icons.landscape, color: const Color(0xFF00BCD4), destinationBuilder: (context) => const VisualizationExercise()),
      ExerciseItem(titleKey: 'cbt_exercises', descriptionKey: 'cbt_desc', icon: Icons.psychology, color: const Color(0xFFE91E63), destinationBuilder: (context) => const CBTExercisesScreen()),
    ];

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(loc.t('exercises'), style: TextStyle(color: cs.onSurface, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: cs.onSurface),
      ),
      body: ZenAuraBackground(
        child: ListView.builder(
          padding: const EdgeInsets.only(top: 80, bottom: 8),
          itemCount: exercises.length + 2,
          itemBuilder: (context, index) {
            if (index == 0) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: Text(loc.t('choose_exercise'), style: TextStyle(color: cs.onSurface.withOpacity(0.6), fontSize: 16)),
              );
            } else if (index <= exercises.length) {
              final exercise = exercises[index - 1];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: GlassCard(
                  padding: EdgeInsets.zero,
                  borderRadius: 24,
                  child: InkWell(
                    onTap: () => Navigator.push(context, smoothPageRoute(
                      page: exercise.destinationBuilder(context),
                    )),
                    borderRadius: BorderRadius.circular(24),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: exercise.color.withOpacity(0.1), shape: BoxShape.circle), child: Icon(exercise.icon, color: exercise.color, size: 28)),
                          const SizedBox(width: 20),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(loc.t(exercise.titleKey), style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: cs.onSurface)),
                            const SizedBox(height: 4),
                            Text(loc.t(exercise.descriptionKey), style: TextStyle(fontSize: 13, color: cs.onSurface.withOpacity(0.6), height: 1.4), maxLines: 2, overflow: TextOverflow.ellipsis),
                          ])),
                          Icon(Icons.arrow_forward_ios_rounded, color: cs.onSurface.withOpacity(0.4), size: 16),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            } else {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: GlassCard(
                  padding: const EdgeInsets.all(16),
                  borderRadius: 16,
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: cs.primary, size: 24),
                      const SizedBox(width: 12),
                      Expanded(child: Text(loc.t('exercises_tip'), style: TextStyle(color: cs.onSurface.withOpacity(0.7), fontSize: 13))),
                    ],
                  ),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}

class ExerciseItem {
  final String titleKey, descriptionKey;
  final IconData icon;
  final Color color;
  final Widget Function(BuildContext) destinationBuilder;
  ExerciseItem({required this.titleKey, required this.descriptionKey, required this.icon, required this.color, required this.destinationBuilder});
}
