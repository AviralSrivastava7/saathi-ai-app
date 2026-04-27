import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/widgets/zen_aura_background.dart';
import '../../core/localization/app_localizations.dart';

class BodyScanExercise extends StatefulWidget {
  const BodyScanExercise({super.key});
  @override
  State<BodyScanExercise> createState() => _BodyScanExerciseState();
}

class _BodyScanExerciseState extends State<BodyScanExercise> {
  bool _isStarted = false;
  int _currentPart = 0;
  int _timer = 30;
  Timer? _exerciseTimer;
  final List<BodyPart> _bodyParts = [];

  @override
  void dispose() { _exerciseTimer?.cancel(); super.dispose(); }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final loc = AppLocalizations.of(context);
    _bodyParts.clear();
    _bodyParts.addAll([
      BodyPart(loc.t('Feet'), 'Focus on your feet. Notice any sensations.', Icons.directions_walk, 30),
      BodyPart(loc.t('Legs'), 'Move attention to your legs. Feel them relax.', Icons.airline_seat_legroom_normal, 30),
      BodyPart('Hips & Lower Back', 'Notice your hips and lower back.', Icons.airline_seat_recline_normal, 30),
      BodyPart(loc.t('Stomach'), 'Feel your stomach rise and fall with breath.', Icons.crop_square, 30),
      BodyPart(loc.t('Chest'), 'Notice your chest and heart beating.', Icons.favorite, 30),
      BodyPart('Hands & Arms', 'Feel your hands and arms.', Icons.back_hand, 30),
      BodyPart(loc.t('Shoulders'), 'Release tension in your shoulders.', Icons.airline_seat_flat, 30),
      BodyPart(loc.t('Neck'), 'Notice your neck, let it relax.', Icons.accessibility, 30),
      BodyPart('Face & Head', 'Feel your face muscles soften.', Icons.face, 30),
      BodyPart('Whole Body', 'Feel your entire body at once.', Icons.accessibility_new, 40),
    ]);
  }

  void _startExercise() {
    setState(() { _isStarted = true; _currentPart = 0; _timer = _bodyParts[0].duration; });
    _exerciseTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _timer--;
        if (_timer <= 0) {
          if (_currentPart < _bodyParts.length - 1) { _currentPart++; _timer = _bodyParts[_currentPart].duration; }
          else _completeExercise();
        }
      });
    });
  }

  void _completeExercise() {
    _exerciseTimer?.cancel();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(children: [const Icon(Icons.check_circle, color: Color(0xFF4CAF50), size: 32), const SizedBox(width: 12), Text(AppLocalizations.of(context).t('body_scan_complete'))]),
        content: Text(AppLocalizations.of(context).t('body_scan_complete_desc')),
        actions: [TextButton(onPressed: () { Navigator.of(ctx).pop(); Navigator.of(context).pop(); }, child: Text(AppLocalizations.of(context).t('Done'), style: const TextStyle(color: Color(0xFF4CAF50))))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(title: Text(AppLocalizations.of(context).t('body_scan'), style: TextStyle(color: cs.onSurface)), backgroundColor: Colors.transparent, elevation: 0, iconTheme: IconThemeData(color: cs.onSurface)),
      body: ZenAuraBackground(
        child: SafeArea(child: _isStarted ? _buildExerciseView(cs) : _buildIntroView(cs)),
      ),
    );
  }

  Widget _buildIntroView(ColorScheme cs) {
    final loc = AppLocalizations.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(children: [
        Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFFFF9800), Color(0xFFF57C00)]), borderRadius: BorderRadius.circular(20)),
          child: const Icon(Icons.accessibility_new, size: 100, color: Colors.white),
        ),
        const SizedBox(height: 24),
        Text(AppLocalizations.of(context).t('body_scan_meditation'), style: TextStyle(color: cs.onSurface, fontSize: 24, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        Text(loc.t('body_scan_meditation_desc'),
          style: TextStyle(color: cs.onSurface.withOpacity(0.7), fontSize: 16, height: 1.5), textAlign: TextAlign.center),
        const SizedBox(height: 24),
        Text(loc.t('bs_duration'), style: TextStyle(color: cs.onSurface.withOpacity(0.6))),
        const SizedBox(height: 32),
        SizedBox(width: double.infinity, height: 56, child: ElevatedButton(
          onPressed: _startExercise,
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF9800), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
          child: Text(AppLocalizations.of(context).t('Start'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white)),
        )),
      ]),
    );
  }

  Widget _buildExerciseView(ColorScheme cs) {
    final current = _bodyParts[_currentPart];
    return Column(children: [
      LinearProgressIndicator(value: (_currentPart + 1) / _bodyParts.length, backgroundColor: cs.outlineVariant, valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFF9800))),
      Expanded(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(current.icon, size: 100, color: const Color(0xFFFF9800)),
              const SizedBox(height: 32),
              Text(current.name, style: TextStyle(color: cs.onSurface, fontSize: 28, fontWeight: FontWeight.w600)),
              const SizedBox(height: 24),
              Text('$_timer', style: TextStyle(color: cs.onSurface, fontSize: 64, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: cs.surfaceContainerHighest, borderRadius: BorderRadius.circular(16)),
                child: Text(current.instruction, style: TextStyle(color: cs.onSurface.withOpacity(0.9), fontSize: 18, height: 1.5), textAlign: TextAlign.center),
              ),
            ]),
          ),
        ),
      ),
    ]);
  }
}

class BodyPart {
  final String name, instruction;
  final IconData icon;
  final int duration;
  BodyPart(this.name, this.instruction, this.icon, this.duration);
}
