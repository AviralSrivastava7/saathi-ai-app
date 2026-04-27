import 'package:flutter/material.dart';
import '../../core/widgets/zen_aura_background.dart';
import '../../core/widgets/glass_card.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';
import '../../core/localization/app_localizations.dart';
import '../../core/localization/translations.dart';
import '../../core/config/app_language.dart';
import '../../core/storage/mood_storage.dart';
import '../../core/storage/stats_storage.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});
  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  int _totalEntries = 0;
  int _weeklyStreak = 0;
  int _monthlyGoal = 0;
  int _meditationMinutes = 0;
  Map<String, int> _moodDistribution = {};
  Map<String, double> _weeklyData = {};
  bool _isLoading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final allMoods = await MoodStorage.getAllMoods();
      final monthMoods = await MoodStorage.getMonthMoods();
      final distribution = await MoodStorage.getMoodDistribution();
      final prefs = await SharedPreferences.getInstance();
      final weeklyActivity = await WeeklyActivityStorage.loadWeeklyData();

      // Use the actual mood/journal consecutive streak
      final moodStreak = await MoodStorage.getMoodStreak();

      setState(() {
        _totalEntries = allMoods.length;
        _weeklyStreak = moodStreak;
        _monthlyGoal = MoodStorage.countUniqueDays(monthMoods);
        _moodDistribution = distribution;
        _meditationMinutes = prefs.getInt('saathi_meditation_minutes') ?? 0;
        _weeklyData = weeklyActivity;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final loc = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(loc.t('analytics'), style: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.w900, fontSize: 28, letterSpacing: -1)),
        leading: IconButton(icon: Icon(Icons.arrow_back_ios_new_rounded, color: colorScheme.onSurface), onPressed: () => Navigator.pop(context)),
        actions: [IconButton(icon: Icon(Icons.refresh_rounded, color: colorScheme.onSurface), onPressed: _load)],
      ),
      body: ZenAuraBackground(
        child: _isLoading
          ? Center(child: CircularProgressIndicator(color: colorScheme.primary))
          : RefreshIndicator(
              onRefresh: _load,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.only(left: 20, right: 20, top: 100, bottom: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Stat Cards Row
                    Row(
                      children: [
                        Expanded(child: _statCard(colorScheme, '📊', '$_totalEntries', loc.t('check_ins'), const Color(0xFF6366F1))),
                        const SizedBox(width: 12),
                        Expanded(child: _statCard(colorScheme, '🔥', '$_weeklyStreak', loc.t('streak'), const Color(0xFFF59E0B))),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: _statCard(colorScheme, '🎯', '$_monthlyGoal/30', loc.t('month_goal'), const Color(0xFF10B981))),
                        const SizedBox(width: 12),
                        Expanded(child: _statCard(colorScheme, '🧘', '${_meditationMinutes}m', loc.t('focus_time'), const Color(0xFF8B5CF6))),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Mood Distribution Pie Chart
                    _sectionTitle(colorScheme, loc.t('mood_distribution')),
                    const SizedBox(height: 16),
                    _moodDistribution.isEmpty
                        ? _emptyState(colorScheme, loc.t('no_mood_data'))
                        : Container(
                            padding: const EdgeInsets.all(24),
                            decoration: _cardDecoration(colorScheme),
                            child: Column(
                              children: [
                                SizedBox(
                                  height: 200,
                                  child: CustomPaint(
                                    size: const Size(200, 200),
                                    painter: _PieChartPainter(_moodDistribution, colorScheme, loc.t('total')),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Wrap(
                                  spacing: 16,
                                  runSpacing: 8,
                                  children: _moodDistribution.entries.map((e) {
                                    final color = _getMoodColor(e.key);
                                    final localizedMood = Translations.localizeMood(e.key, AppLanguage.instance.current);
                                    return Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
                                        const SizedBox(width: 6),
                                        Text('$localizedMood (${e.value})', style: TextStyle(fontSize: 13, color: colorScheme.onSurface.withOpacity(0.7))),
                                      ],
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                          ),
                    const SizedBox(height: 32),

                    // Weekly Activity Bar Chart
                    _sectionTitle(colorScheme, loc.t('weekly_activity')),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: _cardDecoration(colorScheme),
                      child: SizedBox(
                        height: 180,
                        child: CustomPaint(
                          size: const Size(double.infinity, 180),
                          painter: _BarChartPainter(_weeklyData, colorScheme),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Mood Breakdown List
                    _sectionTitle(colorScheme, loc.t('mood_breakdown')),
                    const SizedBox(height: 16),
                    ..._moodDistribution.entries.map((e) {
                      final total = _moodDistribution.values.fold(0, (a, b) => a + b);
                      final pct = total > 0 ? (e.value / total * 100) : 0.0;
                      final color = _getMoodColor(e.key);
                      final localizedMood = Translations.localizeMood(e.key, AppLanguage.instance.current);
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(16),
                        decoration: _cardDecoration(colorScheme),
                        child: Row(
                          children: [
                            Container(
                              width: 44, height: 44,
                              decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
                              child: Center(child: Text(_getMoodEmoji(e.key), style: const TextStyle(fontSize: 22))),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(localizedMood, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: colorScheme.onSurface)),
                                  const SizedBox(height: 6),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: LinearProgressIndicator(
                                      value: pct / 100,
                                      backgroundColor: colorScheme.onSurface.withOpacity(0.06),
                                      color: color,
                                      minHeight: 6,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text('${pct.toInt()}%', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: color)),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
    ),
  );
}

  Widget _statCard(ColorScheme cs, String emoji, String value, String label, Color color) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      borderRadius: 24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
            child: Text(emoji, style: const TextStyle(fontSize: 20)),
          ),
          const SizedBox(height: 14),
          Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: cs.onSurface)),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(fontSize: 12, color: cs.onSurface.withOpacity(0.5))),
        ],
      ),
    );
  }

  Widget _sectionTitle(ColorScheme cs, String title) {
    return Text(title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: cs.onSurface, letterSpacing: -0.5));
  }

  Widget _emptyState(ColorScheme cs, String msg) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: _cardDecoration(cs),
      child: Center(child: Text(msg, style: TextStyle(color: cs.onSurface.withOpacity(0.4), fontSize: 14))),
    );
  }

  BoxDecoration _cardDecoration(ColorScheme cs) {
    return BoxDecoration(
      color: cs.surface.withOpacity(0.3),
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: cs.onSurface.withOpacity(0.06)),
    );
  }

  Color _getMoodColor(String mood) {
    final l = mood.toLowerCase();
    if (l.contains('happy')) return const Color(0xFF10B981);
    if (l.contains('calm')) return const Color(0xFF6366F1);
    if (l.contains('sad')) return const Color(0xFF3B82F6);
    if (l.contains('anxious')) return const Color(0xFFF59E0B);
    if (l.contains('angry')) return const Color(0xFFEF4444);
    if (l.contains('neutral')) return const Color(0xFF8B5CF6);
    return const Color(0xFF6B7280);
  }

  String _getMoodEmoji(String mood) {
    final l = mood.toLowerCase();
    if (l.contains('happy')) return '😊';
    if (l.contains('calm')) return '😌';
    if (l.contains('sad')) return '😔';
    if (l.contains('anxious')) return '😰';
    if (l.contains('angry')) return '😠';
    if (l.contains('neutral')) return '😐';
    return '🙂';
  }
}

