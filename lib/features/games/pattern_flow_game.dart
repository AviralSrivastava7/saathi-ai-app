import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/widgets/zen_aura_background.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/localization/app_localizations.dart';

class PatternFlowGame extends StatefulWidget {
  const PatternFlowGame({super.key});
  @override State<PatternFlowGame> createState() => _PatternFlowGameState();
}

class _PatternFlowGameState extends State<PatternFlowGame> {
  static const List<Color> _tileColors = [
    Color(0xFF6366F1), Color(0xFF10B981), Color(0xFFF59E0B), Color(0xFFEC4899),
  ];
  static const List<String> _tileEmojis = ['💜', '💚', '💛', '💗'];

  final math.Random _rng = math.Random();
  List<int> _sequence = [];
  int _inputIndex = 0;
  int _level = 0;
  bool _isShowingPattern = false;
  bool _gameOver = false;
  int _highlightedTile = -1;

  @override
  void initState() {
    super.initState();
    _startGame();
  }

  void _startGame() {
    _sequence = [];
    _level = 0;
    _gameOver = false;
    _inputIndex = 0;
    _nextLevel();
  }

  void _nextLevel() async {
    _level++;
    _inputIndex = 0;
    _sequence.add(_rng.nextInt(4));
    setState(() => _isShowingPattern = true);

    await Future.delayed(const Duration(milliseconds: 500));

    for (int i = 0; i < _sequence.length; i++) {
      if (!mounted) return;
      setState(() => _highlightedTile = _sequence[i]);
      await Future.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;
      setState(() => _highlightedTile = -1);
      await Future.delayed(const Duration(milliseconds: 200));
    }

    if (mounted) setState(() => _isShowingPattern = false);
  }

  void _onTileTap(int index) {
    if (_isShowingPattern || _gameOver) return;

    if (_sequence[_inputIndex] == index) {
      _inputIndex++;
      setState(() => _highlightedTile = index);
      Future.delayed(const Duration(milliseconds: 150), () {
        if (mounted) setState(() => _highlightedTile = -1);
      });

      if (_inputIndex >= _sequence.length) {
        Future.delayed(const Duration(milliseconds: 400), () {
          if (mounted) _nextLevel();
        });
      }
    } else {
      setState(() => _gameOver = true);
    }
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
        title: Text(AppLocalizations.of(context).t('pattern_flow'), style: TextStyle(color: cs.onSurface, fontWeight: FontWeight.bold)),
      ),
      body: ZenAuraBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                GlassCard(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  borderRadius: 16,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(AppLocalizations.of(context).t('level_label', {'val': '$_level'}), style: TextStyle(color: cs.onSurface, fontSize: 18, fontWeight: FontWeight.bold)),
                      Text(_isShowingPattern ? AppLocalizations.of(context).t('watch_pattern') : AppLocalizations.of(context).t('your_turn'), style: TextStyle(color: cs.onSurface.withOpacity(0.6), fontSize: 14)),
                    ],
                  ),
                ),
                const Spacer(),
                if (_gameOver)
                  _buildGameOver(cs)
                else
                  _buildGrid(cs),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGrid(ColorScheme cs) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 16, mainAxisSpacing: 16),
      itemCount: 4,
      itemBuilder: (context, index) {
        final isHighlighted = _highlightedTile == index;
        return GestureDetector(
          onTap: () => _onTileTap(index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: isHighlighted ? _tileColors[index] : _tileColors[index].withOpacity(0.2),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: _tileColors[index].withOpacity(0.5), width: 2),
              boxShadow: isHighlighted
                  ? [BoxShadow(color: _tileColors[index].withOpacity(0.5), blurRadius: 25, spreadRadius: 5)]
                  : [],
            ),
            child: Center(child: Text(_tileEmojis[index], style: TextStyle(fontSize: isHighlighted ? 48 : 36))),
          ),
        );
      },
    );
  }

  Widget _buildGameOver(ColorScheme cs) {
    return GlassCard(
      padding: const EdgeInsets.all(32),
      borderRadius: 28,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🌊', style: TextStyle(fontSize: 56)),
          const SizedBox(height: 16),
          Text(AppLocalizations.of(context).t('flow_broken'), style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: cs.onSurface)),
          const SizedBox(height: 8),
          Text(AppLocalizations.of(context).t('reached_level', {'val': '$_level'}), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Color(0xFF6366F1))),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => setState(_startGame),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6366F1), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
            child: Text(AppLocalizations.of(context).t('play_again'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
