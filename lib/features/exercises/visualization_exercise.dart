import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/widgets/zen_aura_background.dart';
import '../../core/localization/app_localizations.dart';

class VisualizationExercise extends StatefulWidget {
  const VisualizationExercise({super.key});
  @override
  State<VisualizationExercise> createState() => _VisualizationExerciseState();
}

class _VisualizationExerciseState extends State<VisualizationExercise> {
  String? _selectedScene;
  bool _isStarted = false;
  int _currentStep = 0;
  int _timer = 0;
  Timer? _exerciseTimer;

  final Map<String, VisualizationScene> _scenes = {
    'Beach': VisualizationScene(name: 'Peaceful Beach', icon: Icons.beach_access, color: const Color(0xFF00BCD4), steps: [
      'Close your eyes and imagine a beautiful beach...',
      'Feel the warm sand beneath your feet...',
      'Hear the gentle waves lapping at the shore...',
      'Feel the warm sun on your skin...',
      'Smell the fresh ocean air...',
      'Listen to seagulls calling in the distance...',
      'Feel completely peaceful and relaxed...',
    ]),
    'Forest': VisualizationScene(name: 'Forest Path', icon: Icons.forest, color: const Color(0xFF4CAF50), steps: [
      'Imagine walking through a peaceful forest...',
      'Notice the tall trees surrounding you...',
      'Hear leaves rustling in the gentle breeze...',
      'Smell the fresh pine and earth...',
      'Feel dappled sunlight on your face...',
      'Hear birds singing their songs...',
      'Feel completely safe and at peace...',
    ]),
    'Mountain': VisualizationScene(name: 'Mountain Peak', icon: Icons.landscape, color: const Color(0xFF9C27B0), steps: [
      'Picture yourself on a peaceful mountain peak...',
      'See the vast landscape stretching before you...',
      'Feel the cool, crisp mountain air...',
      'Notice clouds drifting below you...',
      'Hear the gentle wind around you...',
      'Feel strong and grounded...',
      'Experience complete serenity...',
    ]),
  };

  @override
  void dispose() { _exerciseTimer?.cancel(); super.dispose(); }

  void _startExercise() {
    if (_selectedScene == null) return;
    setState(() { _isStarted = true; _currentStep = 0; _timer = 20; });
    _exerciseTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _timer--;
        if (_timer <= 0) {
          final scene = _scenes[_selectedScene]!;
          if (_currentStep < scene.steps.length - 1) { _currentStep++; _timer = 20; }
          else _completeExercise();
        }
      });
    });
  }

  void _completeExercise() {
    _exerciseTimer?.cancel();
    showDialog(context: context, builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(children: [const Icon(Icons.check_circle, color: Color(0xFF4CAF50), size: 32), const SizedBox(width: 12), Text(AppLocalizations.of(context).t('body_scan_complete'))]),
      content: Text(AppLocalizations.of(context).t('visual_complete_desc')),
      actions: [TextButton(onPressed: () { Navigator.of(ctx).pop(); Navigator.of(context).pop(); }, child: Text(AppLocalizations.of(context).t('Done'), style: const TextStyle(color: Color(0xFF4CAF50))))],
    ));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(title: Text(AppLocalizations.of(context).t('guided_visualization'), style: TextStyle(color: cs.onSurface)), backgroundColor: Colors.transparent, elevation: 0, iconTheme: IconThemeData(color: cs.onSurface)),
      body: ZenAuraBackground(
        child: SafeArea(child: _isStarted ? _buildExerciseView(cs) : _buildSceneSelection(cs)),
      ),
    );
  }

  Widget _buildSceneSelection(ColorScheme cs) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(AppLocalizations.of(context).t('choose_your_scene'), style: TextStyle(color: cs.onSurface, fontSize: 24, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Text(AppLocalizations.of(context).t('select_peaceful_place'), style: TextStyle(color: cs.onSurface.withOpacity(0.7), fontSize: 16)),
        const SizedBox(height: 24),
        ..._scenes.entries.map((e) => _buildSceneCard(e.key, e.value, cs)),
        const SizedBox(height: 24),
        if (_selectedScene != null)
          SizedBox(width: double.infinity, height: 56, child: ElevatedButton(
            onPressed: _startExercise,
            style: ElevatedButton.styleFrom(backgroundColor: _scenes[_selectedScene]!.color, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
            child: Text(AppLocalizations.of(context).t('start_visualization'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white)),
          )),
      ]),
    );
  }

  Widget _buildSceneCard(String key, VisualizationScene scene, ColorScheme cs) {
    final sel = _selectedScene == key;
    return GestureDetector(
      onTap: () => setState(() => _selectedScene = key),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16), padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: sel ? scene.color.withOpacity(0.15) : cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: sel ? scene.color : cs.outlineVariant, width: sel ? 2 : 1),
        ),
        child: Row(children: [
          Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: scene.color.withOpacity(0.15), borderRadius: BorderRadius.circular(12)), child: Icon(scene.icon, color: scene.color, size: 32)),
          const SizedBox(width: 16),
          Expanded(child: Text(scene.name, style: TextStyle(color: cs.onSurface, fontSize: 18, fontWeight: FontWeight.w600))),
          if (sel) Icon(Icons.check_circle, color: scene.color),
        ]),
      ),
    );
  }

  Widget _buildExerciseView(ColorScheme cs) {
    final scene = _scenes[_selectedScene]!;
    return Column(children: [
      LinearProgressIndicator(value: (_currentStep + 1) / scene.steps.length, backgroundColor: cs.outlineVariant, valueColor: AlwaysStoppedAnimation<Color>(scene.color)),
      Expanded(
        child: Container(
          decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [scene.color.withOpacity(0.15), Colors.transparent])),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(scene.icon, size: 80, color: scene.color),
                const SizedBox(height: 32),
                Text('$_timer', style: TextStyle(color: scene.color, fontSize: 48, fontWeight: FontWeight.bold)),
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(color: cs.surfaceContainerHighest, borderRadius: BorderRadius.circular(16)),
                  child: Text(scene.steps[_currentStep], style: TextStyle(color: cs.onSurface, fontSize: 20, height: 1.6), textAlign: TextAlign.center),
                ),
                const SizedBox(height: 24),
                Text('Step ${_currentStep + 1} of ${scene.steps.length}', style: TextStyle(color: cs.onSurface.withOpacity(0.6), fontSize: 14)),
              ]),
            ),
          ),
        ),
      ),
    ]);
  }
}

class VisualizationScene {
  final String name;
  final IconData icon;
  final Color color;
  final List<String> steps;
  VisualizationScene({required this.name, required this.icon, required this.color, required this.steps});
}
