import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/widgets/zen_aura_background.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/smooth_page_route.dart';
import '../../core/localization/app_localizations.dart';
import 'pet_service.dart';

class BuddyGamesScreen extends StatelessWidget {
  final PetService petService;
  const BuddyGamesScreen({super.key, required this.petService});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final loc = AppLocalizations.of(context);
    final games = [
      _BuddyGame(loc.t('tic_tac_toe'), '❌⭕', const Color(0xFF6366F1), loc.t('tic_tac_toe_desc'), (ctx) => _TicTacToeScreen(petService: petService)),
      _BuddyGame(loc.t('rock_paper_scissors'), '✊✋✌️', const Color(0xFFEC4899), loc.t('rps_desc'), (ctx) => _RPSScreen(petService: petService)),
      _BuddyGame(loc.t('number_guess'), '🔢', const Color(0xFFF59E0B), loc.t('number_guess_desc'), (ctx) => _NumberGuessScreen(petService: petService)),
      _BuddyGame(loc.t('emoji_quiz'), '🤔', const Color(0xFF10B981), loc.t('emoji_quiz_desc'), (ctx) => _EmojiQuizScreen(petService: petService)),
      _BuddyGame(loc.t('word_guess'), '📝', const Color(0xFF8B5CF6), loc.t('word_guess_desc'), (ctx) => _WordGuessScreen(petService: petService)),
    ];

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent, elevation: 0,
        leading: IconButton(icon: Icon(Icons.arrow_back_ios_rounded, color: cs.onSurface), onPressed: () => Navigator.pop(context)),
        title: Text('${loc.t('play_with_buddy')} 🎮', style: TextStyle(color: cs.onSurface, fontWeight: FontWeight.bold)),
      ),
      body: ZenAuraBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Buddy speech
              GlassCard(
                padding: const EdgeInsets.all(20),
                borderRadius: 24,
                child: Row(
                  children: [
                    const Text('🦊', style: TextStyle(fontSize: 36)),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        loc.t('buddy_nudge_play'),
                        style: TextStyle(color: cs.onSurface, fontSize: 15, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              ...games.map((g) => _gameCard(context, g, cs)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _gameCard(BuildContext context, _BuddyGame game, ColorScheme cs) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: GlassCard(
        padding: EdgeInsets.zero,
        borderRadius: 22,
        child: InkWell(
          onTap: () => Navigator.push(context, smoothPageRoute(page: game.builder(context))),
          borderRadius: BorderRadius.circular(22),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Container(
                  width: 52, height: 52,
                  decoration: BoxDecoration(color: game.color.withOpacity(0.12), borderRadius: BorderRadius.circular(16)),
                  child: Center(child: Text(game.emoji, style: const TextStyle(fontSize: 22))),
                ),
                const SizedBox(width: 16),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(game.name, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: cs.onSurface)),
                  const SizedBox(height: 4),
                  Text(game.desc, style: TextStyle(color: cs.onSurface.withOpacity(0.5), fontSize: 13)),
                ])),
                Icon(Icons.play_arrow_rounded, color: game.color, size: 28),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BuddyGame {
  final String name, emoji, desc;
  final Color color;
  final Widget Function(BuildContext) builder;
  _BuddyGame(this.name, this.emoji, this.color, this.desc, this.builder);
}

// ══════════════════════════════════════════════════════════
// 1. TIC TAC TOE
// ══════════════════════════════════════════════════════════

class _TicTacToeScreen extends StatefulWidget {
  final PetService petService;
  const _TicTacToeScreen({required this.petService});
  @override State<_TicTacToeScreen> createState() => _TicTacToeState();
}

class _TicTacToeState extends State<_TicTacToeScreen> {
  List<String> _board = List.filled(9, '');
  bool _playerTurn = true;
  String _result = '';
  final _rng = Random();

  void _reset() => setState(() { _board = List.filled(9, ''); _playerTurn = true; _result = ''; });

  void _tap(int i) {
    if (_board[i].isNotEmpty || _result.isNotEmpty || !_playerTurn) return;
    setState(() { _board[i] = 'X'; _playerTurn = false; });
    _checkWin();
    if (_result.isEmpty && !_playerTurn) {
      Future.delayed(const Duration(milliseconds: 400), () { if (mounted) _buddyMove(); });
    }
  }

  void _buddyMove() {
    // Try to win
    final winMove = _findWinningMove('O');
    if (winMove != -1) { setState(() { _board[winMove] = 'O'; _playerTurn = true; }); _checkWin(); return; }
    // Try to block
    final blockMove = _findWinningMove('X');
    if (blockMove != -1) { setState(() { _board[blockMove] = 'O'; _playerTurn = true; }); _checkWin(); return; }
    // Take center
    if (_board[4].isEmpty) { setState(() { _board[4] = 'O'; _playerTurn = true; }); _checkWin(); return; }
    // Random
    final empty = <int>[];
    for (int j = 0; j < 9; j++) { if (_board[j].isEmpty) empty.add(j); }
    if (empty.isNotEmpty) {
      setState(() { _board[empty[_rng.nextInt(empty.length)]] = 'O'; _playerTurn = true; });
      _checkWin();
    }
  }

  int _findWinningMove(String mark) {
    const lines = [[0,1,2],[3,4,5],[6,7,8],[0,3,6],[1,4,7],[2,5,8],[0,4,8],[2,4,6]];
    for (final line in lines) {
      final vals = [_board[line[0]], _board[line[1]], _board[line[2]]];
      if (vals.where((v) => v == mark).length == 2 && vals.contains('')) {
        return line[vals.indexOf('')];
      }
    }
    return -1;
  }

  void _checkWin() {
    const lines = [[0,1,2],[3,4,5],[6,7,8],[0,3,6],[1,4,7],[2,5,8],[0,4,8],[2,4,6]];
    for (final line in lines) {
      if (_board[line[0]].isNotEmpty && _board[line[0]] == _board[line[1]] && _board[line[1]] == _board[line[2]]) {
        setState(() { _result = _board[line[0]] == 'X' ? 'game_you_win' : 'game_buddy_wins'; });
        if (_board[line[0]] == 'X') widget.petService.buddyGameBoost();
        return;
      }
    }
    if (!_board.contains('')) {
      setState(() => _result = 'game_draw');
      widget.petService.buddyGameBoost();
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final loc = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0,
        leading: IconButton(icon: Icon(Icons.arrow_back_ios_rounded, color: cs.onSurface), onPressed: () => Navigator.pop(context)),
        title: Text(loc.t('tic_tac_toe'), style: TextStyle(color: cs.onSurface, fontWeight: FontWeight.bold))),
      body: ZenAuraBackground(child: SafeArea(child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(children: [
          GlassCard(padding: const EdgeInsets.all(16), borderRadius: 16,
            child: Row(children: [
              const Text('🦊', style: TextStyle(fontSize: 28)),
              const SizedBox(width: 12),
              Expanded(child: Text(
                _result.isNotEmpty ? (_result == 'game_you_win' ? loc.t('ttt_you_beat_buddy') : loc.t('ttt_better_luck'))
                    : (_playerTurn ? loc.t('ttt_your_turn') : loc.t('ttt_buddy_thinking')),
                style: TextStyle(color: cs.onSurface, fontSize: 14),
              )),
            ])),
          const Spacer(),
          AspectRatio(aspectRatio: 1, child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 10, mainAxisSpacing: 10),
            itemCount: 9,
            itemBuilder: (ctx, i) => GestureDetector(
              onTap: () => _tap(i),
              child: Container(
                decoration: BoxDecoration(
                  color: _board[i] == 'X' ? const Color(0xFF6366F1).withOpacity(0.15) : (_board[i] == 'O' ? const Color(0xFFEC4899).withOpacity(0.15) : cs.onSurface.withOpacity(0.05)),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: cs.onSurface.withOpacity(0.1), width: 1.5),
                ),
                child: Center(child: Text(_board[i] == 'X' ? '❌' : (_board[i] == 'O' ? '⭕' : ''), style: const TextStyle(fontSize: 36))),
              ),
            ),
          )),
          const Spacer(),
          if (_result.isNotEmpty) ElevatedButton(onPressed: _reset,
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6366F1), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
            child: Text(loc.t('play_again'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
        ]),
      ))),
    );
  }
}

