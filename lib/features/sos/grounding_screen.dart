import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/widgets/zen_aura_background.dart';

class GroundingScreen extends StatefulWidget {
  const GroundingScreen({super.key});

  @override
  State<GroundingScreen> createState() => _GroundingScreenState();
}

class _GroundingScreenState extends State<GroundingScreen> with TickerProviderStateMixin {
  int _currentStep = 0; 
  int _itemsCompleted = 0;
  late AnimationController _breathController;
  late AnimationController _fadeController;
  late AnimationController _pulseController;
  late AnimationController _rippleController;
  late Animation<double> _breathAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _pulseAnimation;

  final List<_GroundingStep> _steps = [
    const _GroundingStep(
      count: 5, 
      senseKey: 'grounding_see', 
      emoji: '👁️', 
      titleKey: 'see_5_title', 
      instructionKey: 'see_5_instr', 
      hintKey: 'see_5_hint', 
      gradient: [Color(0xFF667EEA), Color(0xFF764BA2)], 
      checkColor: Color(0xFF667EEA)
    ),
    const _GroundingStep(
      count: 4, 
      senseKey: 'grounding_touch', 
      emoji: '🤲', 
      titleKey: 'touch_4_title', 
      instructionKey: 'touch_4_instr', 
      hintKey: 'touch_4_hint', 
      gradient: [Color(0xFF43E97B), Color(0xFF38F9D7)], 
      checkColor: Color(0xFF43E97B)
    ),
    const _GroundingStep(
      count: 3, 
      senseKey: 'grounding_hear', 
      emoji: '👂', 
      titleKey: 'hear_3_title', 
      instructionKey: 'hear_3_instr', 
      hintKey: 'hear_3_hint', 
      checkColor: Color(0xFF4FACFE), 
      gradient: [Color(0xFF4FACFE), Color(0xFF00F2FE)]
    ),
    const _GroundingStep(
      count: 2, 
      senseKey: 'grounding_smell', 
      emoji: '👃', 
      titleKey: 'smell_2_title', 
      instructionKey: 'smell_2_instr', 
      hintKey: 'smell_2_hint', 
      gradient: [Color(0xFFF093FB), Color(0xFFF5576C)], 
      checkColor: Color(0xFFF093FB)
    ),
    const _GroundingStep(
      count: 1, 
      senseKey: 'grounding_taste', 
      emoji: '👅', 
      titleKey: 'taste_1_title', 
      instructionKey: 'taste_1_instr', 
      hintKey: 'taste_1_hint', 
      gradient: [Color(0xFFFFD700), Color(0xFFF7971E)], 
      checkColor: Color(0xFFFFD700)
    ),
  ];

