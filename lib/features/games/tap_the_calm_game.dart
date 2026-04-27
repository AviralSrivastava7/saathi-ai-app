import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/widgets/zen_aura_background.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/localization/app_localizations.dart';

class TapTheCalmGame extends StatefulWidget {
  const TapTheCalmGame({super.key});
  @override State<TapTheCalmGame> createState() => _TapTheCalmGameState();
}

class _TapTheCalmGameState extends State<TapTheCalmGame> with TickerProviderStateMixin {
  final List<_CalmCircle> _circles = [];
  final math.Random _rng = math.Random();
  int _score = 0;
  int _missed = 0;
  Timer? _spawnTimer;
  bool _gameOver = false;
  static const int _maxMissed = 5;

  final List<Color> _palette = const [
    Color(0xFF7C3AED), Color(0xFF6366F1), Color(0xFF3B82F6),
    Color(0xFF14B8A6), Color(0xFF10B981), Color(0xFFF59E0B),
    Color(0xFFEC4899), Color(0xFF8B5CF6),
  ];

  @override
  void initState() {
    super.initState();
    _startGame();
  }

  void _startGame() {
    _score = 0;
    _missed = 0;
    _gameOver = false;
    _circles.clear();
    _spawnTimer?.cancel();
    _spawnTimer = Timer.periodic(const Duration(milliseconds: 900), (_) {
      if (!mounted || _gameOver) return;
      _spawnCircle();
    });
  }

  void _spawnCircle() {
    final size = 50.0 + _rng.nextDouble() * 40;
    final circle = _CalmCircle(
      id: DateTime.now().microsecondsSinceEpoch,
      x: 20 + _rng.nextDouble() * (MediaQuery.of(context).size.width - 80),
      y: 100 + _rng.nextDouble() * (MediaQuery.of(context).size.height - 300),
      size: size,
      color: _palette[_rng.nextInt(_palette.length)],
      createdAt: DateTime.now(),
      lifetime: Duration(milliseconds: 2000 + _rng.nextInt(1500)),
    );
    setState(() => _circles.add(circle));
    Future.delayed(circle.lifetime, () {
      if (!mounted) return;
      final stillExists = _circles.any((c) => c.id == circle.id);
      if (stillExists) {
        setState(() {
          _circles.removeWhere((c) => c.id == circle.id);
          _missed++;
          if (_missed >= _maxMissed) _endGame();
        });
      }
    });
  }

  void _tapCircle(_CalmCircle circle) {
    setState(() {
      _circles.removeWhere((c) => c.id == circle.id);
      _score += 10;
    });
  }

  void _endGame() {
    _gameOver = true;
    _spawnTimer?.cancel();
    _circles.clear();
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
        title: Text(AppLocalizations.of(context).t('tap_the_calm'), style: TextStyle(color: cs.onSurface, fontWeight: FontWeight.bold)),
      ),
      body: ZenAuraBackground(
        child: SafeArea(
          child: _gameOver ? _buildGameOver(cs) : _buildGameArea(cs),
        ),
      ),
    );
  }

  Widget _buildGameArea(ColorScheme cs) {
    return Stack(
      children: [
        // Score & missed
        Positioned(
          top: 8, left: 20, right: 20,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GlassCard(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                borderRadius: 16,
                child: Text(AppLocalizations.of(context).t('score', {'val': '$_score'}), style: TextStyle(color: cs.onSurface, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
              GlassCard(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                borderRadius: 16,
                child: Row(
                  children: [
                    ...List.generate(_maxMissed, (i) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: Icon(Icons.favorite, size: 16, color: i < (_maxMissed - _missed) ? Colors.pinkAccent : Colors.grey.withOpacity(0.3)),
                    )),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Circles
        ..._circles.map((c) {
          final elapsed = DateTime.now().difference(c.createdAt).inMilliseconds;
          final progress = (elapsed / c.lifetime.inMilliseconds).clamp(0.0, 1.0);
          final opacity = (1.0 - progress).clamp(0.0, 1.0);
          final scale = 0.5 + (1.0 - progress) * 0.5;
          return Positioned(
            left: c.x, top: c.y,
            child: GestureDetector(
              onTap: () => _tapCircle(c),
              child: Opacity(
                opacity: opacity,
                child: Transform.scale(
                  scale: scale,
                  child: Container(
                    width: c.size, height: c.size,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: c.color.withOpacity(0.3),
                      border: Border.all(color: c.color.withOpacity(0.6), width: 2),
                      boxShadow: [BoxShadow(color: c.color.withOpacity(0.2), blurRadius: 20, spreadRadius: 5)],
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
        // Instructions
        if (_score == 0 && _circles.isEmpty)
          Center(
            child: Text(AppLocalizations.of(context).t('tap_the_calm_instr'), style: TextStyle(color: cs.onSurface.withOpacity(0.4), fontSize: 16, fontStyle: FontStyle.italic)),
          ),
      ],
    );
  }

  Widget _buildGameOver(ColorScheme cs) {
    return Center(
      child: GlassCard(
        padding: const EdgeInsets.all(32),
        borderRadius: 28,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🧘', style: TextStyle(fontSize: 56)),
            const SizedBox(height: 16),
            Text(AppLocalizations.of(context).t('peace_achieved'), style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: cs.onSurface)),
            const SizedBox(height: 8),
            Text(AppLocalizations.of(context).t('score', {'val': '$_score'}), style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Color(0xFF7C3AED))),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _startGame,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7C3AED),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              child: Text(AppLocalizations.of(context).t('play_again'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}

class _CalmCircle {
  final int id;
  final double x, y, size;
  final Color color;
  final DateTime createdAt;
  final Duration lifetime;
  _CalmCircle({required this.id, required this.x, required this.y, required this.size, required this.color, required this.createdAt, required this.lifetime});
}