// ══════════════════════════════════════════════════════════
// 2. ROCK PAPER SCISSORS
// ══════════════════════════════════════════════════════════

class _RPSScreen extends StatefulWidget {
  final PetService petService;
  const _RPSScreen({required this.petService});
  @override State<_RPSScreen> createState() => _RPSState();
}

class _RPSState extends State<_RPSScreen> {
  final _rng = Random();
  final List<String> _choices = ['✊', '✋', '✌️'];
  String _playerChoice = '', _buddyChoice = '', _roundResult = '';
  int _playerScore = 0, _buddyScore = 0, _round = 0;
  bool _gameOver = false;

  void _play(String choice) {
    if (_gameOver) return;
    final buddy = _choices[_rng.nextInt(3)];
    String result;
    if (choice == buddy) { result = 'game_draw'; }
    else if ((choice == '✊' && buddy == '✌️') || (choice == '✋' && buddy == '✊') || (choice == '✌️' && buddy == '✋')) {
      result = 'game_you_win'; _playerScore++;
    } else {
      result = 'game_buddy_wins'; _buddyScore++;
    }
    _round++;
    setState(() { _playerChoice = choice; _buddyChoice = buddy; _roundResult = result; });
    if (_round >= 5) {
      setState(() => _gameOver = true);
      if (_playerScore >= _buddyScore) widget.petService.buddyGameBoost();
    }
  }