  @override
  void initState() {
    super.initState();
    _breathController = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat(reverse: true);
    _breathAnimation = Tween<double>(begin: 0.85, end: 1.15).animate(CurvedAnimation(parent: _breathController, curve: Curves.easeInOut));
    _fadeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));
    _fadeController.forward();
    _pulseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));
    _rippleController = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat();
  }

  @override
  void dispose() { 
    _breathController.dispose(); 
    _fadeController.dispose(); 
    _pulseController.dispose(); 
    _rippleController.dispose(); 
    super.dispose(); 
  }

  void _goToStep(int step) { 
    HapticFeedback.mediumImpact(); 
    _fadeController.reset(); 
    setState(() { 
      _currentStep = step; 
      _itemsCompleted = 0; 
    }); 
    _fadeController.forward(); 
  }

  void _markItem() {
    HapticFeedback.lightImpact();
    final step = _steps[_currentStep - 1];
    setState(() { _itemsCompleted++; });
    if (_itemsCompleted >= step.count) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (_currentStep < 5) _goToStep(_currentStep + 1);
        else _goToStep(6);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ZenAuraBackground(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: child),
          child: _currentStep == 0 
              ? _buildIntroScreen(loc) 
              : _currentStep == 6 
                  ? _buildCompletionScreen(loc) 
                  : _buildGroundingStep(loc),
        ),
      ),
    );
  }

  Widget _buildIntroScreen(AppLocalizations loc) {
    return SafeArea(
      child: Stack(
        children: [
          ...List.generate(3, (i) => AnimatedBuilder(animation: _rippleController, builder: (context, child) {
            final progress = (_rippleController.value + i * 0.33) % 1.0;
            return Positioned.fill(child: Center(child: Container(width: 200 + (progress * 300), height: 200 + (progress * 300), decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white.withOpacity(0.08 * (1 - progress)), width: 1.5)))));
          })),
          Padding(
            padding: const EdgeInsets.all(32),
            child: Column(children: [
              Align(alignment: Alignment.topRight, child: IconButton(onPressed: () => Navigator.pop(context), icon: Icon(Icons.close_rounded, color: Colors.white.withOpacity(0.6), size: 28))),
              const Spacer(),
              AnimatedBuilder(animation: _breathAnimation, builder: (context, child) => Transform.scale(scale: _breathAnimation.value, child: Container(width: 160, height: 160, decoration: BoxDecoration(shape: BoxShape.circle, gradient: const LinearGradient(colors: [Color(0xFF667EEA), Color(0xFF764BA2)]), boxShadow: [BoxShadow(color: const Color(0xFF667EEA).withOpacity(0.4), blurRadius: 40, spreadRadius: 10)]), child: const Center(child: Text('🫁', style: TextStyle(fontSize: 64)))))),
              const SizedBox(height: 40),
              Text(loc.t('take_a_breath'), style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w800, letterSpacing: -1)),
              const SizedBox(height: 16),
              Text(loc.t('grounding_technique_desc'), textAlign: TextAlign.center, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 16, height: 1.6)),
              const Spacer(),
              AnimatedBuilder(animation: _pulseAnimation, builder: (context, child) => Transform.scale(scale: _pulseAnimation.value, child: child), child: SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () => _goToStep(1), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF667EEA), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 20), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)), shadowColor: const Color(0xFF667EEA).withOpacity(0.4)), child: Text(loc.t('im_ready'), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold))))),
              const SizedBox(height: 16),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildGroundingStep(AppLocalizations loc) {
    final step = _steps[_currentStep - 1];
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Row(children: List.generate(5, (i) => AnimatedContainer(duration: const Duration(milliseconds: 300), width: i == _currentStep - 1 ? 32 : 12, height: 6, margin: const EdgeInsets.only(right: 6), decoration: BoxDecoration(borderRadius: BorderRadius.circular(3), gradient: i < _currentStep ? LinearGradient(colors: step.gradient) : null, color: i < _currentStep ? null : Colors.white.withOpacity(0.15))))),
              IconButton(onPressed: () => Navigator.pop(context), icon: Icon(Icons.close_rounded, color: Colors.white.withOpacity(0.5))),
            ]),
            const SizedBox(height: 20),
            Container(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8), decoration: BoxDecoration(gradient: LinearGradient(colors: step.gradient), borderRadius: BorderRadius.circular(20)), child: Text(loc.t(step.senseKey), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 2))),
            const SizedBox(height: 32),
            AnimatedBuilder(animation: _breathAnimation, builder: (context, child) => Transform.scale(scale: _breathAnimation.value * 0.95, child: Text(step.emoji, style: const TextStyle(fontSize: 80)))),
            const SizedBox(height: 24),
            Text(loc.t(step.titleKey), style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800), textAlign: TextAlign.center),
            const SizedBox(height: 16),
            Text(loc.t(step.instructionKey), style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 16, height: 1.5), textAlign: TextAlign.center),
            const Spacer(),
            _buildCheckCircles(step),
            const SizedBox(height: 32),
            Text(_itemsCompleted < step.count ? loc.t('tap_a_circle') : loc.t('great_job!'), style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 14)),
          ]),
        ),
      ),
    );
  }

  Widget _buildCheckCircles(_GroundingStep step) {
    return Wrap(alignment: WrapAlignment.center, spacing: 16, children: List.generate(step.count, (i) {
      final isChecked = i < _itemsCompleted;
      return GestureDetector(onTap: isChecked ? null : _markItem, child: AnimatedContainer(duration: const Duration(milliseconds: 400), width: isChecked ? 60 : 56, height: isChecked ? 60 : 56, decoration: BoxDecoration(shape: BoxShape.circle, gradient: isChecked ? LinearGradient(colors: step.gradient) : null, color: isChecked ? null : Colors.white.withOpacity(0.08), border: Border.all(color: isChecked ? Colors.transparent : step.checkColor.withOpacity(0.3), width: 2), boxShadow: isChecked ? [BoxShadow(color: step.gradient[0].withOpacity(0.4), blurRadius: 16)] : []), child: Center(child: isChecked ? const Icon(Icons.check_rounded, color: Colors.white, size: 28) : Text('${i + 1}', style: TextStyle(color: step.checkColor.withOpacity(0.5), fontSize: 20, fontWeight: FontWeight.bold)))));
    }));
  }

  Widget _buildCompletionScreen(AppLocalizations loc) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(children: [
          const Spacer(),
          AnimatedBuilder(animation: _breathAnimation, builder: (context, child) => Transform.scale(scale: _breathAnimation.value * 0.9, child: Container(width: 160, height: 160, decoration: BoxDecoration(shape: BoxShape.circle, gradient: const LinearGradient(colors: [Color(0xFF43E97B), Color(0xFF38F9D7)]), boxShadow: [BoxShadow(color: const Color(0xFF43E97B).withOpacity(0.3), blurRadius: 40, spreadRadius: 15)]), child: const Center(child: Icon(Icons.check_rounded, color: Colors.white, size: 80))))),
          const SizedBox(height: 40),
          Text(loc.t('well_done_celeb'), style: const TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.w800)),
          const SizedBox(height: 16),
          Text(loc.t('grounding_success'), textAlign: TextAlign.center, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 17, height: 1.6)),
          const Spacer(),
          SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () => Navigator.pop(context), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF43E97B), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 20), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24))), child: Text(loc.t('i_feel_better'), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)))),
        ]),
      ),
    );
  }
}

class _GroundingStep {
  final int count; 
  final String senseKey, emoji, titleKey, instructionKey, hintKey; 
  final List<Color> gradient; 
  final Color checkColor;
  const _GroundingStep({
    required this.count, 
    required this.senseKey, 
    required this.emoji, 
    required this.titleKey, 
    required this.instructionKey, 
    required this.hintKey, 
    required this.gradient, 
    required this.checkColor
  });
}
