// lib/features/games/focus_dots_game.dart
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:async';
import '../../core/theme/app_colors.dart';
import '../../core/theme/theme_manager.dart';
import '../../core/localization/app_localizations.dart';

class FocusDotsGame extends StatefulWidget {
  const FocusDotsGame({super.key});

  @override
  State<FocusDotsGame> createState() => _FocusDotsGameState();
}

class _FocusDotsGameState extends State<FocusDotsGame> {
  final int _totalDots = 10;
  int _nextExpected = 1;
  late List<DotPosition> _dots;
  late Stopwatch _stopwatch;
  late Timer _timer;
  String _timeDisplay = "0.00";
  bool _isGameOver = false;

  @override
  void initState() {
    super.initState();
    _startNewGame();
  }

  void _startNewGame() {
    _nextExpected = 1;
    _isGameOver = false;
    _stopwatch = Stopwatch()..start();
    _dots = _generateNonOverlappingDots();
    _timer = Timer.periodic(const Duration(milliseconds: 10), (timer) {
      if (mounted) {
        setState(() {
          _timeDisplay = (_stopwatch.elapsedMilliseconds / 1000).toStringAsFixed(2);
        });
      }
    });
  }

  List<DotPosition> _generateNonOverlappingDots() {
    final rand = math.Random();
    final List<DotPosition> newDots = [];
    const double dotRadius = 35; // Size of dot + some padding

    for (int i = 1; i <= _totalDots; i++) {
      double x, y;
      bool overlaps;
      int attempts = 0;

      do {
        overlaps = false;
        x = 0.1 + rand.nextDouble() * 0.8;
        y = 0.1 + rand.nextDouble() * 0.8;
        attempts++;

        for (var dot in newDots) {
          final dist = math.sqrt(math.pow(x - dot.x, 2) + math.pow(y - dot.y, 2));
          // Distance in normalized units (roughly 0.15 is safe for 60px dots on typical screens)
          if (dist < 0.15) {
            overlaps = true;
            break;
          }
        }
      } while (overlaps && attempts < 100);

      newDots.add(DotPosition(
        value: i,
        x: x,
        y: y,
        color: [
          AppColors.accentBlue,
          AppColors.primaryPurple,
          AppColors.accentTeal,
          AppColors.accentOrange,
          AppColors.accentPink,
        ][rand.nextInt(5)],
      ));
    }
    return newDots;
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _onDotTap(int value) {
    if (_isGameOver) return;

    if (value == _nextExpected) {
      setState(() {
        _nextExpected++;
      });

      if (_nextExpected > _totalDots) {
        _stopwatch.stop();
        _timer.cancel();
        setState(() => _isGameOver = true);
        _showWinDialog();
      }
    } else {
      Feedback.forTap(context);
    }
  }

  void _showWinDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundMid,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(AppLocalizations.of(context).t('focus_achieved'), style: const TextStyle(color: Colors.white)),
        content: Text(AppLocalizations.of(context).t('focus_summary', {'val': _timeDisplay}),
            style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => _startNewGame());
            },
            child: Text(AppLocalizations.of(context).t('try_again'), style: const TextStyle(color: AppColors.accentPink, fontWeight: FontWeight.bold)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text(AppLocalizations.of(context).t('back_to_games'), style: const TextStyle(color: Colors.white60)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeManager().isDarkMode;
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: isDark ? AppColors.background : Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(AppLocalizations.of(context).t('game_focus_dots'), style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded, color: isDark ? Colors.white : Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark 
            ? AppColors.backgroundGradient 
            : LinearGradient(
                colors: [Colors.pink.shade50, Colors.white],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
        ),
        child: Column(
          children: [
            const SafeArea(bottom: false, child: SizedBox(height: 10)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStatCard(AppLocalizations.of(context).t('next_number'), '$_nextExpected', AppColors.accentPink, isDark),
                  _buildStatCard(AppLocalizations.of(context).t('time_label', {'val': ''}).replaceAll(':', ''), _timeDisplay, AppColors.accentBlue, isDark),
                ],
              ),
            ),
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withOpacity(0.05) : Colors.white.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(color: isDark ? Colors.white12 : Colors.black12),
                  boxShadow: [
                    if (isDark) BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 20)
                  ],
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Stack(
                      children: _dots.map((dot) => _buildDot(dot, constraints)).toList(),
                    );
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Text(
                AppLocalizations.of(context).t('focus_dots_instr'),
                style: TextStyle(color: isDark ? Colors.white38 : Colors.black38, fontStyle: FontStyle.italic),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? Colors.white12 : Colors.black12),
      ),
      child: Column(
        children: [
          Text(label, style: TextStyle(color: isDark ? Colors.white54 : Colors.black54, fontSize: 12)),
          Text(value, style: TextStyle(color: color, fontSize: 24, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildDot(DotPosition dot, BoxConstraints constraints) {
    final isTapped = dot.value < _nextExpected;
    final isTarget = dot.value == _nextExpected;

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutBack,
      left: dot.x * (constraints.maxWidth - 70),
      top: dot.y * (constraints.maxHeight - 70),
      child: GestureDetector(
        onTap: () => _onDotTap(dot.value),
        child: AnimatedScale(
          scale: isTapped ? 0 : (isTarget ? 1.1 : 1.0),
          duration: const Duration(milliseconds: 300),
          child: AnimatedOpacity(
            opacity: isTapped ? 0 : 1,
            duration: const Duration(milliseconds: 300),
            child: Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [dot.color, dot.color.withOpacity(0.7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: dot.color.withOpacity(0.4),
                    blurRadius: isTarget ? 20 : 10,
                    spreadRadius: isTarget ? 4 : 2,
                  )
                ],
                border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
              ),
              child: Center(
                child: Text(
                  '${dot.value}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class DotPosition {
  final int value;
  final double x;
  final double y;
  final Color color;

  DotPosition({
    required this.value,
    required this.x,
    required this.y,
    required this.color,
  });
}
