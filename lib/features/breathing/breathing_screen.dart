import 'package:flutter/material.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/widgets/zen_aura_background.dart';
import '../../core/widgets/glass_card.dart';

class BreathingScreen extends StatefulWidget {
  const BreathingScreen({super.key});
  @override State<BreathingScreen> createState() => _BreathingScreenState();
}
class _BreathingScreenState extends State<BreathingScreen> with SingleTickerProviderStateMixin {
  bool _isBreathing = false;
  String _instKey = 'tap_to_start';
  late AnimationController _ac;
  late Animation<double> _sa;

  @override
  void initState() {
    super.initState();
    _ac = AnimationController(vsync: this, duration: const Duration(seconds: 4));
    _sa = Tween<double>(begin: 0.6, end: 1.0).animate(CurvedAnimation(parent: _ac, curve: Curves.easeInOut));
  }

  @override void dispose() { _ac.dispose(); super.dispose(); }

  void _start() {
    setState(() { _isBreathing = !_isBreathing; });
    if (_isBreathing) { _breatheCycle(); }
  }

  Future<void> _breatheCycle() async {
    while (_isBreathing && mounted) {
      if (!mounted) break;
      setState(() => _instKey = 'breathe_in');
      await _ac.forward();
      if (!_isBreathing || !mounted) break;
      setState(() => _instKey = 'hold');
      await Future.delayed(const Duration(seconds: 1));
      if (!_isBreathing || !mounted) break;
      setState(() => _instKey = 'breathe_out');
      await _ac.reverse();
      if (!_isBreathing || !mounted) break;
      await Future.delayed(const Duration(seconds: 1));
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(loc.t('breathing'), style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded), onPressed: () => Navigator.pop(context)),
      ),
      body: ZenAuraBackground(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedBuilder(
                animation: _sa,
                builder: (context, child) => Transform.scale(
                  scale: _sa.value,
                  child: Container(
                    width: 250, height: 250,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.teal.withOpacity(0.05),
                      border: Border.all(color: Colors.teal.withOpacity(0.35), width: 3),
                      boxShadow: [
                        BoxShadow(color: Colors.teal.withOpacity(0.15), blurRadius: 40, spreadRadius: 10),
                      ],
                    ),
                    child: Center(
                      child: GlassCard(
                        padding: const EdgeInsets.all(12),
                        borderRadius: 60,
                        color: Colors.white.withOpacity(0.05),
                        child: Text(loc.t(_instKey), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.teal, letterSpacing: -0.5)),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 80),
              ElevatedButton(
                onPressed: _start,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isBreathing ? Colors.red.withOpacity(0.8) : Colors.teal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 56, vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(_isBreathing ? Icons.stop_rounded : Icons.play_arrow_rounded, size: 28),
                    const SizedBox(width: 8),
                    Text(_isBreathing ? loc.t('stop') : loc.t('start_breathing'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const SizedBox(height: 48),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 48),
                child: Text(
                  loc.t('breathing_footer_instr'),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: colorScheme.onSurface.withOpacity(0.5), fontSize: 13, fontStyle: FontStyle.italic),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
