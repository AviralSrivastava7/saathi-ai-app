import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/widgets/zen_aura_background.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/localization/app_localizations.dart';

class CatchTheLightGame extends StatefulWidget {
  const CatchTheLightGame({super.key});
  @override State<CatchTheLightGame> createState() => _CatchTheLightGameState();
}

class _CatchTheLightGameState extends State<CatchTheLightGame> {
  final math.Random _rng = math.Random();
  double _basketX = 0.5;
  int _score = 0;
  int _lives = 3;
  bool _gameOver = false;
  final List<_FallingItem> _items = [];
  Timer? _spawnTimer;
  Timer? _updateTimer;

  @override
  void initState() {
    super.initState();
    _startGame();
  }

  void _startGame() {
    _basketX = 0.5;
    _score = 0;
    _lives = 3;
    _gameOver = false;
    _items.clear();
    _spawnTimer?.cancel();
    _updateTimer?.cancel();
    _spawnTimer = Timer.periodic(const Duration(milliseconds: 800), (_) {
      if (!mounted || _gameOver) return;
      _spawnItem();
    });
    _updateTimer = Timer.periodic(const Duration(milliseconds: 32), (_) {
      if (!mounted || _gameOver) return;
      _updateItems();
    });
    setState(() {});
  }

  void _spawnItem() {
    final isStar = _rng.nextDouble() > 0.3;
    _items.add(_FallingItem(
      x: _rng.nextDouble(),
      y: 0,
      isStar: isStar,
      speed: 0.004 + _rng.nextDouble() * 0.003 + (_score / 500) * 0.002,
    ));
  }

  void _updateItems() {
    const basketWidth = 0.2;
    setState(() {
      for (int i = _items.length - 1; i >= 0; i--) {
        _items[i].y += _items[i].speed;
        if (_items[i].y > 0.82 && _items[i].y < 0.92) {
          if ((_items[i].x - _basketX).abs() < basketWidth / 2) {
            if (_items[i].isStar) {
              _score += 10;
            } else {
              _lives--;
              if (_lives <= 0) {
                _gameOver = true;
                _spawnTimer?.cancel();
                _updateTimer?.cancel();
              }
            }
            _items.removeAt(i);
            continue;
          }
        }
        if (_items[i].y > 1.1) {
          if (_items[i].isStar) {
            _lives--;
            if (_lives <= 0) {
              _gameOver = true;
              _spawnTimer?.cancel();
              _updateTimer?.cancel();
            }
          }
          _items.removeAt(i);
        }
      }
    });
  }

  @override
  void dispose() {
    _spawnTimer?.cancel();
    _updateTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final size = MediaQuery.of(context).size;
    final localization = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent, elevation: 0,
        leading: IconButton(icon: Icon(Icons.arrow_back_ios_rounded, color: cs.onSurface), onPressed: () => Navigator.pop(context)),
        title: Text(localization.t('game_catch_light'), style: TextStyle(color: cs.onSurface, fontWeight: FontWeight.bold)),
      ),
      body: ZenAuraBackground(
        child: SafeArea(
          child: _gameOver ? _buildGameOver(cs, localization) : _buildGame(cs, size, localization),
        ),
      ),
    );
  }

  Widget _buildGame(ColorScheme cs, Size size, AppLocalizations localization) {
    return GestureDetector(
      onPanUpdate: (details) {
        setState(() {
          _basketX = (details.localPosition.dx / size.width).clamp(0.1, 0.9);
        });
      },
      onTapDown: (details) {
        setState(() {
          _basketX = (details.localPosition.dx / size.width).clamp(0.1, 0.9);
        });
      },
      child: Stack(
        children: [
          Positioned(
            top: 8, left: 20, right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GlassCard(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  borderRadius: 16,
                  child: Text('⭐ $_score', style: TextStyle(color: cs.onSurface, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
                Row(
                  children: List.generate(3, (i) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Icon(Icons.favorite, size: 20, color: i < _lives ? Colors.pinkAccent : Colors.grey.withOpacity(0.3)),
                  )),
                ),
              ],
            ),
          ),
          ..._items.map((item) {
            return Positioned(
              left: item.x * size.width - 20,
              top: item.y * (size.height - 100),
              child: Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: item.isStar
                      ? const Color(0xFFFBBF24).withOpacity(0.2)
                      : const Color(0xFF64748B).withOpacity(0.2),
                  boxShadow: [
                    if (item.isStar)
                      BoxShadow(color: const Color(0xFFFBBF24).withOpacity(0.3), blurRadius: 15),
                  ],
                ),
                child: Center(
                  child: Text(
                    item.isStar ? '⭐' : '🌑',
                    style: const TextStyle(fontSize: 22),
                  ),
                ),
              ),
            );
          }),
          Positioned(
            left: _basketX * size.width - 40,
            bottom: 40,
            child: Container(
              width: 80, height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF7C3AED).withOpacity(0.3),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
                border: Border.all(color: const Color(0xFF7C3AED).withOpacity(0.6), width: 2),
                boxShadow: [BoxShadow(color: const Color(0xFF7C3AED).withOpacity(0.2), blurRadius: 15)],
              ),
              child: const Center(child: Text('🧺', style: TextStyle(fontSize: 24))),
            ),
          ),
          if (_score == 0 && _items.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(localization.t('catch_light_instr'), textAlign: TextAlign.center, style: TextStyle(color: cs.onSurface.withOpacity(0.4), fontSize: 14)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildGameOver(ColorScheme cs, AppLocalizations localization) {
    return Center(
      child: GlassCard(
        padding: const EdgeInsets.all(32),
        borderRadius: 28,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🌟', style: TextStyle(fontSize: 56)),
            const SizedBox(height: 16),
            Text(localization.t('light_collected'), style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: cs.onSurface)),
            const SizedBox(height: 8),
            Text(localization.t('score', {'val': '$_score'}), style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFFFBBF24))),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => setState(_startGame),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFBBF24), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
              child: Text(localization.t('play_again'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}

class _FallingItem {
  double x, y, speed;
  final bool isStar;
  _FallingItem({required this.x, required this.y, required this.isStar, required this.speed});
}