  void _reset() => setState(() { _playerChoice = ''; _buddyChoice = ''; _roundResult = ''; _playerScore = 0; _buddyScore = 0; _round = 0; _gameOver = false; });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final loc = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0,
        leading: IconButton(icon: Icon(Icons.arrow_back_ios_rounded, color: cs.onSurface), onPressed: () => Navigator.pop(context)),
        title: Text(loc.t('rock_paper_scissors'), style: TextStyle(color: cs.onSurface, fontWeight: FontWeight.bold))),
      body: ZenAuraBackground(child: SafeArea(child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(children: [
          GlassCard(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12), borderRadius: 16,
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('${loc.t('rps_you_label')}: $_playerScore', style: TextStyle(color: cs.onSurface, fontWeight: FontWeight.bold, fontSize: 16)),
              Text(loc.t('rps_round', _round.toString()), style: TextStyle(color: cs.onSurface.withOpacity(0.5))),
              Text('${loc.t('rps_buddy_label')}: $_buddyScore', style: const TextStyle(color: Color(0xFFEC4899), fontWeight: FontWeight.bold, fontSize: 16)),
            ])),
          const Spacer(),
          if (_playerChoice.isNotEmpty) ...[
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
              Column(children: [Text(loc.t('rps_you_label'), style: TextStyle(color: cs.onSurface.withOpacity(0.5))), const SizedBox(height: 8), Text(_playerChoice, style: const TextStyle(fontSize: 56))]),
              Text(loc.t('rps_vs'), style: TextStyle(color: cs.onSurface.withOpacity(0.3), fontSize: 20, fontWeight: FontWeight.bold)),
              Column(children: [Text(loc.t('rps_buddy_label'), style: TextStyle(color: cs.onSurface.withOpacity(0.5))), const SizedBox(height: 8), Text(_buddyChoice, style: const TextStyle(fontSize: 56))]),
            ]),
            const SizedBox(height: 20),
            Text(loc.t(_roundResult), style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: cs.onSurface)),
          ],
          const Spacer(),
          if (_gameOver)
            Column(children: [
              Text(_playerScore > _buddyScore ? loc.t('rps_you_won_series') : (_playerScore == _buddyScore ? loc.t('rps_series_tied') : loc.t('rps_buddy_won_series')),
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: cs.onSurface)),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: _reset,
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEC4899), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                child: Text(loc.t('play_again'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
            ])
          else
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: _choices.map((c) =>
              GestureDetector(
                onTap: () => _play(c),
                child: Container(
                  width: 80, height: 80,
                  decoration: BoxDecoration(color: const Color(0xFFEC4899).withOpacity(0.1), borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFEC4899).withOpacity(0.3))),
                  child: Center(child: Text(c, style: const TextStyle(fontSize: 36))),
                ),
              ),
            ).toList()),
          const SizedBox(height: 20),
        ]),
      ))),
    );
  }
}

