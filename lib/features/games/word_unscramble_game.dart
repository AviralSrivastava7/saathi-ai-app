import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/widgets/zen_aura_background.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/localization/app_localizations.dart';

class WordUnscrambleGame extends StatefulWidget {
  const WordUnscrambleGame({super.key});
  @override State<WordUnscrambleGame> createState() => _WordUnscrambleGameState();
}

class _WordUnscrambleGameState extends State<WordUnscrambleGame> {
  static const List<Map<String, String>> _words = [
    {'word': 'PEACE', 'hint': 'hint_peace'},
    {'word': 'BRAVE', 'hint': 'hint_brave'},
    {'word': 'HAPPY', 'hint': 'hint_happy'},
    {'word': 'CALM', 'hint': 'hint_calm'},
    {'word': 'SMILE', 'hint': 'hint_smile'},
    {'word': 'HOPE', 'hint': 'hint_hope'},
    {'word': 'LOVE', 'hint': 'hint_love'},
    {'word': 'GRACE', 'hint': 'hint_grace'},
    {'word': 'DREAM', 'hint': 'hint_dream'},
    {'word': 'TRUST', 'hint': 'hint_trust'},
    {'word': 'KIND', 'hint': 'hint_kind'},
    {'word': 'RELAX', 'hint': 'hint_relax'},
    {'word': 'SHINE', 'hint': 'hint_shine'},
    {'word': 'BLISS', 'hint': 'hint_bliss'},
    {'word': 'CHARM', 'hint': 'hint_charm'},
  ];

  final math.Random _rng = math.Random();
  int _currentIndex = 0;
  int _score = 0;
  late List<String> _scrambled;
  List<String> _answer = [];
  bool _solved = false;
  bool _allDone = false;
  late List<int> _wordOrder;

  @override
  void initState() {
    super.initState();
    _wordOrder = List.generate(_words.length, (i) => i)..shuffle(_rng);
    _loadWord();
  }

  void _startGame() {
    _currentIndex = 0;
    _score = 0;
    _allDone = false;
    _wordOrder.shuffle(_rng);
    _loadWord();
  }

  void _loadWord() {
    if (_currentIndex >= _words.length) {
      setState(() => _allDone = true);
      return;
    }
    final word = _words[_wordOrder[_currentIndex]]['word']!;
    _scrambled = word.split('')..shuffle(_rng);
    // Make sure it's actually scrambled
    while (_scrambled.join() == word && word.length > 1) {
      _scrambled.shuffle(_rng);
    }
    _answer = [];
    _solved = false;
    setState(() {});
  }

  void _tapLetter(int index) {
    if (_solved) return;
    final letter = _scrambled[index];
    setState(() {
      _answer.add(letter);
      _scrambled[index] = ''; // Mark used
    });
    _checkAnswer();
  }

  void _removeLetter(int index) {
    if (_solved) return;
    final letter = _answer[index];
    setState(() {
      _answer.removeAt(index);
      // Put letter back
      for (int i = 0; i < _scrambled.length; i++) {
        if (_scrambled[i].isEmpty) {
          _scrambled[i] = letter;
          break;
        }
      }
    });
  }

  void _checkAnswer() {
    final word = _words[_wordOrder[_currentIndex]]['word']!;
    if (_answer.join() == word) {
      setState(() {
        _solved = true;
        _score += 10;
      });
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) {
          _currentIndex++;
          _loadWord();
        }
      });
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
        title: Text(AppLocalizations.of(context).t('word_unscramble'), style: TextStyle(color: cs.onSurface, fontWeight: FontWeight.bold)),
      ),
      body: ZenAuraBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: _allDone ? _buildComplete(cs) : _buildPuzzle(cs),
          ),
        ),
      ),
    );
  }

  Widget _buildPuzzle(ColorScheme cs) {
    final hint = _words[_wordOrder[_currentIndex]]['hint']!;
    final wordLen = _words[_wordOrder[_currentIndex]]['word']!.length;
    return Column(
      children: [
        GlassCard(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          borderRadius: 16,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(AppLocalizations.of(context).t('score', {'val': '$_score'}), style: TextStyle(color: cs.onSurface, fontWeight: FontWeight.bold, fontSize: 16)),
              Text('${_currentIndex + 1}/${_words.length}', style: TextStyle(color: cs.onSurface.withOpacity(0.6))),
            ],
          ),
        ),
        const Spacer(),
        Text(AppLocalizations.of(context).t(hint), textAlign: TextAlign.center, style: TextStyle(color: cs.onSurface.withOpacity(0.6), fontSize: 16, fontStyle: FontStyle.italic)),
        const SizedBox(height: 32),
        // Answer slots
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(wordLen, (i) {
            final hasLetter = i < _answer.length;
            return GestureDetector(
              onTap: hasLetter ? () => _removeLetter(i) : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: 44, height: 52,
                decoration: BoxDecoration(
                  color: _solved
                      ? const Color(0xFF10B981).withOpacity(0.2)
                      : (hasLetter ? const Color(0xFF6366F1).withOpacity(0.2) : cs.onSurface.withOpacity(0.05)),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _solved
                        ? const Color(0xFF10B981)
                        : (hasLetter ? const Color(0xFF6366F1) : cs.onSurface.withOpacity(0.15)),
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    hasLetter ? _answer[i] : '',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: _solved ? const Color(0xFF10B981) : cs.onSurface),
                  ),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 40),
        // Scrambled letters
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: List.generate(_scrambled.length, (i) {
            if (_scrambled[i].isEmpty) return const SizedBox(width: 48);
            return GestureDetector(
              onTap: () => _tapLetter(i),
              child: Container(
                width: 48, height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFF59E0B).withOpacity(0.4), width: 1.5),
                ),
                child: Center(
                  child: Text(_scrambled[i], style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: cs.onSurface)),
                ),
              ),
            );
          }),
        ),
        const Spacer(),
        if (_solved)
          Text(AppLocalizations.of(context).t('correct_sparkle'), style: const TextStyle(color: Color(0xFF10B981), fontSize: 20, fontWeight: FontWeight.bold)),
      ],
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
            const Text('🏆', style: TextStyle(fontSize: 56)),
            const SizedBox(height: 16),
            Text(AppLocalizations.of(context).t('all_words_solved'), style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: cs.onSurface)),
            const SizedBox(height: 8),
            Text(AppLocalizations.of(context).t('score', {'val': '$_score'}), style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFFF59E0B))),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => setState(_startGame),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF59E0B), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
              child: Text(AppLocalizations.of(context).t('play_again'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
