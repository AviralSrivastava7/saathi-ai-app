import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:async';
import '../../core/widgets/zen_aura_background.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/localization/app_localizations.dart';

class EmotionBubblesGame extends StatefulWidget {
  const EmotionBubblesGame({super.key});
  @override State<EmotionBubblesGame> createState() => _EmotionBubblesGameState();
}

class _EmotionBubblesGameState extends State<EmotionBubblesGame> {
  final math.Random _rng = math.Random();
  final List<_Bubble> _bubbles = [];
  int _score = 0;
  int _popped = 0;
  Timer? _spawnTimer;
  bool _gameActive = false;

  static const _negatives = ['emo_worry', 'emo_fear', 'emo_doubt', 'thought_judging', 'emo_stress', 'emo_guilt', 'emo_shame', 'emo_envy'];
  static const _positives = ['emo_joy', 'emo_love', 'emo_hope', 'emo_peace', 'emo_calm', 'emo_grace', 'emo_kind', 'emo_brave'];

  @override
  void initState() {
    super.initState();
    // Don't start automatically, or start once mounted
    WidgetsBinding.instance.addPostFrameCallback((_) => _startGame());
  }

  void _startGame() {
    _score = 0;
    _popped = 0;
    _gameActive = true;
    _bubbles.clear();
    _spawnTimer?.cancel();
    _spawnTimer = Timer.periodic(const Duration(milliseconds: 700), (_) {
      if (!mounted || !_gameActive) return;
      _spawnBubble();
    });
  }

  void _spawnBubble() {
    final isNegative = _rng.nextBool();
    final texts = isNegative ? _negatives : _positives;
    final screenW = MediaQuery.of(context).size.width;
    _bubbles.add(_Bubble(
      id: DateTime.now().microsecondsSinceEpoch,
      text: texts[_rng.nextInt(texts.length)],
      isNegative: isNegative,
      x: 20 + _rng.nextDouble() * (screenW - 120),
      y: MediaQuery.of(context).size.height - 100,
      speed: 0.5 + _rng.nextDouble() * 1.0,
      size: 60 + _rng.nextDouble() * 30,
    ));
    setState(() {});
    _updateBubbles();
  }

  void _updateBubbles() {
    Timer.periodic(const Duration(milliseconds: 32), (timer) {
      if (!mounted || !_gameActive) { timer.cancel(); return; }
      setState(() {
        for (int i = _bubbles.length - 1; i >= 0; i--) {
          _bubbles[i].y -= _bubbles[i].speed;
          if (_bubbles[i].y < -100) {
            if (_bubbles[i].isNegative) {
              // Negative escaped — bad
              _score -= 5;
            } else {
              // Positive flew away — good
              _score += 5;
            }
            _bubbles.removeAt(i);
          }
        }
      });
      if (_popped >= 30) {
        timer.cancel();
        _gameActive = false;
        _spawnTimer?.cancel();
        setState(() {});
      }
    });
  }

  void _tapBubble(_Bubble bubble) {
    if (bubble.isNegative) {
      _score += 10;
      _popped++;
    } else {
      _score -= 5; // Don't pop positive ones!
    }
    _bubbles.removeWhere((b) => b.id == bubble.id);
    setState(() {});
  }

  @override
  void dispose() {
    _spawnTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent, elevation: 0,
        leading: IconButton(icon: Icon(Icons.arrow_back_ios_rounded, color: cs.onSurface), onPressed: () => Navigator.pop(context)),
        title: Text(AppLocalizations.of(context).t('emotion_bubbles'), style: TextStyle(color: cs.onSurface, fontWeight: FontWeight.bold)),
      ),
      body: ZenAuraBackground(
        child: SafeArea(
          child: Stack(
            children: [
              // Score
              Positioned(
                top: 8, left: 20, right: 20,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GlassCard(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      borderRadius: 16,
                      child: Text(AppLocalizations.of(context).t('score', {'val': '$_score'}), style: TextStyle(color: cs.onSurface, fontWeight: FontWeight.bold)),
                    ),
                    GlassCard(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      borderRadius: 16,
                      child: Text(AppLocalizations.of(context).t('popped_stat', {'val': '$_popped'}), style: TextStyle(color: cs.onSurface.withOpacity(0.7))),
                    ),
                  ],
                ),
              ),
              // Hint
              Positioned(
                top: 56, left: 24, right: 24,
                child: Text(AppLocalizations.of(context).t('bubble_hint'), textAlign: TextAlign.center, style: TextStyle(color: cs.onSurface.withOpacity(0.4), fontSize: 12, fontStyle: FontStyle.italic)),
              ),
              // Bubbles
              ..._bubbles.map((b) => Positioned(
                left: b.x, top: b.y,
                child: GestureDetector(
                  onTap: () => _tapBubble(b),
                  child: Container(
                    width: b.size, height: b.size,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: b.isNegative
                          ? Colors.red.withOpacity(0.15)
                          : Colors.green.withOpacity(0.15),
                      border: Border.all(
                        color: b.isNegative ? Colors.red.withOpacity(0.4) : Colors.green.withOpacity(0.4),
                        width: 1.5,
                      ),
                      boxShadow: [BoxShadow(color: (b.isNegative ? Colors.red : Colors.green).withOpacity(0.15), blurRadius: 15)],
                    ),
                    child: Center(
                      child: Text(AppLocalizations.of(context).t(b.text), textAlign: TextAlign.center, style: TextStyle(fontSize: b.size < 70 ? 9 : 10, fontWeight: FontWeight.w600, color: cs.onSurface)),
                    ),
                  ),
                ),
              )),
              // Game over
              if (!_gameActive)
                Center(
                  child: GlassCard(
                    padding: const EdgeInsets.all(32),
                    borderRadius: 28,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('🫧', style: TextStyle(fontSize: 56)),
                        const SizedBox(height: 16),
                        Text(AppLocalizations.of(context).t('thoughts_cleansed'), style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: cs.onSurface)),
                        const SizedBox(height: 8),
                        Text(AppLocalizations.of(context).t('score', {'val': '$_score'}), style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF10B981))),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () => setState(_startGame),
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                          child: Text(AppLocalizations.of(context).t('play_again'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Bubble {
  final int id;
  final String text;
  final bool isNegative;
  final double x, size, speed;
  double y;
  _Bubble({required this.id, required this.text, required this.isNegative, required this.x, required this.y, required this.speed, required this.size});
}
