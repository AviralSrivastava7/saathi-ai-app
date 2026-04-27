import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/widgets/zen_aura_background.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/localization/app_localizations.dart';

class NumberZenGame extends StatefulWidget {
  const NumberZenGame({super.key});
  @override State<NumberZenGame> createState() => _NumberZenGameState();
}

class _NumberZenGameState extends State<NumberZenGame> {
  final math.Random _rng = math.Random();
  int _gridCount = 9; // Start 3x3 (9 numbers)
  List<_NumberTile> _tiles = [];
  int _nextExpected = 1;
  int _level = 1;
  bool _gameOver = false;
  final Stopwatch _stopwatch = Stopwatch();
  Timer? _uiTimer;
  String _elapsed = '0.0s';

  @override
  void initState() {
    super.initState();
    _startLevel();
  }

  void _startLevel() {
    _nextExpected = 1;
    _gameOver = false;
    _tiles = List.generate(_gridCount, (i) => _NumberTile(
      number: i + 1,
      x: 20 + _rng.nextDouble() * (280),
      y: 20 + _rng.nextDouble() * (400),
      tapped: false,
    ));
    _tiles.shuffle(_rng);
    _stopwatch.reset();
    _stopwatch.start();
    _uiTimer?.cancel();
    _uiTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (mounted && !_gameOver) {
        setState(() {
          _elapsed = '${(_stopwatch.elapsedMilliseconds / 1000).toStringAsFixed(1)}s';
        });
      }
    });
    setState(() {});
  }

  void _tapNumber(int number) {
    if (_gameOver) return;
    if (number == _nextExpected) {
      setState(() {
        _tiles.firstWhere((t) => t.number == number).tapped = true;
        _nextExpected++;
      });
      if (_nextExpected > _gridCount) {
        _stopwatch.stop();
        _uiTimer?.cancel();
        if (_gridCount < 25) {
          _level++;
          _gridCount = (_gridCount == 9) ? 12 : (_gridCount == 12 ? 16 : (_gridCount == 16 ? 20 : 25));
          Future.delayed(const Duration(milliseconds: 600), () {
            if (mounted) _startLevel();
          });
        } else {
          setState(() => _gameOver = true);
        }
      }
    }
  }

  @override
  void dispose() {
    _uiTimer?.cancel();
    _stopwatch.stop();
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
        title: Text(AppLocalizations.of(context).t('number_zen'), style: TextStyle(color: cs.onSurface, fontWeight: FontWeight.bold)),
      ),
      body: ZenAuraBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                GlassCard(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  borderRadius: 16,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Level $_level', style: TextStyle(color: cs.onSurface, fontWeight: FontWeight.bold, fontSize: 16)),
                      Text(_elapsed, style: const TextStyle(color: Color(0xFF8B5CF6), fontWeight: FontWeight.bold, fontSize: 16)),
                      Text('Next: $_nextExpected', style: TextStyle(color: cs.onSurface.withOpacity(0.6), fontSize: 14)),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text('Tap numbers 1 → $_gridCount in order', style: TextStyle(color: cs.onSurface.withOpacity(0.4), fontSize: 13)),
                const SizedBox(height: 12),
                Expanded(
                  child: _gameOver && _gridCount >= 25 ? _buildComplete(cs) : _buildBoard(cs),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBoard(ColorScheme cs) {
    final crossAxisCount = _gridCount <= 9 ? 3 : (_gridCount <= 16 ? 4 : 5);
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: _tiles.length,
      itemBuilder: (context, index) {
        final tile = _tiles[index];
        return GestureDetector(
          onTap: () => _tapNumber(tile.number),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: tile.tapped
                  ? const Color(0xFF10B981).withOpacity(0.2)
                  : (tile.number == _nextExpected
                      ? const Color(0xFF8B5CF6).withOpacity(0.1)
                      : cs.onSurface.withOpacity(0.05)),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: tile.tapped
                    ? const Color(0xFF10B981).withOpacity(0.5)
                    : cs.onSurface.withOpacity(0.1),
                width: 1.5,
              ),
            ),
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: tile.tapped
                    ? Icon(Icons.check_rounded, key: ValueKey('done_${tile.number}'), color: const Color(0xFF10B981), size: 28)
                    : Text(
                        '${tile.number}',
                        key: ValueKey('num_${tile.number}'),
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: cs.onSurface,
                        ),
                      ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildComplete(ColorScheme cs) {
    return Center(
      child: GlassCard(
        padding: const EdgeInsets.all(32),
        borderRadius: 28,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🎯', style: TextStyle(fontSize: 56)),
            const SizedBox(height: 16),
            Text(AppLocalizations.of(context).t('zen_master'), style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: cs.onSurface)),
            const SizedBox(height: 8),
            Text(AppLocalizations.of(context).t('all_levels_complete', {'val': _elapsed}), style: const TextStyle(fontSize: 16, color: Color(0xFF8B5CF6), fontWeight: FontWeight.w600)),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _gridCount = 9;
                  _level = 1;
                  _startLevel();
                });
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF8B5CF6), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
              child: Text(AppLocalizations.of(context).t('play_again'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}

class _NumberTile {
  final int number;
  final double x, y;
  bool tapped;
  _NumberTile({required this.number, required this.x, required this.y, required this.tapped});
}