// ══════════════════════════════════════════════════════════
// 3. NUMBER GUESS
// ══════════════════════════════════════════════════════════

class _NumberGuessScreen extends StatefulWidget {
  final PetService petService;
  const _NumberGuessScreen({required this.petService});
  @override State<_NumberGuessScreen> createState() => _NumberGuessState();
}

class _NumberGuessState extends State<_NumberGuessScreen> {
  final _rng = Random();
  late int _secret;
  int _attempts = 0;
  String _hintKey = 'ng_thinking';
  String _buddyReactionKey = '';
  bool _won = false;
  final _controller = TextEditingController();

  @override
  void initState() { super.initState(); _secret = 1 + _rng.nextInt(100); }

  void _guess() {
    final guess = int.tryParse(_controller.text);
    if (guess == null) return;
    _attempts++;
    _controller.clear();
    if (guess == _secret) {
      setState(() { _won = true; _hintKey = 'ng_correct'; _buddyReactionKey = 'ng_got_it'; });
      widget.petService.buddyGameBoost();
    } else if (guess < _secret) {
      final diff = _secret - guess;
      setState(() {
        _hintKey = diff > 30 ? 'ng_way_higher' : (diff > 10 ? 'ng_higher' : 'ng_warm_higher');
        _buddyReactionKey = diff > 30 ? 'ng_react_far' : (diff > 10 ? 'ng_react_mid' : 'ng_react_close');
      });
    } else {
      final diff = guess - _secret;
      setState(() {
        _hintKey = diff > 30 ? 'ng_way_lower' : (diff > 10 ? 'ng_lower' : 'ng_warm_lower');
        _buddyReactionKey = diff > 30 ? 'ng_react_far' : (diff > 10 ? 'ng_react_mid' : 'ng_react_close');
      });
    }
  }

  void _reset() { setState(() { _secret = 1 + _rng.nextInt(100); _attempts = 0; _hintKey = 'ng_thinking'; _buddyReactionKey = ''; _won = false; }); }

