import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/widgets/zen_aura_background.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/localization/app_localizations.dart';

class MindfulMatchGame extends StatefulWidget {
  const MindfulMatchGame({super.key});
  @override State<MindfulMatchGame> createState() => _MindfulMatchGameState();
}

class _MindfulMatchGameState extends State<MindfulMatchGame> {
  static const List<String> _emojiPool = [
    '🌸', '🦋', '🌿', '🕊️', '🌊', '🍃', '🌙', '☁️',
    '🧘', '🌈', '🌻', '💎', '🔮', '🪷', '🫧', '🌺',
  ];

  List<String> _cards = [];
  List<bool> _revealed = [];
  List<bool> _matched = [];
  int? _firstIndex;
  int _moves = 0;
  int _pairs = 0;
  bool _inputLocked = false;
  final int _gridSize = 16; // 4x4

  @override
  void initState() {
    super.initState();
    _startGame();
  }

  void _startGame() {
    final rng = math.Random();
    final numPairs = _gridSize ~/ 2;
    final selected = (_emojiPool.toList()..shuffle(rng)).take(numPairs).toList();
    _cards = [...selected, ...selected]..shuffle(rng);
    _revealed = List.filled(_gridSize, false);
    _matched = List.filled(_gridSize, false);
    _firstIndex = null;
    _moves = 0;
    _pairs = 0;
    _inputLocked = false;
    setState(() {});
  }

  void _onCardTap(int index) {
    if (_inputLocked || _revealed[index] || _matched[index]) return;

    setState(() => _revealed[index] = true);

    if (_firstIndex == null) {
      _firstIndex = index;
    } else {
      _moves++;
      _inputLocked = true;
      final first = _firstIndex!;

      if (_cards[first] == _cards[index]) {
        // Match!
        setState(() {
          _matched[first] = true;
          _matched[index] = true;
          _pairs++;
        });
        _firstIndex = null;
        _inputLocked = false;
      } else {
        // No match — flip back
        Timer(const Duration(milliseconds: 600), () {
          if (mounted) {
            setState(() {
              _revealed[first] = false;
              _revealed[index] = false;
            });
            _firstIndex = null;
            _inputLocked = false;
          }
        });
      }
    }
  }

  bool get _allMatched => _pairs >= _gridSize ~/ 2;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent, elevation: 0,
        leading: IconButton(icon: Icon(Icons.arrow_back_ios_rounded, color: cs.onSurface), onPressed: () => Navigator.pop(context)),
        title: Text(AppLocalizations.of(context).t('mindful_match'), style: TextStyle(color: cs.onSurface, fontWeight: FontWeight.bold)),
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
                      Text('Moves: $_moves', style: TextStyle(color: cs.onSurface, fontWeight: FontWeight.bold)),
                      Text('Pairs: $_pairs/${_gridSize ~/ 2}', style: const TextStyle(color: Color(0xFF14B8A6), fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: _allMatched ? _buildWinScreen(cs) : _buildGrid(cs),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGrid(ColorScheme cs) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: _gridSize,
      itemBuilder: (context, index) {
        final isRevealed = _revealed[index] || _matched[index];
        return GestureDetector(
          onTap: () => _onCardTap(index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            decoration: BoxDecoration(
              color: _matched[index]
                  ? const Color(0xFF14B8A6).withOpacity(0.15)
                  : (isRevealed ? const Color(0xFF6366F1).withOpacity(0.2) : cs.onSurface.withOpacity(0.06)),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _matched[index]
                    ? const Color(0xFF14B8A6).withOpacity(0.5)
                    : (isRevealed ? const Color(0xFF6366F1).withOpacity(0.4) : cs.onSurface.withOpacity(0.1)),
                width: 1.5,
              ),
              boxShadow: _matched[index]
                  ? [BoxShadow(color: const Color(0xFF14B8A6).withOpacity(0.2), blurRadius: 10)]
                  : [],
            ),
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: isRevealed
                    ? Text(_cards[index], key: ValueKey('emoji_$index'), style: const TextStyle(fontSize: 28))
                    : Icon(Icons.spa_rounded, key: ValueKey('hidden_$index'), color: cs.onSurface.withOpacity(0.2), size: 24),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildWinScreen(ColorScheme cs) {
    return Center(
      child: GlassCard(
        padding: const EdgeInsets.all(32),
        borderRadius: 28,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🧠', style: TextStyle(fontSize: 56)),
            const SizedBox(height: 16),
            Text(AppLocalizations.of(context).t('brain_mastery'), style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: cs.onSurface)),
            const SizedBox(height: 8),
            Text(AppLocalizations.of(context).t('completed_in_moves', {'val': '$_moves'}), style: const TextStyle(fontSize: 16, color: Color(0xFF14B8A6), fontWeight: FontWeight.w600)),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => setState(_startGame),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF14B8A6), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
              child: Text(AppLocalizations.of(context).t('play_again'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
