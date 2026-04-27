import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/storage/stats_storage.dart';
import '../../core/widgets/zen_aura_background.dart';
import '../../core/widgets/glass_card.dart';
import 'services/journal_service.dart';

class MoodGraphScreen extends StatefulWidget {
  const MoodGraphScreen({super.key});

  @override State<MoodGraphScreen> createState() => _MoodGraphScreenState();
}

class _MoodGraphScreenState extends State<MoodGraphScreen> {
  final JournalService _journalService = JournalService();
  List<double> _moodLevels = List.filled(7, 0.0); 
  bool _isLoading = true;
  String _avgMoodText = 'N/A';
  Color _avgMoodColor = Colors.grey;
  String _insightKey = 'journal_insight_default';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  double _getMoodScore(String mood) {
    if (mood.contains('Happy')) return 5.0;
    if (mood.contains('Calm')) return 4.0;
    if (mood.contains('Tired')) return 3.0;
    if (mood.contains('Anxious')) return 2.0;
    if (mood.contains('Sad')) return 1.0;
    if (mood.contains('Angry')) return 1.0;
    return 3.0; // Default average
  }

  Future<void> _loadData() async {
    // Refresh global stats first just in case
    await StatsStorage.loadAllStats();
    
    final entries = await _journalService.getAllEntries();
    final now = DateTime.now();
    
    // Get this week's Monday
    DateTime monday = now.subtract(Duration(days: now.weekday - 1));
    monday = DateTime(monday.year, monday.month, monday.day);
    
    List<double> weeklyMoods = List.filled(7, 0.0);
    int validCount = 0;
    double sumScore = 0;

    for (int i = 0; i < 7; i++) {
      final curDay = monday.add(Duration(days: i));
      final dayEntries = entries.where((e) => 
        e.date.year == curDay.year && 
        e.date.month == curDay.month && 
        e.date.day == curDay.day
      ).toList();
      
      if (dayEntries.isNotEmpty) {
        double dayScore = 0;
        for (var e in dayEntries) {
          dayScore += _getMoodScore(e.mood);
        }
        dayScore /= dayEntries.length;
        weeklyMoods[i] = dayScore;
        sumScore += dayScore;
        validCount++;
      }
    }

    if (validCount > 0) {
      double avg = sumScore / validCount;
      if (avg >= 4) {
        _avgMoodText = 'mood_status_high';
        _avgMoodColor = Colors.orange;
        _insightKey = 'mood_insight_high';
      } else if (avg >= 3) {
        _avgMoodText = 'mood_status_neutral';
        _avgMoodColor = Colors.teal;
        _insightKey = 'mood_insight_neutral';
      } else {
        _avgMoodText = 'mood_status_low';
        _avgMoodColor = Colors.blue;
        _insightKey = 'mood_insight_low';
      }
    }

    if (mounted) {
      setState(() {
        _moodLevels = weeklyMoods;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final loc = AppLocalizations.of(context);

    // Prepare chart spots (ignore 0.0s to jump over missing days smoothly)
    final spots = _moodLevels.asMap().entries
        .where((e) => e.value > 0)
        .map((e) => FlSpot(e.key.toDouble(), e.value))
        .toList();

    return ZenAuraBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(icon: Icon(Icons.arrow_back_ios_new_rounded, color: colorScheme.onSurface), onPressed: () => Navigator.pop(context)),
          title: Text(loc.t('mood_trends'), style: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.w900, fontSize: 24, letterSpacing: -0.5)),
        ),
        body: SafeArea(
          child: _isLoading 
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Main Graph Card
                GlassCard(
                  padding: const EdgeInsets.all(24),
                  borderRadius: 28,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(AppLocalizations.of(context).t('this_week'), style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
                          if (spots.length >= 2) ...[
                             Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), 
                              decoration: BoxDecoration(color: (spots.last.y >= spots.first.y ? Colors.green : Colors.red).withOpacity(0.1), borderRadius: BorderRadius.circular(10)), 
                              child: Text(spots.last.y >= spots.first.y ? AppLocalizations.of(context).t('trending_up') : AppLocalizations.of(context).t('trending_down'), style: TextStyle(color: spots.last.y >= spots.first.y ? Colors.green : Colors.red, fontSize: 12, fontWeight: FontWeight.bold))
                            )
                          ]
                        ],
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        height: 200,
                        child: spots.isEmpty 
                        ? Center(child: Text(AppLocalizations.of(context).t('not_enough_data'), style: TextStyle(color: colorScheme.onSurface.withOpacity(0.5))))
                        : LineChart(
                          LineChartData(
                            gridData: const FlGridData(show: false),
                            titlesData: const FlTitlesData(
                              leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)), // We use custom text below
                            ),
                            borderData: FlBorderData(show: false),
                            minX: 0, maxX: 6, minY: 0, maxY: 6,
                            lineBarsData: [
                              LineChartBarData(
                                spots: spots,
                                isCurved: true,
                                color: colorScheme.primary,
                                barWidth: 4,
                                dotData: const FlDotData(show: true),
                                belowBarData: BarAreaData(show: true, color: colorScheme.primary.withOpacity(0.1)),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Text(AppLocalizations.of(context).t('mon'), style: TextStyle(fontSize: 12, color: colorScheme.onSurface.withOpacity(0.6))),
                        Text(AppLocalizations.of(context).t('tue'), style: TextStyle(fontSize: 12, color: colorScheme.onSurface.withOpacity(0.6))),
                        Text(AppLocalizations.of(context).t('wed'), style: TextStyle(fontSize: 12, color: colorScheme.onSurface.withOpacity(0.6))),
                        Text(AppLocalizations.of(context).t('thu'), style: TextStyle(fontSize: 12, color: colorScheme.onSurface.withOpacity(0.6))),
                        Text(AppLocalizations.of(context).t('fri'), style: TextStyle(fontSize: 12, color: colorScheme.onSurface.withOpacity(0.6))),
                        Text(AppLocalizations.of(context).t('sat'), style: TextStyle(fontSize: 12, color: colorScheme.onSurface.withOpacity(0.6))),
                        Text(AppLocalizations.of(context).t('sun'), style: TextStyle(fontSize: 12, color: colorScheme.onSurface.withOpacity(0.6))),
                      ]),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // Stat Cards Row
                Row(
                  children: [
                    Expanded(child: _buildStatCard(AppLocalizations.of(context).t('avg_mood'), _avgMoodText == 'N/A' ? 'N/A' : AppLocalizations.of(context).t(_avgMoodText), _avgMoodColor)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildStatCard(AppLocalizations.of(context).t('app_streak'), AppLocalizations.of(context).t('days_streak', {'val': AppStats.streakDays.toString()}), Colors.purple)),
                  ],
                ),
                const SizedBox(height: 16),
                _buildInsightCard(loc, AppLocalizations.of(context).t(_insightKey)),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color accent) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      borderRadius: 24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5))),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: accent)),
        ],
      ),
    );
  }

  Widget _buildInsightCard(AppLocalizations loc, String insightText) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      borderRadius: 24,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(14)), child: const Icon(Icons.lightbulb_outline_rounded, color: Colors.blue, size: 24)),
          const SizedBox(width: 16),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(loc.t('buddy_insights'), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Theme.of(context).colorScheme.onSurface)),
            const SizedBox(height: 6),
            Text(insightText, style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6), fontSize: 14, height: 1.5)),
          ])),
        ],
      ),
    );
  }
}