  @override
  void dispose() { _controller.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final loc = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: Colors.transparent, extendBodyBehindAppBar: true,
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0,
        leading: IconButton(icon: Icon(Icons.arrow_back_ios_rounded, color: cs.onSurface), onPressed: () => Navigator.pop(context)),
        title: Text(loc.t('number_guess'), style: TextStyle(color: cs.onSurface, fontWeight: FontWeight.bold))),
      body: ZenAuraBackground(child: SafeArea(child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(children: [
          GlassCard(padding: const EdgeInsets.all(20), borderRadius: 20,
            child: Column(children: [
              Row(children: [const Text('🦊', style: TextStyle(fontSize: 32)), const SizedBox(width: 12),
                Expanded(child: Text(_won ? loc.t('ng_correct', _secret.toString()) : loc.t(_hintKey), style: TextStyle(color: cs.onSurface, fontSize: 16, fontWeight: FontWeight.w500)))]),
              if (_buddyReactionKey.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(_won ? loc.t('ng_got_it', _attempts.toString()) : loc.t(_buddyReactionKey), style: TextStyle(color: cs.onSurface.withOpacity(0.6), fontSize: 13, fontStyle: FontStyle.italic)),
              ],
            ])),
          const SizedBox(height: 12),
          Text(loc.t('ng_attempts', _attempts.toString()), style: TextStyle(color: cs.onSurface.withOpacity(0.5))),
          const Spacer(),
          if (!_won)
            Row(children: [
              Expanded(child: TextField(
                controller: _controller,
                keyboardType: TextInputType.number,
                style: TextStyle(color: cs.onSurface, fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  hintText: '?',
                  hintStyle: TextStyle(color: cs.onSurface.withOpacity(0.2)),
                  filled: true, fillColor: cs.onSurface.withOpacity(0.05),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                ),
                onSubmitted: (_) => _guess(),
              )),
              const SizedBox(width: 12),
              ElevatedButton(onPressed: _guess,
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF59E0B), padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                child: Text(loc.t('ng_guess_btn'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16))),
            ])
          else
            ElevatedButton(onPressed: _reset,
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF59E0B), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
              child: Text(loc.t('play_again'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
          const SizedBox(height: 32),
        ]),
      ))),
    );
  }
}

// ══════════════════════════════════════════════════════════
// 4. EMOJI QUIZ
// ══════════════════════════════════════════════════════════

class _EmojiQuizScreen extends StatefulWidget {
  final PetService petService;
  const _EmojiQuizScreen({required this.petService});
  @override State<_EmojiQuizScreen> createState() => _EmojiQuizState();
}

class _EmojiQuizState extends State<_EmojiQuizScreen> {
  static const _quizzes = [
    {'emojis': '😊+🌞', 'answer': 'Happy Day', 'options': ['Happy Day', 'Sad Night', 'Rainy Day', 'Windy Morning']},
    {'emojis': '🧘+🌿', 'answer': 'Meditation', 'options': ['Meditation', 'Running', 'Cooking', 'Sleeping']},
    {'emojis': '💤+🌙', 'answer': 'Good Sleep', 'options': ['Good Sleep', 'Party Time', 'Study Time', 'Workout']},
    {'emojis': '🏃+💪', 'answer': 'Exercise', 'options': ['Exercise', 'Rest', 'Reading', 'Eating']},
    {'emojis': '📖+🧠', 'answer': 'Learning', 'options': ['Learning', 'Dancing', 'Singing', 'Sleeping']},
    {'emojis': '🫂+💕', 'answer': 'Love & Care', 'options': ['Love & Care', 'Anger', 'Loneliness', 'Fear']},
    {'emojis': '🌊+😌', 'answer': 'Inner Peace', 'options': ['Inner Peace', 'Storm', 'Confusion', 'Excitement']},
    {'emojis': '🎵+😊', 'answer': 'Music Joy', 'options': ['Music Joy', 'Silent Pain', 'Loud Noise', 'Deep Thought']},
    {'emojis': '🌱+⏰', 'answer': 'Growth', 'options': ['Growth', 'Decay', 'Stagnation', 'Rush']},
    {'emojis': '🤗+🌟', 'answer': 'Gratitude', 'options': ['Gratitude', 'Jealousy', 'Sadness', 'Boredom']},
  ];

  final _rng = Random();
  int _current = 0, _score = 0;
  String _selected = '', _feedback = '';
  late List<int> _order;

  @override
  void initState() { super.initState(); _order = List.generate(_quizzes.length, (i) => i)..shuffle(_rng); }

