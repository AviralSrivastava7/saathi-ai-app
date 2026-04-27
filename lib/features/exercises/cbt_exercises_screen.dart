import 'package:flutter/material.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/widgets/zen_aura_background.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/smooth_page_route.dart';

class CBTExercisesScreen extends StatelessWidget {
  const CBTExercisesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final loc = AppLocalizations.of(context);

    final List<_CBTExercise> exercises = [
      _CBTExercise(
        titleKey: 'thought_challenging',
        descriptionKey: 'thought_challenging_desc',
        icon: Icons.psychology_alt_rounded,
        color: const Color(0xFF6366F1),
        stepKeys: [
          'tc_step_1',
          'tc_step_2',
          'tc_step_3',
          'tc_step_4',
          'tc_step_5',
          'tc_step_6',
          'tc_step_7',
        ],
        longDescriptionKey: 'tc_long_desc',
      ),
      _CBTExercise(
        titleKey: 'behavioral_activation',
        descriptionKey: 'behavioral_activation_desc',
        icon: Icons.directions_run_rounded,
        color: const Color(0xFF10B981),
        stepKeys: [
          'ba_step_1',
          'ba_step_2',
          'ba_step_3',
          'ba_step_4',
          'ba_step_5',
          'ba_step_6',
          'ba_step_7',
        ],
        longDescriptionKey: 'ba_long_desc',
      ),
      _CBTExercise(
        titleKey: 'exposure_therapy',
        descriptionKey: 'exposure_therapy_desc',
        icon: Icons.visibility_rounded,
        color: const Color(0xFFF59E0B),
        stepKeys: [
          'et_step_1',
          'et_step_2',
          'et_step_3',
          'et_step_4',
          'et_step_5',
          'et_step_6',
          'et_step_7',
          'et_step_8',
        ],
        longDescriptionKey: 'et_long_desc',
      ),
      _CBTExercise(
        titleKey: 'cognitive_restructuring',
        descriptionKey: 'cognitive_restructuring_desc',
        icon: Icons.auto_fix_high_rounded,
        color: const Color(0xFFEC4899),
        stepKeys: [
          'cr_step_1',
          'cr_step_2',
          'cr_step_3',
          'cr_step_4',
          'cr_step_5',
          'cr_step_6',
          'cr_step_7',
        ],
        longDescriptionKey: 'cr_long_desc',
      ),
    ];

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
        title: Text(
          loc.t('cbt_exercises'),
          style: TextStyle(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w900,
            fontSize: 24,
            letterSpacing: -0.5,
          ),
        ),
      ),
      body: ZenAuraBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  loc.t('cbt_intro'),
                  style: TextStyle(
                    color: colorScheme.onSurface.withOpacity(0.6),
                    fontSize: 15,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 32),
                ...exercises.map((e) => _buildExerciseCard(context, e, loc)),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExerciseCard(
      BuildContext context, _CBTExercise exercise, AppLocalizations loc) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: GlassCard(
        padding: EdgeInsets.zero,
        borderRadius: 28,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              smoothPageRoute(
                page: _CBTDetailScreen(exercise: exercise),
              ),
            );
          },
          borderRadius: BorderRadius.circular(28),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: exercise.color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(exercise.icon, color: exercise.color, size: 30),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        loc.t(exercise.titleKey),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        loc.t(exercise.descriptionKey),
                        style: TextStyle(
                          fontSize: 13,
                          color: colorScheme.onSurface.withOpacity(0.5),
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios_rounded,
                    color: colorScheme.onSurface.withOpacity(0.2), size: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CBTExercise {
  final String titleKey, descriptionKey, longDescriptionKey;
  final IconData icon;
  final Color color;
  final List<String> stepKeys;
  _CBTExercise({
    required this.titleKey,
    required this.descriptionKey,
    required this.icon,
    required this.color,
    required this.stepKeys,
    required this.longDescriptionKey,
  });
}

/// Detail screen for each CBT exercise with guided steps
class _CBTDetailScreen extends StatefulWidget {
  final _CBTExercise exercise;
  const _CBTDetailScreen({required this.exercise});

  @override
  State<_CBTDetailScreen> createState() => _CBTDetailScreenState();
}

class _CBTDetailScreenState extends State<_CBTDetailScreen> {
  int _currentStep = 0;
  final Set<int> _completedSteps = {};

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final loc = AppLocalizations.of(context);
    final exercise = widget.exercise;
    final allDone = _completedSteps.length == exercise.stepKeys.length;

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          loc.t(exercise.titleKey),
          style: TextStyle(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
      ),
      body: ZenAuraBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hero
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        exercise.color,
                        exercise.color.withOpacity(0.7),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: exercise.color.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(exercise.icon,
                            color: Colors.white, size: 36),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        loc.t(exercise.titleKey),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        loc.t(exercise.longDescriptionKey),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.85),
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // Progress
                GlassCard(
                  padding: const EdgeInsets.all(16),
                  borderRadius: 20,
                  child: Row(
                    children: [
                      Icon(
                        allDone
                            ? Icons.check_circle_rounded
                            : Icons.timeline_rounded,
                        color: allDone ? Colors.green : exercise.color,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              allDone ? loc.t('all_steps_complete') : loc.t('progress'),
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 6),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: exercise.stepKeys.isEmpty
                                    ? 0
                                    : _completedSteps.length /
                                        exercise.stepKeys.length,
                                backgroundColor:
                                    colorScheme.onSurface.withOpacity(0.08),
                                color: exercise.color,
                                minHeight: 6,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${_completedSteps.length}/${exercise.stepKeys.length}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: exercise.color,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Steps
                Text(
                  loc.t('guided_steps'),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 16),
                ...List.generate(exercise.stepKeys.length, (index) {
                  final isDone = _completedSteps.contains(index);
                  final isActive = index == _currentStep;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: GlassCard(
                      padding: EdgeInsets.zero,
                      borderRadius: 20,
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            if (isDone) {
                              _completedSteps.remove(index);
                            } else {
                              _completedSteps.add(index);
                              if (_currentStep == index &&
                                  _currentStep < exercise.stepKeys.length - 1) {
                                _currentStep++;
                              }
                            }
                          });
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            border: isActive && !isDone
                                ? Border.all(
                                    color: exercise.color.withOpacity(0.5),
                                    width: 2,
                                  )
                                : null,
                          ),
                          child: Row(
                            children: [
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: isDone
                                      ? exercise.color
                                      : exercise.color.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: isDone
                                      ? const Icon(Icons.check_rounded,
                                          color: Colors.white, size: 20)
                                      : Text(
                                          '${index + 1}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: exercise.color,
                                            fontSize: 14,
                                          ),
                                        ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  loc.t(exercise.stepKeys[index]),
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: isDone
                                        ? colorScheme.onSurface.withOpacity(0.4)
                                        : colorScheme.onSurface,
                                    decoration: isDone
                                        ? TextDecoration.lineThrough
                                        : null,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),

                const SizedBox(height: 32),

                // Complete button
                if (allDone)
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            exercise.color,
                            exercise.color.withOpacity(0.7),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: exercise.color.withOpacity(0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.celebration_rounded,
                              color: Colors.white, size: 24),
                          const SizedBox(width: 12),
                          Text(
                            loc.t('well_done_celeb'),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
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
