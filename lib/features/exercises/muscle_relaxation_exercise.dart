import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/widgets/zen_aura_background.dart';

class MuscleRelaxationExercise extends StatefulWidget {
  const MuscleRelaxationExercise({super.key});
  @override
  State<MuscleRelaxationExercise> createState() => _MuscleRelaxationExerciseState();
}

class _MuscleRelaxationExerciseState extends State<MuscleRelaxationExercise> {
  bool _isStarted = false;
  int _currentStep = 0;
  int _stepTimer = 0;
  Timer? _timer;
  bool _isPaused = false;

  final List<MuscleGroup> _muscleGroups = [
    MuscleGroup(name: 'Hands and Arms', instruction: 'Make tight fists with both hands. Hold for 5 seconds.', relaxInstruction: 'Release and let your hands relax completely.', tenseDuration: 5, relaxDuration: 10, icon: Icons.back_hand),
    MuscleGroup(name: 'Biceps', instruction: 'Flex your biceps by bending your arms.', relaxInstruction: 'Release and let your arms hang loose.', tenseDuration: 5, relaxDuration: 10, icon: Icons.fitness_center),
    MuscleGroup(name: 'Shoulders', instruction: 'Raise your shoulders up toward your ears.', relaxInstruction: 'Drop your shoulders and feel the tension melt away.', tenseDuration: 5, relaxDuration: 10, icon: Icons.airline_seat_recline_extra),
    MuscleGroup(name: 'Neck', instruction: 'Gently press your head back against the chair or pillow.', relaxInstruction: 'Return to normal position and relax your neck.', tenseDuration: 5, relaxDuration: 10, icon: Icons.accessibility),
    MuscleGroup(name: 'Face', instruction: 'Scrunch up your face, squeeze your eyes tight.', relaxInstruction: 'Release and let your face relax completely.', tenseDuration: 5, relaxDuration: 10, icon: Icons.face),
    MuscleGroup(name: 'Chest and Back', instruction: 'Take a deep breath and hold it, pull shoulders back.', relaxInstruction: 'Exhale slowly and let your chest relax.', tenseDuration: 5, relaxDuration: 10, icon: Icons.favorite),
    MuscleGroup(name: 'Stomach', instruction: 'Tighten your stomach muscles, make them hard.', relaxInstruction: 'Release and breathe normally.', tenseDuration: 5, relaxDuration: 10, icon: Icons.crop_square),
    MuscleGroup(name: 'Legs and Feet', instruction: 'Point your toes down and tense your leg muscles.', relaxInstruction: 'Release and let your legs relax completely.', tenseDuration: 5, relaxDuration: 10, icon: Icons.directions_walk),
  ];

  @override
  void dispose() { _timer?.cancel(); super.dispose(); }