  void _select(String option) {
    if (_selected.isNotEmpty) return;
    final correct = _quizzes[_order[_current]]['answer'] as String;
    setState(() {
      _selected = option;
      if (option == correct) { _score++; _feedback = 'eq_correct'; } else { _feedback = correct; }
    });
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      if (_current < _quizzes.length - 1) {
        setState(() { _current++; _selected = ''; _feedback = ''; });
      } else {
        widget.petService.buddyGameBoost();
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final done = _current >= _quizzes.length - 1 && _selected.isNotEmpty;
    final loc = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: Colors.transparent, extendBodyBehindAppBar: true,
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0,
        leading: IconButton(icon: Icon(Icons.arrow_back_ios_rounded, color: cs.onSurface), onPressed: () => Navigator.pop(context)),
        title: Text(loc.t('emoji_quiz'), style: TextStyle(color: cs.onSurface, fontWeight: FontWeight.bold))),
      body: ZenAuraBackground(child: SafeArea(child: Padding(
        padding: const EdgeInsets.all(24),
        child: done ? _buildDone(cs) : _buildQuiz(cs),
      ))),
    );
  }

  Widget _buildQuiz(ColorScheme cs) {
    final loc = AppLocalizations.of(context);
    final q = _quizzes[_order[_current]];
    final options = List<String>.from(q['options'] as List)..shuffle(_rng);
    return Column(children: [
      GlassCard(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12), borderRadius: 16,
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(loc.t('score_label', _score.toString()), style: TextStyle(color: cs.onSurface, fontWeight: FontWeight.bold)),
          Text('${_current + 1}/${_quizzes.length}', style: TextStyle(color: cs.onSurface.withOpacity(0.5))),
        ])),
      const Spacer(),
      Text(loc.t('eq_what_mean'), style: TextStyle(color: cs.onSurface.withOpacity(0.5), fontSize: 14)),
      const SizedBox(height: 16),
      Text(q['emojis'] as String, style: const TextStyle(fontSize: 56)),
      const SizedBox(height: 32),
      ...options.map((o) {
        final isCorrect = o == q['answer'];
        final isSelected = _selected == o;
        Color bg = cs.onSurface.withOpacity(0.05);
        if (_selected.isNotEmpty) {
          if (isCorrect) bg = const Color(0xFF10B981).withOpacity(0.2);
          else if (isSelected) bg = Colors.red.withOpacity(0.2);
        }
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: GestureDetector(
            onTap: () => _select(o),
            child: Container(width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(16), border: Border.all(color: cs.onSurface.withOpacity(0.1))),
              child: Text(o, textAlign: TextAlign.center, style: TextStyle(color: cs.onSurface, fontSize: 16, fontWeight: FontWeight.w500))),
          ),
        );
      }),
      if (_feedback.isNotEmpty)
        Padding(padding: const EdgeInsets.only(top: 12), child: Text(
          _feedback == 'eq_correct' ? loc.t('eq_correct') : loc.t('eq_wrong', _feedback),
          style: TextStyle(color: cs.onSurface, fontSize: 16, fontWeight: FontWeight.bold))),
      const Spacer(),
    ]);
  }

  Widget _buildDone(ColorScheme cs) {
    final loc = AppLocalizations.of(context);
    return Center(child: GlassCard(padding: const EdgeInsets.all(32), borderRadius: 28,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Text('🏆', style: TextStyle(fontSize: 56)),
        const SizedBox(height: 16),
        Text(loc.t('eq_complete'), style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: cs.onSurface)),
        const SizedBox(height: 8),
        Text('${loc.t('score_label', _score.toString())}/${_quizzes.length}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF10B981))),
        const SizedBox(height: 24),
        ElevatedButton(onPressed: () { setState(() { _current = 0; _score = 0; _selected = ''; _feedback = ''; _order.shuffle(_rng); }); },
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
          child: Text(loc.t('play_again'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
      ])));
  }
}

// ══════════════════════════════════════════════════════════
// 5. WORD GUESS (Hangman-style)
// ══════════════════════════════════════════════════════════

class _WordGuessScreen extends StatefulWidget {
  final PetService petService;
  const _WordGuessScreen({required this.petService});
  @override State<_WordGuessScreen> createState() => _WordGuessState();
}

