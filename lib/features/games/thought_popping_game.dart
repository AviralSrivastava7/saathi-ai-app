import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import 'dart:async';
import '../../core/localization/app_localizations.dart';

/// Interactive CBT Quest: "Thought Popping" Game
/// Based on the CBT technique of 'Thought Interruption'.
/// Negative thought bubbles appear on screen and user taps to "pop" them.
class ThoughtPoppingGame extends StatefulWidget {
  const ThoughtPoppingGame({super.key});

  @override
  State<ThoughtPoppingGame> createState() => _ThoughtPoppingGameState();
}

class _ThoughtPoppingGameState extends State<ThoughtPoppingGame>
    with TickerProviderStateMixin {
  final Random _random = Random();
  final List<_ThoughtBubble> _bubbles = [];
  int _poppedCount = 0;
  int _missedCount = 0;
  int _combo = 0;
  int _maxCombo = 0;
  bool _isPlaying = false;
  bool _isGameOver = false;
  Timer? _spawnTimer;
  Timer? _gameTimer;
  int _timeLeft = 60;
  int _level = 1;

  final List<String> _negativeThoughts = [
    'neg_failure',
    'neg_nobody_likes',
    'neg_cant_do_right',
    'neg_worthless',
    'neg_never_succeed',
    'neg_not_smart',
    'neg_people_judging',
    'neg_nothing_better',
    'neg_burden',
    'neg_no_happiness',
    'neg_mess_up',
    'neg_slow',
    'neg_cant_keep_up',
    'neg_everyone_better',
    'neg_study_hard',
    'neg_life_unfair',
  ];

  final List<String> _positiveReplacements = [
    'pos_growing',
    'pos_enough',
    'pos_strong',
    'pos_worthy',
    'pos_believe_self',
    'pos_everything_ok',
    'pos_progress',
    'pos_never_give_up',
  ];

  String? _lastAffirmation;
  double _lastAffirmationOpacity = 0;

  @override
  void dispose() {
    _spawnTimer?.cancel();
    _gameTimer?.cancel();
    for (final b in _bubbles) {
      b.controller.dispose();
    }
    super.dispose();
  }

  void _startGame() {
    setState(() {
      _isPlaying = true;
      _isGameOver = false;
      _poppedCount = 0;
      _missedCount = 0;
      _combo = 0;
      _maxCombo = 0;
      _timeLeft = 60;
      _level = 1;
      _bubbles.clear();
      _lastAffirmation = null;
    });

    _spawnTimer = Timer.periodic(Duration(milliseconds: _getSpawnInterval()), (timer) {
      if (!_isPlaying) {
        timer.cancel();
        return;
      }
      _spawnBubble();

      if (_poppedCount > 0 && _poppedCount % 8 == 0 && _level < 5) {
        setState(() => _level++);
        timer.cancel();
        _spawnTimer = Timer.periodic(Duration(milliseconds: _getSpawnInterval()), (t) {
          if (!_isPlaying) { t.cancel(); return; }
          _spawnBubble();
        });
      }
    });

    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) { timer.cancel(); return; }
      setState(() => _timeLeft--);
      if (_timeLeft <= 0) {
        timer.cancel();
        _endGame();
      }
    });
  }

  int _getSpawnInterval() {
    switch (_level) {
      case 1: return 2000;
      case 2: return 1600;
      case 3: return 1200;
      case 4: return 900;
      case 5: return 700;
      default: return 2000;
    }
  }

  void _spawnBubble() {
    if (!mounted) return;
    final screenWidth = MediaQuery.of(context).size.width;

    final controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 5 - (_level ~/ 2).clamp(0, 2)),
    );

    final bubble = _ThoughtBubble(
      id: DateTime.now().millisecondsSinceEpoch + _random.nextInt(1000),
      text: _negativeThoughts[_random.nextInt(_negativeThoughts.length)],
      x: 30 + _random.nextDouble() * (screenWidth - 200),
      size: 90 + _random.nextDouble() * 40,
      color: _getBubbleColor(),
      controller: controller,
    );

    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (mounted && _isPlaying) {
          setState(() {
            _missedCount++;
            _combo = 0;
            _bubbles.removeWhere((b) => b.id == bubble.id);
          });
          controller.dispose();
          if (_missedCount >= 10) _endGame();
        }
      }
    });

    setState(() => _bubbles.add(bubble));
    controller.forward();
  }

  Color _getBubbleColor() {
    final colors = [
      const Color(0xFFEF4444),
      const Color(0xFFF97316),
      const Color(0xFFEC4899),
      const Color(0xFF8B5CF6),
      const Color(0xFFDC2626),
      const Color(0xFFE11D48),
    ];
    return colors[_random.nextInt(colors.length)];
  }

  void _popBubble(_ThoughtBubble bubble) {
    HapticFeedback.mediumImpact();
    setState(() {
      _bubbles.removeWhere((b) => b.id == bubble.id);
      _poppedCount++;
      _combo++;
      if (_combo > _maxCombo) _maxCombo = _combo;
      _lastAffirmation = _positiveReplacements[_random.nextInt(_positiveReplacements.length)];
      _lastAffirmationOpacity = 1.0;
    });
    bubble.controller.dispose();

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _lastAffirmationOpacity = 0);
    });
  }

  void _endGame() {
    _spawnTimer?.cancel();
    _gameTimer?.cancel();
    for (final b in _bubbles) {
      b.controller.dispose();
    }
    setState(() {
      _isPlaying = false;
      _isGameOver = true;
      _bubbles.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0F0C29), Color(0xFF302B63), Color(0xFF24243E)],
          ),
        ),
        child: SafeArea(
          child: !_isPlaying && !_isGameOver
              ? _buildStartScreen()
              : _isGameOver
                  ? _buildResultScreen()
                  : _buildGameScreen(),
        ),
      ),
    );
  }

  Widget _buildStartScreen() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Align(
            alignment: Alignment.topRight,
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icon(Icons.close_rounded, color: Colors.white.withOpacity(0.6)),
            ),
          ),
          const Spacer(),
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(colors: [Color(0xFFEC4899), Color(0xFF8B5CF6)]),
              boxShadow: [
                BoxShadow(color: const Color(0xFFEC4899).withOpacity(0.3), blurRadius: 40, spreadRadius: 10),
              ],
            ),
            child: const Center(child: Text('💭', style: TextStyle(fontSize: 64))),
          ),
          const SizedBox(height: 40),
          Text(AppLocalizations.of(context).t('thought_popping'),
              style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
          const SizedBox(height: 12),
          Text(AppLocalizations.of(context).t('cbt_quest'),
              style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 2)),
          const SizedBox(height: 24),
          Text(
            AppLocalizations.of(context).t('thought_popping_instr'),
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 15, height: 1.5),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _startGame,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEC4899),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                elevation: 8,
              ),
              child: Text(AppLocalizations.of(context).t('start_popping'), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildGameScreen() {
    return Stack(
      children: [
        ..._bubbles.map((bubble) {
          return AnimatedBuilder(
            key: ValueKey(bubble.id),
            animation: bubble.controller,
            builder: (context, child) {
              final screenHeight = MediaQuery.of(context).size.height;
              final yPos = screenHeight - (bubble.controller.value * (screenHeight + bubble.size));
              return Positioned(
                left: bubble.x,
                top: yPos,
                child: GestureDetector(
                  onTap: () => _popBubble(bubble),
                  child: _BubbleWidget(bubble: bubble, progress: bubble.controller.value),
                ),
              );
            },
          );
        }),
        Positioned(
          top: 8,
          left: 16,
          right: 16,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () { _endGame(); },
                icon: Icon(Icons.close_rounded, color: Colors.white.withOpacity(0.6)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: _timeLeft <= 10 ? Colors.red.withOpacity(0.3) : Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(Icons.timer_rounded, color: _timeLeft <= 10 ? Colors.red : Colors.white, size: 18),
                    const SizedBox(width: 6),
                    Text('${_timeLeft}s', style: TextStyle(color: _timeLeft <= 10 ? Colors.red : Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFFEC4899), Color(0xFF8B5CF6)]),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(AppLocalizations.of(context).t('level_label', {'val': '$_level'}), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
              ),
            ],
          ),
        ),
        Positioned(
          top: 60,
          left: 24,
          right: 24,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _statLabel(AppLocalizations.of(context).t('popped'), '$_poppedCount', Colors.greenAccent),
              _statLabel(AppLocalizations.of(context).t('stat_missed'), '$_missedCount / 10', Colors.orangeAccent),
              _statLabel(AppLocalizations.of(context).t('combo'), 'x$_combo', Colors.yellowAccent),
            ],
          ),
        ),
        if (_lastAffirmation != null)
          Positioned(
            bottom: 100,
            left: 24,
            right: 24,
            child: AnimatedOpacity(
              opacity: _lastAffirmationOpacity,
              duration: const Duration(milliseconds: 500),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [const Color(0xFF43E97B).withOpacity(0.2), const Color(0xFF38F9D7).withOpacity(0.1)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF43E97B).withOpacity(0.3)),
                ),
                child: Text(
                  AppLocalizations.of(context).t(_lastAffirmation!),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Color(0xFF43E97B), fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _statLabel(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.bold)),
        Text(label, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11)),
      ],
    );
  }

  Widget _buildResultScreen() {
    final score = (_poppedCount * 10) + (_maxCombo * 5) - (_missedCount * 3);
    String titleKey;
    String messageKey;
    String emoji;

    if (score >= 200) {
      titleKey = 'thought_master';
      messageKey = 'thought_master_msg';
      emoji = '🏆';
    } else {
      titleKey = 'great_job';
      messageKey = 'great_job_msg';
      emoji = '🌟';
    }

    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          const Spacer(),
          Text(emoji, style: const TextStyle(fontSize: 72)),
          const SizedBox(height: 24),
          Text(AppLocalizations.of(context).t(titleKey), style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800)),
          const SizedBox(height: 16),
          Text(AppLocalizations.of(context).t(messageKey), textAlign: TextAlign.center, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 16, height: 1.5)),
          const SizedBox(height: 40),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.06),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withOpacity(0.08)),
            ),
            child: Column(
              children: [
                _resultRow(AppLocalizations.of(context).t('total_score'), AppLocalizations.of(context).t('score_pts', {'val': '$score'}), const Color(0xFFEC4899)),
                const SizedBox(height: 16),
                _resultRow(AppLocalizations.of(context).t('thoughts_popped'), '$_poppedCount 💥', const Color(0xFF43E97B)),
                const SizedBox(height: 16),
                _resultRow(AppLocalizations.of(context).t('max_combo'), '$_maxCombo 🔥', const Color(0xFFF97316)),
              ],
            ),
          ),
          const Spacer(),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.white.withOpacity(0.2)),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  ),
                  child: Text(AppLocalizations.of(context).t('back_to_games'), style: const TextStyle(fontSize: 16)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _startGame,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEC4899),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  ),
                  child: Text(AppLocalizations.of(context).t('play_again'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _resultRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 15)),
        Text(value, style: TextStyle(color: color, fontSize: 17, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class _ThoughtBubble {
  final int id;
  final String text;
  final double x;
  final double size;
  final Color color;
  final AnimationController controller;
  _ThoughtBubble({required this.id, required this.text, required this.x, required this.size, required this.color, required this.controller});
}

class _BubbleWidget extends StatelessWidget {
  final _ThoughtBubble bubble;
  final double progress;
  const _BubbleWidget({required this.bubble, required this.progress});

  @override
  Widget build(BuildContext context) {
    final wobble = sin(progress * 8 * pi) * 5;
    return Transform.translate(
      offset: Offset(wobble, 0),
      child: Container(
        width: bubble.size,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: RadialGradient(
            colors: [bubble.color.withOpacity(0.7), bubble.color.withOpacity(0.4), bubble.color.withOpacity(0.1)],
            stops: const [0.0, 0.6, 1.0],
          ),
          shape: BoxShape.circle,
          border: Border.all(color: bubble.color.withOpacity(0.5), width: 1.5),
          boxShadow: [BoxShadow(color: bubble.color.withOpacity(0.3), blurRadius: 15, spreadRadius: 2)],
        ),
        child: Center(
          child: Text(
            AppLocalizations.of(context).t(bubble.text),
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}