  void _startExercise() {
    setState(() { _isStarted = true; _currentStep = 0; _stepTimer = _muscleGroups[0].tenseDuration; });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isPaused) setState(() { _stepTimer--; if (_stepTimer <= 0) _nextStep(); });
    });
  }

  void _nextStep() {
    final isTensePhase = _currentStep % 2 == 0;
    if (isTensePhase) {
      setState(() { _currentStep++; _stepTimer = _muscleGroups[_currentStep ~/ 2].relaxDuration; });
    } else {
      if (_currentStep ~/ 2 < _muscleGroups.length - 1) {
        setState(() { _currentStep++; _stepTimer = _muscleGroups[_currentStep ~/ 2].tenseDuration; });
      } else {
        _completeExercise();
      }
    }
  }

  void _completeExercise() {
    _timer?.cancel();
    showDialog(context: context, builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(children: [const Icon(Icons.check_circle, color: Color(0xFF4CAF50), size: 32), const SizedBox(width: 12), Text(AppLocalizations.of(context).t('muscle_relaxation_complete'))]),
      content: const Text('Great job! You\'ve completed the progressive muscle relaxation exercise.'),
      actions: [TextButton(onPressed: () { Navigator.of(ctx).pop(); Navigator.of(context).pop(); }, child: Text(AppLocalizations.of(context).t('Done'), style: const TextStyle(color: Color(0xFF4CAF50))))],
    ));
  }

  void _stopExercise() {
    _timer?.cancel();
    setState(() { _isStarted = false; _currentStep = 0; _isPaused = false; });
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(title: Text(loc.t('muscle_relaxation'), style: TextStyle(color: cs.onSurface)), backgroundColor: Colors.transparent, elevation: 0, iconTheme: IconThemeData(color: cs.onSurface)),
      body: ZenAuraBackground(
        child: SafeArea(child: _isStarted ? _buildExerciseView(cs) : _buildIntroView(cs)),
      ),
    );
  }

  Widget _buildIntroView(ColorScheme cs) {
    final loc = AppLocalizations.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF9C27B0), Color(0xFF673AB7)]), borderRadius: BorderRadius.circular(20)),
          child: const Center(child: Icon(Icons.self_improvement, size: 100, color: Colors.white)),
        ),
        const SizedBox(height: 24),
        Text('Progressive Muscle Relaxation', style: TextStyle(color: cs.onSurface, fontSize: 24, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        Text(loc.t('muscle_relaxation_desc'),
          style: TextStyle(color: cs.onSurface.withOpacity(0.7), fontSize: 16, height: 1.5)),
        const SizedBox(height: 24),
        Text(loc.t('how_it_works'), style: TextStyle(color: cs.onSurface, fontSize: 18, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        _buildInfoCard(icon: Icons.looks_one, title: loc.t('mr_tense_title'), description: loc.t('mr_tense_desc'), color: const Color(0xFF9C27B0), cs: cs),
        _buildInfoCard(icon: Icons.looks_two, title: loc.t('mr_notice_title'), description: loc.t('mr_notice_desc'), color: const Color(0xFF7B1FA2), cs: cs),
        _buildInfoCard(icon: Icons.looks_3, title: loc.t('mr_release_title'), description: loc.t('mr_release_desc'), color: const Color(0xFF6A1B9A), cs: cs),
        _buildInfoCard(icon: Icons.looks_4, title: loc.t('mr_repeat_title'), description: loc.t('mr_repeat_desc'), color: const Color(0xFF4A148C), cs: cs),
        const SizedBox(height: 24),
        Text(loc.t('mr_groups'), style: TextStyle(color: cs.onSurface, fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        Wrap(spacing: 8, runSpacing: 8, children: _muscleGroups.map((g) => Chip(
          avatar: Icon(g.icon, size: 16, color: cs.onSurface),
          label: Text(g.name),
          backgroundColor: const Color(0xFF9C27B0).withOpacity(0.15),
          labelStyle: TextStyle(color: cs.onSurface, fontSize: 12),
        )).toList()),
        const SizedBox(height: 32),
        SizedBox(width: double.infinity, height: 56, child: ElevatedButton(
          onPressed: _startExercise,
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF9C27B0), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
          child: Text(loc.t('start_exercise'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white)),
        )),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: cs.primary.withOpacity(0.08), borderRadius: BorderRadius.circular(16), border: Border.all(color: cs.primary.withOpacity(0.2))),
          child: Row(children: [
            Icon(Icons.info_outline, color: cs.primary, size: 24), const SizedBox(width: 12),
            Expanded(child: Text(loc.t('mr_duration'), style: TextStyle(color: cs.onSurface.withOpacity(0.7), fontSize: 13))),
          ]),
        ),
      ]),
    );
  }

  Widget _buildExerciseView(ColorScheme cs) {
    final groupIdx = _currentStep ~/ 2;
    final isTense = _currentStep % 2 == 0;
    final group = _muscleGroups[groupIdx];
    final instruction = isTense ? group.instruction : group.relaxInstruction;
    final phaseColor = isTense ? Colors.red : const Color(0xFF9C27B0);

    return Column(children: [
      LinearProgressIndicator(value: (_currentStep + 1) / (_muscleGroups.length * 2), backgroundColor: cs.outlineVariant, valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF9C27B0))),
      Expanded(
        child: Center(
          child: Padding(padding: const EdgeInsets.all(32), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(padding: const EdgeInsets.all(32), decoration: BoxDecoration(shape: BoxShape.circle, color: phaseColor.withOpacity(0.15)), child: Icon(group.icon, size: 80, color: phaseColor)),
            const SizedBox(height: 32),
            Text(isTense ? 'TENSE' : 'RELAX', style: TextStyle(color: phaseColor, fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 2)),
            const SizedBox(height: 16),
            Text(group.name, style: TextStyle(color: cs.onSurface, fontSize: 28, fontWeight: FontWeight.w600), textAlign: TextAlign.center),
            const SizedBox(height: 24),
            Text('$_stepTimer', style: TextStyle(color: cs.onSurface, fontSize: 72, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: cs.surfaceContainerHighest, borderRadius: BorderRadius.circular(16)),
              child: Text(instruction, style: TextStyle(color: cs.onSurface.withOpacity(0.9), fontSize: 18, height: 1.5), textAlign: TextAlign.center),
            ),
            const SizedBox(height: 32),
            Text('Muscle group ${groupIdx + 1} of ${_muscleGroups.length}', style: TextStyle(color: cs.onSurface.withOpacity(0.6), fontSize: 14)),
          ])),
        ),
      ),
      Padding(padding: const EdgeInsets.all(20), child: Row(children: [
        Expanded(child: OutlinedButton(onPressed: _stopExercise, style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), side: BorderSide(color: Colors.red.withOpacity(0.5)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          child: Text(AppLocalizations.of(context).t('Stop'), style: const TextStyle(color: Colors.red, fontSize: 16, fontWeight: FontWeight.w600)))),
        const SizedBox(width: 16),
        Expanded(child: ElevatedButton(onPressed: _nextStep, style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), backgroundColor: const Color(0xFF9C27B0), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          child: Text(AppLocalizations.of(context).t('Skip'), style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)))),
      ])),
    ]);
  }

  Widget _buildInfoCard({required IconData icon, required String title, required String description, required Color color, required ColorScheme cs}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(12), border: Border.all(color: color.withOpacity(0.2))),
      child: Row(children: [
        Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(8)), child: Icon(icon, color: color, size: 24)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: TextStyle(color: cs.onSurface, fontSize: 16, fontWeight: FontWeight.w600)),
          Text(description, style: TextStyle(color: cs.onSurface.withOpacity(0.7), fontSize: 13)),
        ])),
      ]),
    );
  }
}

class MuscleGroup {
  final String name, instruction, relaxInstruction;
  final int tenseDuration, relaxDuration;
  final IconData icon;
  MuscleGroup({required this.name, required this.instruction, required this.relaxInstruction, required this.tenseDuration, required this.relaxDuration, required this.icon});
}