class _WordGuessState extends State<_WordGuessScreen> {
  static const _words = ['PEACE', 'HAPPY', 'BRAVE', 'RELAX', 'SMILE', 'GRACE', 'BLISS', 'TRUST', 'DREAM', 'SHINE'];
  final _rng = Random();
  late String _word;
  final Set<String> _guessed = {};
  int _wrongCount = 0;
  static const int _maxWrong = 6;

  @override
  void initState() { super.initState(); _word = _words[_rng.nextInt(_words.length)]; }

  bool get _won => _word.split('').every((l) => _guessed.contains(l));
  bool get _lost => _wrongCount >= _maxWrong;

  void _guessLetter(String letter) {
    if (_guessed.contains(letter) || _won || _lost) return;
    setState(() {
      _guessed.add(letter);
      if (!_word.contains(letter)) _wrongCount++;
    });
    if (_won) widget.petService.buddyGameBoost();
  }

  void _reset() { setState(() { _word = _words[_rng.nextInt(_words.length)]; _guessed.clear(); _wrongCount = 0; }); }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final loc = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: Colors.transparent, extendBodyBehindAppBar: true,
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0,
        leading: IconButton(icon: Icon(Icons.arrow_back_ios_rounded, color: cs.onSurface), onPressed: () => Navigator.pop(context)),
        title: Text(loc.t('word_guess'), style: TextStyle(color: cs.onSurface, fontWeight: FontWeight.bold))),
      body: ZenAuraBackground(child: SafeArea(child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(children: [
          GlassCard(padding: const EdgeInsets.all(16), borderRadius: 16,
            child: Row(children: [
              const Text('🦊', style: TextStyle(fontSize: 28)),
              const SizedBox(width: 12),
              Expanded(child: Text(
                _won ? loc.t('wg_got_it') : (_lost ? loc.t('wg_word_was', _word) : loc.t('wg_guess_hint')),
                style: TextStyle(color: cs.onSurface, fontSize: 14),
              )),
            ])),
          const SizedBox(height: 8),
          // Lives
          Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(_maxWrong, (i) =>
            Padding(padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Icon(Icons.favorite, size: 20, color: i < (_maxWrong - _wrongCount) ? Colors.pinkAccent : Colors.grey.withOpacity(0.3))))),
          const Spacer(),
          // Word display
          Row(mainAxisAlignment: MainAxisAlignment.center, children: _word.split('').map((l) =>
            Container(
              width: 44, height: 52, margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: _guessed.contains(l) ? const Color(0xFF8B5CF6).withOpacity(0.2) : cs.onSurface.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: cs.onSurface.withOpacity(0.15), width: 2),
              ),
              child: Center(child: Text(_guessed.contains(l) || _lost ? l : '', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: cs.onSurface))),
            ),
          ).toList()),
          const SizedBox(height: 32),
          // Keyboard
          if (!_won && !_lost)
            Wrap(spacing: 6, runSpacing: 6, alignment: WrapAlignment.center,
              children: 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'.split('').map((l) {
                final used = _guessed.contains(l);
                final inWord = _word.contains(l);
                return GestureDetector(
                  onTap: () => _guessLetter(l),
                  child: Container(
                    width: 36, height: 40,
                    decoration: BoxDecoration(
                      color: used ? (inWord ? const Color(0xFF10B981).withOpacity(0.2) : Colors.red.withOpacity(0.15)) : cs.onSurface.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: cs.onSurface.withOpacity(used ? 0.05 : 0.1)),
                    ),
                    child: Center(child: Text(l, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: used ? cs.onSurface.withOpacity(0.3) : cs.onSurface))),
                  ),
                );
              }).toList()),
          if (_won || _lost)
            ElevatedButton(onPressed: _reset,
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF8B5CF6), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
              child: Text(loc.t('play_again'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
          const Spacer(),
        ]),
      ))),
    );
  }
}
