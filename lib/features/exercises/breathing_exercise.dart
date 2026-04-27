import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/widgets/zen_aura_background.dart';

class BreathingExercise extends StatefulWidget {
  const BreathingExercise({super.key});
  @override
  State<BreathingExercise> createState() => _BreathingExerciseState();
}

class _BreathingExerciseState extends State<BreathingExercise> {
  int _selectedDuration = 3;
  String _selectedTechnique = 'Box Breathing';
  final List<int> _durations = [1, 3, 5, 10];
  final List<String> _techniques = ['Box Breathing', '4-7-8 Breathing', 'Deep Breathing'];

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(loc.t('breathing_exercise'), style: TextStyle(color: cs.onSurface)),
        backgroundColor: Colors.transparent, elevation: 0,
        iconTheme: IconThemeData(color: cs.onSurface),
      ),
      body: ZenAuraBackground(
        child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(loc.t('select_technique'), style: TextStyle(color: cs.onSurface.withOpacity(0.7), fontSize: 16, fontWeight: FontWeight.w500)),
              const SizedBox(height: 12),
              ..._techniques.map((t) => Padding(padding: const EdgeInsets.only(bottom: 12), child: _buildTechniqueCard(t, cs, loc))),
              const SizedBox(height: 24),
              Text(loc.t('duration'), style: TextStyle(color: cs.onSurface.withOpacity(0.7), fontSize: 16, fontWeight: FontWeight.w500)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                children: _durations.map((d) {
                  final sel = _selectedDuration == d;
                  return ChoiceChip(
                    label: Text('$d min'),
                    selected: sel,
                    onSelected: (_) => setState(() => _selectedDuration = d),
                    backgroundColor: cs.surfaceContainerHighest,
                    selectedColor: const Color(0xFF4CAF50),
                    labelStyle: TextStyle(color: sel ? Colors.white : cs.onSurface, fontWeight: sel ? FontWeight.w600 : FontWeight.normal),
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity, height: 56,
                child: ElevatedButton(
                  onPressed: () => _startExercise(context),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4CAF50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                  child: Text(loc.t('start_exercise'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white)),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: cs.primary.withOpacity(0.08), borderRadius: BorderRadius.circular(16), border: Border.all(color: cs.primary.withOpacity(0.2))),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: cs.primary, size: 24),
                    const SizedBox(width: 12),
                    Expanded(child: Text(loc.t('breathing_tip'), style: TextStyle(color: cs.onSurface.withOpacity(0.7), fontSize: 13))),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }

  Widget _buildTechniqueCard(String technique, ColorScheme cs, AppLocalizations loc) {
    final sel = _selectedTechnique == technique;
    String desc = '';
    IconData icon = Icons.air;
    switch (technique) {
      case 'Box Breathing': desc = loc.t('box_breathing_desc'); icon = Icons.grid_4x4; break;
      case '4-7-8 Breathing': desc = loc.t('478_breathing_desc'); icon = Icons.av_timer; break;
      case 'Deep Breathing': desc = loc.t('deep_breathing_desc'); icon = Icons.spa; break;
    }
    return GestureDetector(
      onTap: () => setState(() => _selectedTechnique = technique),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: sel ? const Color(0xFF4CAF50).withOpacity(0.15) : cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: sel ? const Color(0xFF4CAF50) : cs.outlineVariant, width: sel ? 2 : 1),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: const Color(0xFF4CAF50).withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: const Color(0xFF4CAF50), size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(technique, style: TextStyle(color: cs.onSurface, fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(desc, style: TextStyle(color: cs.onSurface.withOpacity(0.6), fontSize: 13)),
              ]),
            ),
            if (sel) const Icon(Icons.check_circle, color: Color(0xFF4CAF50), size: 24),
          ],
        ),
      ),
    );
  }

  void _startExercise(BuildContext context) {
    showDialog(context: context, barrierDismissible: false, builder: (ctx) => BreathingExerciseDialog(technique: _selectedTechnique, duration: _selectedDuration));
  }
}

class BreathingExerciseDialog extends StatefulWidget {
  final String technique;
  final int duration;
  const BreathingExerciseDialog({super.key, required this.technique, required this.duration});
  @override
  State<BreathingExerciseDialog> createState() => _BreathingExerciseDialogState();
}

