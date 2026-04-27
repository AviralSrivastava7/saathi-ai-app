import 'package:flutter/material.dart';
import 'dart:async';
import '../../core/storage/stats_storage.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/widgets/zen_aura_background.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/smooth_page_route.dart';

class MeditationScreen extends StatelessWidget {
  const MeditationScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final loc = AppLocalizations.of(context);

    final sessions = [
      {'titleKey': 'morning_calm', 'descKey': 'morning_calm_desc', 'minutes': 5, 'color': Colors.orange},
      {'titleKey': 'deep_focus', 'descKey': 'deep_focus_desc', 'minutes': 10, 'color': Colors.blue},
      {'titleKey': 'stress_relief', 'descKey': 'stress_relief_desc', 'minutes': 15, 'color': Colors.purple},
      {'titleKey': 'evening_winddown', 'descKey': 'evening_winddown_desc', 'minutes': 20, 'color': Colors.indigo},
    ];
    
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(loc.t('meditation'), style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded), onPressed: () => Navigator.pop(context)),
      ),
      body: ZenAuraBackground(
        child: ListView.builder(
          padding: const EdgeInsets.only(left: 20, right: 20, top: 100, bottom: 24),
          itemCount: sessions.length,
          itemBuilder: (context, i) {
            final s = sessions[i];
            final accentColor = s['color'] as Color;
            final mins = s['minutes'] as int;
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: GlassCard(
                padding: EdgeInsets.zero,
                borderRadius: 24,
                child: InkWell(
                  onTap: () => Navigator.push(context, smoothPageRoute(
                    page: MeditationPlayerScreen(
                      title: loc.t(s['titleKey'] as String), 
                      description: loc.t(s['descKey'] as String), 
                      totalMinutes: mins, 
                      accentColor: accentColor
                    ),
                  )),
                  borderRadius: BorderRadius.circular(24),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(children: [
                      Container(width: 56, height: 56, decoration: BoxDecoration(color: accentColor.withOpacity(0.12), borderRadius: BorderRadius.circular(16)), child: Center(child: Icon(Icons.self_improvement, color: accentColor, size: 28))),
                      const SizedBox(width: 16),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(loc.t(s['titleKey'] as String), style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
                        const SizedBox(height: 4),
                        Text(loc.t(s['descKey'] as String), style: TextStyle(fontSize: 12, color: colorScheme.onSurface.withOpacity(0.5))),
                      ])),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), 
                        decoration: BoxDecoration(color: accentColor.withOpacity(0.1), borderRadius: BorderRadius.circular(10)), 
                        child: Text(
                          loc.t('min_duration', {'val': mins.toString()}), 
                          style: TextStyle(color: accentColor, fontWeight: FontWeight.bold, fontSize: 12)
                        )
                      ),
                    ]),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class MeditationPlayerScreen extends StatefulWidget {
  final String title, description;
  final int totalMinutes;
  final Color accentColor;
  const MeditationPlayerScreen({super.key, required this.title, required this.description, required this.totalMinutes, required this.accentColor});
  @override State<MeditationPlayerScreen> createState() => _MeditationPlayerScreenState();
}
class _MeditationPlayerScreenState extends State<MeditationPlayerScreen> with SingleTickerProviderStateMixin {
  bool _playing = false;
  int _remaining = 0;
  int _elapsedSeconds = 0;
  Timer? _timer;
  late AnimationController _ctrl;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _remaining = widget.totalMinutes * 60;
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.9, end: 1.1).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override void dispose() { _timer?.cancel(); _ctrl.dispose(); _saveElapsedMinutes(); super.dispose(); }

  Future<void> _saveElapsedMinutes() async {
    final mins = _elapsedSeconds ~/ 60;
    if (mins > 0) { await StatsStorage.saveMeditationMinutes(mins); await WeeklyActivityStorage.incrementTodayActivity(mins.toDouble()); }
  }

  void _toggle() {
    final loc = AppLocalizations.of(context);
    setState(() { _playing = !_playing; });
    if (_playing) {
      _timer = Timer.periodic(const Duration(seconds: 1), (t) {
        if (mounted) {
          setState(() {
            _remaining--; _elapsedSeconds++;
            if (_remaining <= 0) {
              _playing = false; t.cancel();
              StatsStorage.saveMeditationMinutes(widget.totalMinutes);
              WeeklyActivityStorage.incrementTodayActivity(widget.totalMinutes.toDouble());
              _elapsedSeconds = 0;
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(loc.t('session_complete_msg'))));
            }
          });
        }
      });
    } else { _timer?.cancel(); }
  }

  String _fmt(int s) => '${(s ~/ 60).toString().padLeft(2, '0')}:${(s % 60).toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final loc = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0, leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded), onPressed: () => Navigator.pop(context))),
      body: ZenAuraBackground(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedBuilder(
                  animation: _pulse,
                  builder: (context, child) => Transform.scale(
                    scale: _playing ? _pulse.value : 1.0,
                    child: Container(
                      width: 200, height: 200,
                      decoration: BoxDecoration(shape: BoxShape.circle, color: widget.accentColor.withOpacity(0.05), border: Border.all(color: widget.accentColor.withOpacity(0.3), width: 3), boxShadow: [BoxShadow(color: widget.accentColor.withOpacity(0.15), blurRadius: 40, spreadRadius: 10)]),
                      child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.self_improvement, size: 60, color: widget.accentColor), const SizedBox(height: 8), Text(_fmt(_remaining), style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: widget.accentColor))])),
                    ),
                  ),
                ),
                const SizedBox(height: 60),
                Text(widget.title, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: colorScheme.onSurface), textAlign: TextAlign.center),
                const SizedBox(height: 12),
                Text(widget.description, style: TextStyle(fontSize: 15, color: colorScheme.onSurface.withOpacity(0.6)), textAlign: TextAlign.center),
                const SizedBox(height: 80),
                ElevatedButton(
                  onPressed: _toggle,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _playing ? Colors.red.withOpacity(0.8) : widget.accentColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 56, vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                    elevation: 0,
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(_playing ? Icons.pause_rounded : Icons.play_arrow_rounded, size: 28), const SizedBox(width: 8), Text(_playing ? loc.t('pause') : loc.t('start_session'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))]),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
