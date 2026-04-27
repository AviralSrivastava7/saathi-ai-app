import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/widgets/zen_aura_background.dart';

class WindDownScreen extends StatefulWidget {
  const WindDownScreen({super.key});

  @override
  State<WindDownScreen> createState() => _WindDownScreenState();
}

class _WindDownScreenState extends State<WindDownScreen>
    with SingleTickerProviderStateMixin {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  int _selectedSoundIndex = 0;
  double _volume = 0.7;
  int _timerMinutes = 30;
  int _secondsLeft = 0;
  Timer? _timer;
  bool _timerRunning = false;

  int _sleepStreak = 0;
  double _avgHours = 0;
  String? _lastSleepTime;

  final double _originalBrightness = 1.0;
  bool _dimmed = false;

  late AnimationController _floatController;

  final List<_SoundOption> _sounds = [
    _SoundOption('sounds_rain', '🌧️', 'nature_sounds.mp3', [const Color(0xFF4FACFE), const Color(0xFF00F2FE)]),
    _SoundOption('sounds_piano', '🎹', 'calm_piano.mp3', [const Color(0xFFA78BFA), const Color(0xFF7C3AED)]),
    _SoundOption('sounds_lofi', '🎵', 'default_chill.mp3', [const Color(0xFFF97316), const Color(0xFFFFD700)]),
    _SoundOption('sounds_nature', '🌿', 'nature_sounds.mp3', [const Color(0xFF43E97B), const Color(0xFF38F9D7)]),
    _SoundOption('sounds_meditation', '🧘', 'meditation_track.mp3', [const Color(0xFFEC4899), const Color(0xFF8B5CF6)]),
  ];

  final List<int> _timerOptions = [15, 30, 45, 60, 90, 120];

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat(reverse: true);
    _loadSleepStats();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _audioPlayer.dispose();
    _floatController.dispose();
    super.dispose();
  }

  Future<void> _loadSleepStats() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _sleepStreak = prefs.getInt('sleep_streak') ?? 0;
      _avgHours = prefs.getDouble('avg_sleep_hours') ?? 0;
      _lastSleepTime = prefs.getString('last_sleep_time');
    });
  }

  Future<void> _recordSleep() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final todayStr = '${now.year}-${now.month}-${now.day}';
    if (_lastSleepTime == todayStr) return;
    final newStreak = _sleepStreak + 1;
    await prefs.setInt('sleep_streak', newStreak);
    await prefs.setString('last_sleep_time', todayStr);
    final hours = _timerMinutes / 60.0;
    final newAvg = _avgHours == 0 ? hours : (_avgHours * 0.8 + hours * 0.2);
    await prefs.setDouble('avg_sleep_hours', newAvg);
    setState(() { _sleepStreak = newStreak; _avgHours = newAvg; _lastSleepTime = todayStr; });
  }

  Future<void> _togglePlay() async {
    HapticFeedback.lightImpact();
    if (_isPlaying) {
      await _audioPlayer.pause();
      setState(() => _isPlaying = false);
    } else {
      final sound = _sounds[_selectedSoundIndex];
      await _audioPlayer.setSource(AssetSource('audio/${sound.filename}'));
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      await _audioPlayer.setVolume(_volume);
      await _audioPlayer.resume();
      setState(() => _isPlaying = true);
      _dimScreen();
      _recordSleep();
    }
  }

  Future<void> _selectSound(int index) async {
    HapticFeedback.selectionClick();
    setState(() => _selectedSoundIndex = index);
    if (_isPlaying) {
      final sound = _sounds[index];
      await _audioPlayer.setSource(AssetSource('audio/${sound.filename}'));
      await _audioPlayer.resume();
    }
  }

  void _startSleepTimer() {
    _timer?.cancel();
    setState(() { _secondsLeft = _timerMinutes * 60; _timerRunning = true; });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) { timer.cancel(); return; }
      setState(() => _secondsLeft--);
      if (_secondsLeft <= 0) {
        timer.cancel();
        _audioPlayer.pause();
        setState(() { _isPlaying = false; _timerRunning = false; });
      }
    });
  }

  void _dimScreen() {
    setState(() => _dimmed = true);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(statusBarBrightness: Brightness.dark, statusBarIconBrightness: Brightness.light));
  }

  String _formatTimer(int totalSeconds) {
    final h = totalSeconds ~/ 3600;
    final m = (totalSeconds % 3600) ~/ 60;
    final s = totalSeconds % 60;
    if (h > 0) return '${h}h ${m}m';
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final loc = AppLocalizations.of(context);
    final selectedSound = _sounds[_selectedSoundIndex];

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: _dimmed ? Colors.white38 : colorScheme.onSurface),
          onPressed: () { _timer?.cancel(); _audioPlayer.stop(); Navigator.pop(context); },
        ),
        title: Text(loc.t('wind_down'), style: TextStyle(color: _dimmed ? Colors.white38 : colorScheme.onSurface, fontWeight: FontWeight.w900, fontSize: 24, letterSpacing: -0.5)),
        actions: [ if (_dimmed) IconButton(icon: Icon(Icons.brightness_7_rounded, color: Colors.white.withOpacity(0.3)), onPressed: () => setState(() => _dimmed = false)) ],
      ),
      body: ZenAuraBackground(
        child: AnimatedContainer(
          duration: const Duration(seconds: 1),
          color: _dimmed ? Colors.black.withOpacity(0.8) : Colors.transparent,
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: AnimatedOpacity(
                opacity: _dimmed ? 0.6 : 1.0,
                duration: const Duration(seconds: 2),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_sleepStreak > 0) ...[
                      Container(
                        width: double.infinity, padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [const Color(0xFF6366F1).withOpacity(0.15), const Color(0xFF8B5CF6).withOpacity(0.05)]),
                          borderRadius: BorderRadius.circular(22), border: Border.all(color: const Color(0xFF6366F1).withOpacity(0.15)),
                        ),
                        child: Row(children: [
                          Container(padding: const EdgeInsets.all(12), decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)]), shape: BoxShape.circle), child: const Icon(Icons.bedtime_rounded, color: Colors.white, size: 24)),
                          const SizedBox(width: 16),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(loc.t('sleep_streak_msg', {'val': _sleepStreak.toString()}), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: _dimmed ? Colors.white70 : colorScheme.onSurface)),
                            if (_sleepStreak >= 3) Text(loc.t('clarity_score_msg', {'val': (_sleepStreak * 3).toString()}), style: const TextStyle(color: Color(0xFF43E97B), fontSize: 13, fontWeight: FontWeight.w600)),
                          ])),
                        ]),
                      ),
                      const SizedBox(height: 24),
                    ],
                    Text(loc.t('white_noise'), style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: _dimmed ? Colors.white54 : colorScheme.onSurface)),
                    const SizedBox(height: 16),
                    SizedBox(height: 130, child: ListView.builder(scrollDirection: Axis.horizontal, itemCount: _sounds.length, itemBuilder: (context, index) {
                      final sound = _sounds[index]; final isSelected = index == _selectedSoundIndex;
                      return GestureDetector(onTap: () => _selectSound(index), child: AnimatedContainer(duration: const Duration(milliseconds: 300), width: 100, margin: const EdgeInsets.only(right: 12), padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(gradient: isSelected ? LinearGradient(colors: sound.gradient.map((c) => c.withOpacity(0.25)).toList()) : null, color: isSelected ? null : (_dimmed ? Colors.white.withOpacity(0.05) : colorScheme.surface), borderRadius: BorderRadius.circular(22), border: Border.all(color: isSelected ? sound.gradient[0].withOpacity(0.4) : Colors.transparent, width: 2), boxShadow: isSelected ? [BoxShadow(color: sound.gradient[0].withOpacity(0.15), blurRadius: 15, offset: const Offset(0, 5))] : null),
                        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [ Text(sound.emoji, style: const TextStyle(fontSize: 30)), const SizedBox(height: 8), Expanded(child: Text(loc.t(sound.nameKey), textAlign: TextAlign.center, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isSelected ? sound.gradient[0] : (_dimmed ? Colors.white38 : colorScheme.onSurface.withOpacity(0.5))))) ]),
                      ));
                    })),
                    const SizedBox(height: 32),
                    Center(child: AnimatedBuilder(animation: _floatController, builder: (context, child) { final offset = (_floatController.value - 0.5) * 8; return Transform.translate(offset: Offset(0, _isPlaying ? offset : 0), child: child); },
                      child: GestureDetector(onTap: _togglePlay, child: Container(width: 120, height: 120, decoration: BoxDecoration(shape: BoxShape.circle, gradient: LinearGradient(colors: selectedSound.gradient), boxShadow: [BoxShadow(color: selectedSound.gradient[0].withOpacity(_isPlaying ? 0.4 : 0.2), blurRadius: _isPlaying ? 40 : 20, spreadRadius: _isPlaying ? 10 : 0)]), child: Icon(_isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded, color: Colors.white, size: 56))),
                    )),
                    const SizedBox(height: 24),
                    Row(children: [
                      Icon(Icons.volume_down_rounded, color: _dimmed ? Colors.white24 : colorScheme.onSurface.withOpacity(0.3), size: 22),
                      Expanded(child: SliderTheme(data: SliderThemeData(activeTrackColor: selectedSound.gradient[0], inactiveTrackColor: colorScheme.onSurface.withOpacity(0.1), thumbColor: selectedSound.gradient[0], overlayColor: selectedSound.gradient[0].withOpacity(0.1), trackHeight: 4), child: Slider(value: _volume, onChanged: (v) { setState(() => _volume = v); _audioPlayer.setVolume(v); }))),
                      Icon(Icons.volume_up_rounded, color: _dimmed ? Colors.white24 : colorScheme.onSurface.withOpacity(0.3), size: 22),
                    ]),
                    const SizedBox(height: 28),
                    Text(loc.t('sleep_timer'), style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: _dimmed ? Colors.white54 : colorScheme.onSurface)),
                    const SizedBox(height: 16),
                    if (_timerRunning) Center(child: Column(children: [
                      Text(_formatTimer(_secondsLeft), style: TextStyle(fontSize: 42, fontWeight: FontWeight.w300, color: _dimmed ? Colors.white38 : colorScheme.onSurface, letterSpacing: 2)),
                      const SizedBox(height: 12),
                      Text(loc.t('timer_auto_stop'), style: TextStyle(color: colorScheme.onSurface.withOpacity(0.4), fontSize: 13)),
                      const SizedBox(height: 16),
                      TextButton.icon(onPressed: () { _timer?.cancel(); setState(() => _timerRunning = false); }, icon: const Icon(Icons.close_rounded, size: 18), label: Text(loc.t('cancel_timer')), style: TextButton.styleFrom(foregroundColor: Colors.red.withOpacity(0.7))),
                    ])) else ...[
                      Wrap(spacing: 10, runSpacing: 10, children: _timerOptions.map((mins) {
                        final isSelected = mins == _timerMinutes;
                        return GestureDetector(onTap: () => setState(() => _timerMinutes = mins), child: AnimatedContainer(duration: const Duration(milliseconds: 200), padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10), decoration: BoxDecoration(color: isSelected ? selectedSound.gradient[0].withOpacity(0.2) : (_dimmed ? Colors.white.withOpacity(0.05) : colorScheme.surface), borderRadius: BorderRadius.circular(14), border: Border.all(color: isSelected ? selectedSound.gradient[0].withOpacity(0.4) : Colors.transparent)), child: Text('${mins}m', style: TextStyle(color: isSelected ? selectedSound.gradient[0] : (_dimmed ? Colors.white38 : colorScheme.onSurface.withOpacity(0.5)), fontWeight: FontWeight.bold, fontSize: 14))));
                      }).toList()),
                      const SizedBox(height: 16),
                      SizedBox(width: double.infinity, child: ElevatedButton.icon(onPressed: () { if (!_isPlaying) _togglePlay(); _startSleepTimer(); }, icon: const Icon(Icons.bedtime_rounded, size: 20), label: Text(loc.t('start_sleep_timer', {'val': _timerMinutes.toString()}), style: const TextStyle(fontWeight: FontWeight.bold)), style: ElevatedButton.styleFrom(backgroundColor: selectedSound.gradient[0], foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))))),
                    ],
                    const SizedBox(height: 32),
                    Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: _dimmed ? Colors.white.withOpacity(0.03) : colorScheme.surface, borderRadius: BorderRadius.circular(20), border: Border.all(color: colorScheme.onSurface.withOpacity(0.05))), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [ const Text('💡', style: TextStyle(fontSize: 18)), const SizedBox(width: 8), Text(loc.t('sleep_tips_title'), style: TextStyle(fontWeight: FontWeight.bold, color: _dimmed ? Colors.white54 : colorScheme.onSurface, fontSize: 15)) ]),
                      const SizedBox(height: 12),
                      _tipRow('📵', loc.t('tip_phone'), _dimmed ? Colors.white24 : colorScheme.onSurface.withOpacity(0.5)),
                      _tipRow('🌡️', loc.t('tip_cool'), _dimmed ? Colors.white24 : colorScheme.onSurface.withOpacity(0.5)),
                      _tipRow('☕', loc.t('tip_caffeine'), _dimmed ? Colors.white24 : colorScheme.onSurface.withOpacity(0.5)),
                      _tipRow('🕐', loc.t('tip_consistency'), _dimmed ? Colors.white24 : colorScheme.onSurface.withOpacity(0.5)),
                      _tipRow('🧘', loc.t('tip_breathing'), _dimmed ? Colors.white24 : colorScheme.onSurface.withOpacity(0.5)),
                    ])),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _tipRow(String emoji, String text, Color color) {
    return Padding(padding: const EdgeInsets.only(top: 8), child: Row(children: [ Text(emoji, style: const TextStyle(fontSize: 16)), const SizedBox(width: 10), Expanded(child: Text(text, style: TextStyle(color: color, fontSize: 13))) ]));
  }
}

class _SoundOption {
  final String nameKey, emoji, filename; final List<Color> gradient;
  _SoundOption(this.nameKey, this.emoji, this.filename, this.gradient);
}