class _BreathingExerciseDialogState extends State<BreathingExerciseDialog> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Timer _timer;
  int _currentPhase = 0, _countdown = 0, _totalSeconds = 0, _remainingSeconds = 0;
  final AudioPlayer _audioPlayer = AudioPlayer();
  List<String> _phaseKeys = [];
  List<int> _phaseDurations = [];

  @override
  void initState() {
    super.initState();
    _setupTechnique();
    _totalSeconds = widget.duration * 60;
    _remainingSeconds = _totalSeconds;
    _animationController = AnimationController(vsync: this, duration: Duration(seconds: _phaseDurations[_currentPhase]));
    _startExercise();
  }

  void _setupTechnique() {
    switch (widget.technique) {
      case 'Box Breathing': _phaseKeys = ['breathe_in', 'hold', 'breathe_out', 'hold']; _phaseDurations = [4, 4, 4, 4]; break;
      case '4-7-8 Breathing': _phaseKeys = ['breathe_in', 'hold', 'breathe_out']; _phaseDurations = [4, 7, 8]; break;
      case 'Deep Breathing': _phaseKeys = ['breathe_in', 'breathe_out']; _phaseDurations = [6, 6]; break;
    }
    _countdown = _phaseDurations[_currentPhase];
  }

  void _startExercise() {
    _animationController.forward();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _countdown--;
        _remainingSeconds--;
        if (_remainingSeconds <= 0) { _stopExercise(); return; }
        if (_countdown <= 0) _nextPhase();
      });
    });
  }

  void _nextPhase() {
    _currentPhase = (_currentPhase + 1) % _phaseKeys.length;
    _countdown = _phaseDurations[_currentPhase];
    _animationController.duration = Duration(seconds: _phaseDurations[_currentPhase]);
    _animationController.reset();
    _animationController.forward();
  }

  void _stopExercise() {
    _timer.cancel();
    _animationController.stop();
    _audioPlayer.stop();
    if (mounted) { Navigator.of(context).pop(); _showCompletionDialog(); }
  }

  void _showCompletionDialog() {
    final loc = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(children: [const Icon(Icons.check_circle, color: Color(0xFF4CAF50), size: 32), const SizedBox(width: 12), Text(loc.t('well_done'))]),
        content: Text(loc.t('exercise_complete_message')),
        actions: [TextButton(onPressed: () => Navigator.of(ctx).pop(), child: Text(loc.t('done'), style: const TextStyle(color: Color(0xFF4CAF50))))],
      ),
    );
  }

  @override
  void dispose() { _timer.cancel(); _animationController.dispose(); _audioPlayer.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 80),
      child: LayoutBuilder(builder: (context, constraints) {
        final dialogCs = Theme.of(context).colorScheme;
        return Container(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.7, maxWidth: 400),
          decoration: BoxDecoration(
            color: dialogCs.surface,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [BoxShadow(color: const Color(0xFF4CAF50).withOpacity(0.3), blurRadius: 30, spreadRadius: 5)],
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text(widget.technique, style: TextStyle(color: dialogCs.onSurface, fontSize: 18, fontWeight: FontWeight.w600)),
                IconButton(icon: Icon(Icons.close, color: dialogCs.onSurface.withOpacity(0.7)), onPressed: _stopExercise),
              ]),
            ),
            Flexible(
              child: Center(
                child: AnimatedBuilder(
                  animation: _animationController,
                  builder: (ctx, child) => Container(
                    width: 180 + (70 * _animationController.value), height: 180 + (70 * _animationController.value),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(colors: [const Color(0xFF4CAF50).withOpacity(0.8), const Color(0xFF4CAF50).withOpacity(0.3)]),
                      boxShadow: [BoxShadow(color: const Color(0xFF4CAF50).withOpacity(0.5), blurRadius: 40, spreadRadius: 10)],
                    ),
                    child: Center(child: Text('$_countdown', style: TextStyle(color: dialogCs.onSurface, fontSize: 64, fontWeight: FontWeight.bold))),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Text(loc.t(_phaseKeys[_currentPhase]), style: TextStyle(color: dialogCs.onSurface, fontSize: 24, fontWeight: FontWeight.w600)),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Text('${(_remainingSeconds ~/ 60)}:${(_remainingSeconds % 60).toString().padLeft(2, '0')} ${loc.t('remaining')}', style: TextStyle(color: dialogCs.onSurface.withOpacity(0.7), fontSize: 16)),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity, height: 50,
                  child: ElevatedButton(
                    onPressed: _stopExercise,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red.withOpacity(0.8), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    child: Text(loc.t('stop'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                  ),
                ),
              ]),
            ),
          ]),
        );
      }),
    );
  }
}