// Custom Pie Chart Painter
class _PieChartPainter extends CustomPainter {
  final Map<String, int> data;
  final ColorScheme colorScheme;
  final String totalLabel;
  _PieChartPainter(this.data, this.colorScheme, this.totalLabel);

  Color _getColor(String mood) {
    final l = mood.toLowerCase();
    if (l.contains('happy')) return const Color(0xFF10B981);
    if (l.contains('calm')) return const Color(0xFF6366F1);
    if (l.contains('sad')) return const Color(0xFF3B82F6);
    if (l.contains('anxious')) return const Color(0xFFF59E0B);
    if (l.contains('angry')) return const Color(0xFFEF4444);
    if (l.contains('neutral')) return const Color(0xFF8B5CF6);
    return const Color(0xFF6B7280);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final total = data.values.fold(0, (a, b) => a + b);
    if (total == 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2 - 8;
    double startAngle = -pi / 2;

    for (final entry in data.entries) {
      final sweep = (entry.value / total) * 2 * pi;
      final paint = Paint()
        ..color = _getColor(entry.key)
        ..style = PaintingStyle.fill;
      canvas.drawArc(Rect.fromCircle(center: center, radius: radius), startAngle, sweep, true, paint);

      // White border between segments
      final borderPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawArc(Rect.fromCircle(center: center, radius: radius), startAngle, sweep, true, borderPaint);
      startAngle += sweep;
    }

    // Center hole (donut)
    final holePaint = Paint()..color = colorScheme.surface;
    canvas.drawCircle(center, radius * 0.55, holePaint);

    // Center text
    final textPainter = TextPainter(
      text: TextSpan(text: '$total', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(canvas, Offset(center.dx - textPainter.width / 2, center.dy - textPainter.height / 2 - 8));

    final labelPainter = TextPainter(
      text: TextSpan(text: totalLabel, style: TextStyle(fontSize: 12, color: colorScheme.onSurface.withOpacity(0.5))),
      textDirection: TextDirection.ltr,
    )..layout();
    labelPainter.paint(canvas, Offset(center.dx - labelPainter.width / 2, center.dy + 8));
  }

  @override
  bool shouldRepaint(covariant _PieChartPainter oldDelegate) =>
      oldDelegate.data.length != data.length ||
      oldDelegate.totalLabel != totalLabel ||
      !_mapsEqual(oldDelegate.data, data);

  bool _mapsEqual(Map<String, int> a, Map<String, int> b) {
    if (a.length != b.length) return false;
    for (final key in a.keys) {
      if (a[key] != b[key]) return false;
    }
    return true;
  }
}

// Custom Bar Chart Painter
class _BarChartPainter extends CustomPainter {
  final Map<String, double> data;
  final ColorScheme colorScheme;
  _BarChartPainter(this.data, this.colorScheme);

  @override
  void paint(Canvas canvas, Size size) {
    // English defaults fallback
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    // In actual implementation we just use first letter 'M', 'T' etc. which works for English.
    // If we wanted full localization for days here we'd pass it in, but we just draw `days[i][0]`.
    final maxVal = data.values.isEmpty ? 1.0 : data.values.reduce(max).clamp(1.0, double.infinity);
    final barWidth = (size.width - 60) / 7;
    final chartHeight = size.height - 30;

    // Grid lines
    for (int i = 0; i <= 4; i++) {
      final y = chartHeight - (chartHeight * i / 4);
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        Paint()..color = colorScheme.onSurface.withOpacity(0.05)..strokeWidth = 1,
      );
    }

    for (int i = 0; i < days.length; i++) {
      final val = data[days[i]] ?? 0;
      final barHeight = (val / maxVal) * (chartHeight - 20);
      final x = 30.0 + i * barWidth + barWidth * 0.2;
      final w = barWidth * 0.6;

      // Bar
      final barRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, chartHeight - barHeight, w, barHeight),
        const Radius.circular(6),
      );
      final gradient = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [colorScheme.primary, colorScheme.primary.withOpacity(0.4)],
      );
      final paint = Paint()..shader = gradient.createShader(Rect.fromLTWH(x, chartHeight - barHeight, w, barHeight));
      canvas.drawRRect(barRect, paint);

      // Day label
      final tp = TextPainter(
        text: TextSpan(text: days[i][0], style: TextStyle(fontSize: 12, color: colorScheme.onSurface.withOpacity(0.4))),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(x + w / 2 - tp.width / 2, chartHeight + 8));
    }
  }

  @override
  bool shouldRepaint(covariant _BarChartPainter oldDelegate) =>
      oldDelegate.data.length != data.length ||
      !_mapsEqual(oldDelegate.data, data);

  bool _mapsEqual(Map<String, double> a, Map<String, double> b) {
    if (a.length != b.length) return false;
    for (final key in a.keys) {
      if (a[key] != b[key]) return false;
    }
    return true;
  }
}
