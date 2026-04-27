import 'package:flutter/material.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/widgets/zen_aura_background.dart';
import '../../core/widgets/glass_card.dart';

class GroundingScreen extends StatefulWidget {
  const GroundingScreen({super.key});

  @override State<GroundingScreen> createState() => _GroundingScreenState();
}

class _GroundingScreenState extends State<GroundingScreen> {
  int _currentStep = 0;
  final List<_GroundingStep> _steps = [
    _GroundingStep(title: 'Sight', instruction: 'Find 5 things you can see around you.', emoji: '👁️', count: 5, color: Colors.blue),
    _GroundingStep(title: 'Touch', instruction: 'Find 4 things you can touch or feel.', emoji: '✋', count: 4, color: Colors.orange),
    _GroundingStep(title: 'Sound', instruction: 'Find 3 things you can hear right now.', emoji: '👂', count: 3, color: Colors.purple),
    _GroundingStep(title: 'Smell', instruction: 'Find 2 things you can smell (or favorite smells).', emoji: '👃', count: 2, color: Colors.green),
    _GroundingStep(title: 'Taste', instruction: 'Find 1 thing you can taste (or a favorite taste).', emoji: '👅', count: 1, color: Colors.red),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final loc = AppLocalizations.of(context);
    final step = _steps[_currentStep];

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: Icon(Icons.arrow_back_ios_new_rounded, color: colorScheme.onSurface), onPressed: () => Navigator.pop(context)),
        title: Text(
          loc.t('grounding_exercise'),
          style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.onSurface),
        ),
      ),
      body: ZenAuraBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                const SizedBox(height: 20),
                LinearProgressIndicator(
                  value: (_currentStep + 1) / _steps.length,
                  backgroundColor: colorScheme.onSurface.withOpacity(0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(step.color),
                  borderRadius: BorderRadius.circular(10),
                  minHeight: 12,
                ),
                const SizedBox(height: 12),
                Text('Step ${_currentStep + 1} of ${_steps.length}', style: TextStyle(color: colorScheme.onSurface.withOpacity(0.6), fontWeight: FontWeight.bold)),
                
                const Spacer(),
                
                GlassCard(
                  padding: const EdgeInsets.all(32),
                  borderRadius: 36,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(step.emoji, style: const TextStyle(fontSize: 64)),
                      const SizedBox(height: 24),
                      Text(step.title, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: -1)),
                      const SizedBox(height: 16),
                      Text(step.instruction, textAlign: TextAlign.center, style: TextStyle(fontSize: 18, color: colorScheme.onSurface.withOpacity(0.8), height: 1.5)),
                      const SizedBox(height: 40),
                      ElevatedButton(
                        onPressed: () {
                          if (_currentStep < _steps.length - 1) {
                            setState(() => _currentStep++);
                          } else {
                            _showCompletionDialog();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: step.color,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 18),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          elevation: 0,
                        ),
                        child: Text(_currentStep < _steps.length - 1 ? 'Done' : 'Complete', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
                
                const Spacer(),
                
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Text(
                    'The 5-4-3-2-1 technique helps bring you back to the present moment by focusing on your senses.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: colorScheme.onSurface.withOpacity(0.5), fontSize: 13, fontStyle: FontStyle.italic),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.transparent,
        contentPadding: EdgeInsets.zero,
        content: GlassCard(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('✨', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 20),
              const Text('Well Done!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              const Text('You have successfully completed the grounding exercise. Take a deep breath and carry this peace with you.', textAlign: TextAlign.center),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Close SOS screen
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.purple, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                child: const Text('Return Home', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GroundingStep {
  final String title, instruction, emoji;
  final int count;
  final Color color;
  _GroundingStep({required this.title, required this.instruction, required this.emoji, required this.count, required this.color});
}
