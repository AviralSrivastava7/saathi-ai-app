import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:math';
import '../../core/localization/app_localizations.dart';
import '../../core/widgets/zen_aura_background.dart';

/// Developer/Student Burnout Toolkit - "Focus & Recover" Mode
/// Pomodoro with a Twist: Deep breathing exercises & offline puzzles during breaks.
class FocusRecoverScreen extends StatefulWidget {
  const FocusRecoverScreen({super.key});

  @override
  State<FocusRecoverScreen> createState() => _FocusRecoverScreenState();
}

class _FocusRecoverScreenState extends State<FocusRecoverScreen>
    with TickerProviderStateMixin {
  int _focusMinutes = 25;
  int _breakMinutes = 5;
  int _secondsLeft = 25 * 60;
  bool _isRunning = false;
  bool _isFocusPhase = true;
  int _sessionsCompleted = 0;
  Timer? _timer;
  _BreakActivity? _currentBreakActivity;

  late AnimationController _breathController;
  late Animation<double> _breathAnimation;

  int? _puzzleAnswer;
  final TextEditingController _puzzleInputController = TextEditingController();
  String? _puzzleQuestion;
  bool _puzzleSolved = false;

  int _selectedPresetIndex = 1; // Default: Classic Pomodoro

  final List<Map<String, String>> _focusPresets = [
    {'name': 'preset_quick', 'focus': '15', 'break': '3', 'emoji': '⚡'},
    {'name': 'preset_classic', 'focus': '25', 'break': '5', 'emoji': '🍅'},
    {'name': 'preset_deep', 'focus': '45', 'break': '10', 'emoji': '🧠'},
    {'name': 'preset_dsa', 'focus': '50', 'break': '10', 'emoji': '💻'},
    {'name': 'preset_study', 'focus': '30', 'break': '7', 'emoji': '📚'},
  ];

  @override
  void initState() {
    super.initState();
    _breathController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    _breathAnimation = Tween<double>(begin: 0.7, end: 1.3).animate(
      CurvedAnimation(parent: _breathController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _breathController.dispose();
    _puzzleInputController.dispose();
    super.dispose();
  }

  void _selectPreset(int index) {
    if (_isRunning) return;
    HapticFeedback.selectionClick();
    final preset = _focusPresets[index];
    setState(() {
      _selectedPresetIndex = index;
      _focusMinutes = int.parse(preset['focus']!);
      _breakMinutes = int.parse(preset['break']!);
      _secondsLeft = _focusMinutes * 60;
      _isFocusPhase = true;
    });
  }

  void _startTimer() {
    HapticFeedback.mediumImpact();
    setState(() => _isRunning = true);
    if (_isFocusPhase) _breathController.stop();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) { timer.cancel(); return; }
      setState(() {
        _secondsLeft--;
        if (_secondsLeft <= 0) {
          timer.cancel();
          _isRunning = false;
          HapticFeedback.heavyImpact();
          if (_isFocusPhase) {
            _sessionsCompleted++;
            _isFocusPhase = false;
            _secondsLeft = _breakMinutes * 60;
            _pickBreakActivity();
          } else {
            _isFocusPhase = true;
            _secondsLeft = _focusMinutes * 60;
            _currentBreakActivity = null;
            _puzzleSolved = false;
          }
        }
      });
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() => _isRunning = false);
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _isFocusPhase = true;
      _secondsLeft = _focusMinutes * 60;
      _currentBreakActivity = null;
      _puzzleSolved = false;
    });
    _breathController.stop();
  }

  void _pickBreakActivity() {
    final activities = [_BreakActivity.breathing, _BreakActivity.puzzle, _BreakActivity.stretch];
    final picked = activities[Random().nextInt(activities.length)];
    setState(() { _currentBreakActivity = picked; _puzzleSolved = false; });
    if (picked == _BreakActivity.breathing) {
      _breathController.repeat(reverse: true);
    } else if (picked == _BreakActivity.puzzle) {
      _generatePuzzle();
    }
  }

  void _generatePuzzle() {
    final random = Random();
    final a = random.nextInt(50) + 10;
    final b = random.nextInt(30) + 5;
    final ops = ['+', '-', '×'];
    final op = ops[random.nextInt(ops.length)];
    int answer;
    switch (op) {
      case '+': answer = a + b; break;
      case '-': answer = a - b; break;
      case '×': answer = a * b; break;
      default: answer = a + b;
    }
    setState(() { _puzzleQuestion = '$a $op $b = ?'; _puzzleAnswer = answer; _puzzleSolved = false; });
    _puzzleInputController.clear();
  }

  void _checkPuzzle() {
    final userAnswer = int.tryParse(_puzzleInputController.text.trim());
    if (userAnswer == _puzzleAnswer) {
      HapticFeedback.mediumImpact();
      setState(() => _puzzleSolved = true);
    }
  }

  String _formatTime(int totalSeconds) {
    final mins = totalSeconds ~/ 60;
    final secs = totalSeconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  double _getProgress() {
    final total = _isFocusPhase ? _focusMinutes * 60 : _breakMinutes * 60;
    return 1.0 - (_secondsLeft / total);
  }

  Color get _accentColor => _isFocusPhase ? const Color(0xFF6366F1) : const Color(0xFF43E97B);
  List<Color> get _accentGradient => _isFocusPhase
      ? [const Color(0xFF6366F1), const Color(0xFF8B5CF6)]
      : [const Color(0xFF43E97B), const Color(0xFF38F9D7)];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final loc = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: colorScheme.onSurface),
          onPressed: () { _timer?.cancel(); Navigator.pop(context); },
        ),
        title: Text(loc.t('focus_recover'), style: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.w900, fontSize: 22, letterSpacing: -0.5)),
        actions: [
          if (_sessionsCompleted > 0)
            Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFF97316).withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🔥', style: TextStyle(fontSize: 14)),
                  const SizedBox(width: 4),
                  Text('$_sessionsCompleted', style: const TextStyle(color: Color(0xFFF97316), fontWeight: FontWeight.bold, fontSize: 14)),
                ],
              ),
            ),
        ],
      ),
      body: ZenAuraBackground(
        child: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
          child: Column(
            children: [
              // ─── Phase indicator ───
              AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: _accentGradient),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: _accentColor.withOpacity(0.25), blurRadius: 12, offset: const Offset(0, 4))],
                ),
                child: Text(
                  _isFocusPhase ? '🎯  ${loc.t('focus_mode')}' : '🧘  ${loc.t('break_time')}',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13, letterSpacing: 1.5),
                ),
              ),
              const SizedBox(height: 28),

              // ─── Timer Ring ───
              SizedBox(
                width: 240,
                height: 240,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 240,
                      height: 240,
                      child: TweenAnimationBuilder<double>(
                        tween: Tween<double>(begin: 0, end: _getProgress()),
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeOut,
                        builder: (context, value, _) => CircularProgressIndicator(
                          value: value,
                          strokeWidth: 10,
                          backgroundColor: colorScheme.onSurface.withOpacity(0.06),
                          valueColor: AlwaysStoppedAnimation<Color>(_accentColor),
                          strokeCap: StrokeCap.round,
                        ),
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _formatTime(_secondsLeft),
                          style: TextStyle(
                            color: colorScheme.onSurface,
                            fontSize: 52,
                            fontWeight: FontWeight.w200,
                            letterSpacing: 3,
                            fontFamily: 'monospace',
                          ),
                        ),
                        const SizedBox(height: 6),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: Text(
                            _isFocusPhase ? loc.t('stay_focused') : loc.t('relax_recharge'),
                            key: ValueKey(_isFocusPhase),
                            style: TextStyle(color: _accentColor.withOpacity(0.7), fontSize: 13, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // ─── Controls ───
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _controlBtn(Icons.refresh_rounded, colorScheme.onSurface.withOpacity(0.25), _resetTimer),
                  const SizedBox(width: 24),
                  GestureDetector(
                    onTap: _isRunning ? _pauseTimer : _startTimer,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 68,
                      height: 68,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(colors: _accentGradient),
                        boxShadow: [BoxShadow(color: _accentColor.withOpacity(0.35), blurRadius: 20, offset: const Offset(0, 8))],
                      ),
                      child: Icon(_isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded, color: Colors.white, size: 34),
                    ),
                  ),
                  const SizedBox(width: 24),
                  _controlBtn(Icons.skip_next_rounded, colorScheme.onSurface.withOpacity(0.25), () {
                    _timer?.cancel();
                    setState(() {
                      _isRunning = false;
                      if (_isFocusPhase) {
                        _sessionsCompleted++;
                        _isFocusPhase = false;
                        _secondsLeft = _breakMinutes * 60;
                        _pickBreakActivity();
                      } else {
                        _isFocusPhase = true;
                        _secondsLeft = _focusMinutes * 60;
                        _currentBreakActivity = null;
                      }
                    });
                  }),
                ],
              ),
              const SizedBox(height: 28),

              // ─── Presets (chip-style, no overflow) ───
              if (!_isRunning && _isFocusPhase) ...[
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(loc.t('quick_presets'), style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: colorScheme.onSurface)),
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: List.generate(_focusPresets.length, (i) {
                    final preset = _focusPresets[i];
                    final isSelected = i == _selectedPresetIndex;
                    return GestureDetector(
                      onTap: () => _selectPreset(i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected ? _accentColor.withOpacity(0.12) : (isDark ? Colors.white.withOpacity(0.05) : colorScheme.surface),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected ? _accentColor.withOpacity(0.5) : colorScheme.onSurface.withOpacity(0.06),
                            width: isSelected ? 1.5 : 1,
                          ),
                          boxShadow: isSelected ? [BoxShadow(color: _accentColor.withOpacity(0.08), blurRadius: 8, offset: const Offset(0, 2))] : null,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(preset['emoji']!, style: const TextStyle(fontSize: 16)),
                            const SizedBox(width: 6),
                            Text(
                              loc.t(preset['name']!),
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                color: isSelected ? _accentColor : colorScheme.onSurface.withOpacity(0.6),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${preset['focus']}m',
                              style: TextStyle(fontSize: 11, color: colorScheme.onSurface.withOpacity(0.3), fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 8),
              ],

              // ─── Break Activity ───
              if (!_isFocusPhase && _currentBreakActivity != null) ...[
                const SizedBox(height: 8),
                _buildBreakActivity(colorScheme),
              ],
            ],
          ),
        ),
      ),
    ),
  );
}

  Widget _controlBtn(IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color.withOpacity(0.12)),
        child: Icon(icon, color: color, size: 22),
      ),
    );
  }

  Widget _buildBreakActivity(ColorScheme colorScheme) {
    final loc = AppLocalizations.of(context);
    switch (_currentBreakActivity!) {
      case _BreakActivity.breathing: return _buildBreathingBreak(colorScheme, loc);
      case _BreakActivity.puzzle: return _buildPuzzleBreak(colorScheme, loc);
      case _BreakActivity.stretch: return _buildStretchBreak(colorScheme, loc);
    }
  }

  Widget _buildBreathingBreak(ColorScheme colorScheme, AppLocalizations loc) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [const Color(0xFF43E97B).withOpacity(0.08), const Color(0xFF38F9D7).withOpacity(0.03)]),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF43E97B).withOpacity(0.12)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.self_improvement_rounded, color: Color(0xFF43E97B), size: 20),
              const SizedBox(width: 8),
              Text(loc.t('deep_breathing'), style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: colorScheme.onSurface)),
            ],
          ),
          const SizedBox(height: 6),
          Text(loc.t('breath_instruction'),
              textAlign: TextAlign.center,
              style: TextStyle(color: colorScheme.onSurface.withOpacity(0.4), fontSize: 12)),
          const SizedBox(height: 20),
          AnimatedBuilder(
            animation: _breathAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _breathAnimation.value,
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(colors: [Color(0xFF43E97B), Color(0xFF38F9D7)]),
                    boxShadow: [BoxShadow(color: const Color(0xFF43E97B).withOpacity(0.25), blurRadius: 25, spreadRadius: 3)],
                  ),
                  child: Center(
                    child: Text(
                      _breathAnimation.value > 1.0 ? loc.t('breath_in') : loc.t('breath_out'),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPuzzleBreak(ColorScheme colorScheme, AppLocalizations loc) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [const Color(0xFF4FACFE).withOpacity(0.08), const Color(0xFF00F2FE).withOpacity(0.03)]),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF4FACFE).withOpacity(0.12)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.extension_rounded, color: Color(0xFF4FACFE), size: 20),
              const SizedBox(width: 8),
              Text(loc.t('quick_puzzle'), style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: colorScheme.onSurface)),
            ],
          ),
          const SizedBox(height: 6),
          Text(loc.t('puzzle_sub'),
              textAlign: TextAlign.center,
              style: TextStyle(color: colorScheme.onSurface.withOpacity(0.4), fontSize: 12)),
          const SizedBox(height: 20),
          if (_puzzleQuestion != null && !_puzzleSolved) ...[
            Text(_puzzleQuestion!, style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: colorScheme.onSurface)),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _puzzleInputController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20, color: colorScheme.onSurface, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      hintText: loc.t('answer_hint'),
                      hintStyle: TextStyle(color: colorScheme.onSurface.withOpacity(0.25)),
                      filled: true,
                      fillColor: colorScheme.onSurface.withOpacity(0.04),
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _checkPuzzle,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4FACFE),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: Text(loc.t('check_btn'), style: const TextStyle(fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          ],
          if (_puzzleSolved) ...[
            const Icon(Icons.check_circle_rounded, color: Color(0xFF43E97B), size: 48),
            const SizedBox(height: 8),
            Text(loc.t('correct_msg'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF43E97B))),
            const SizedBox(height: 10),
            TextButton(onPressed: _generatePuzzle, child: Text(loc.t('next_puzzle'))),
          ],
        ],
      ),
    );
  }

  Widget _buildStretchBreak(ColorScheme colorScheme, AppLocalizations loc) {
    final stretches = [
      {'emoji': '🙆', 'title': loc.t('str_neck_t'), 'desc': loc.t('str_neck_d')},
      {'emoji': '💪', 'title': loc.t('str_shrug_t'), 'desc': loc.t('str_shrug_d')},
      {'emoji': '🤲', 'title': loc.t('str_wrist_t'), 'desc': loc.t('str_wrist_d')},
      {'emoji': '👀', 'title': loc.t('str_eye_t'), 'desc': loc.t('str_eye_d')},
      {'emoji': '🧍', 'title': loc.t('str_stand_t'), 'desc': loc.t('str_stand_d')},
    ];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [const Color(0xFFF97316).withOpacity(0.08), const Color(0xFFFFD700).withOpacity(0.03)]),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF97316).withOpacity(0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.accessibility_new_rounded, color: Color(0xFFF97316), size: 20),
                const SizedBox(width: 8),
                Text(loc.t('quick_stretches'), style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: colorScheme.onSurface)),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Center(
            child: Text(loc.t('stretches_sub'), style: TextStyle(color: colorScheme.onSurface.withOpacity(0.4), fontSize: 12)),
          ),
          const SizedBox(height: 16),
          ...stretches.map((s) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(s['emoji']!, style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(s['title']!, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: colorScheme.onSurface)),
                      Text(s['desc']!, style: TextStyle(fontSize: 11, color: colorScheme.onSurface.withOpacity(0.45), height: 1.3)),
                    ],
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
}

enum _BreakActivity { breathing, puzzle, stretch }
