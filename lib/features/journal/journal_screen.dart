import 'package:flutter/material.dart';
import '../../core/widgets/zen_aura_background.dart';
import 'models/journal_entry.dart';
import 'services/journal_service.dart';
import 'journal_detail_screen.dart';
import 'quick_journal_screen.dart';
import 'mood_graph_screen.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/smooth_page_route.dart';
import '../../core/localization/app_localizations.dart';

class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  final JournalService _journalService = JournalService();
  List<JournalEntry> _entries = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    setState(() => _isLoading = true);
    final entries = await _journalService.getAllEntries();
    if (mounted) {
      setState(() {
        _entries = entries;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return _buildJournalContent(context, colorScheme, isDark);
  }

  Widget _buildJournalContent(BuildContext context, ColorScheme colorScheme, bool isDark) {

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(AppLocalizations.of(context).t('nav_journal'), style: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.w900, fontSize: 24, letterSpacing: -0.5)),
        actions: [
          IconButton(
            icon: Icon(Icons.add_circle_outline_rounded, color: colorScheme.primary, size: 28),
            onPressed: () async {
              await showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => const QuickJournalScreen(),
              );
              _loadEntries();
            },
          ),
        ],
      ),
      body: ZenAuraBackground(
        child: Column(
          children: [
            const SizedBox(height: 16),

            // AI Mood Insights Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: GestureDetector(
                onTap: () => Navigator.push(context, smoothPageRoute(page: const MoodGraphScreen())),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [const Color(0xFF6366F1).withOpacity(0.12), const Color(0xFF8B5CF6).withOpacity(0.06)],
                    ),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFF6366F1).withOpacity(0.15)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)]),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.auto_graph_rounded, color: Colors.white, size: 18),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(AppLocalizations.of(context).t('ai_mood_insights'), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: colorScheme.onSurface)),
                            Text(AppLocalizations.of(context).t('mood_graph_desc'), style: TextStyle(fontSize: 11, color: colorScheme.onSurface.withOpacity(0.5))),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF43E97B).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(AppLocalizations.of(context).t('on_device_label'), style: const TextStyle(fontSize: 9, color: Color(0xFF43E97B), fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(width: 6),
                          Icon(Icons.arrow_forward_ios_rounded, color: colorScheme.onSurface.withOpacity(0.3), size: 14),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Entries List
            Expanded(
              child: _isLoading
                  ? Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary)))
                  : _entries.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: GlassCard(
                              padding: const EdgeInsets.all(32),
                              borderRadius: 24,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.book_outlined, size: 64, color: colorScheme.onSurface.withOpacity(0.2)),
                                  const SizedBox(height: 16),
                                  Text(AppLocalizations.of(context).t('no_entries_yet'), style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
                                  const SizedBox(height: 8),
                                  Text(AppLocalizations.of(context).t('tap_plus_journal'), style: TextStyle(fontSize: 14, color: colorScheme.onSurface.withOpacity(0.5))),
                                ],
                              ),
                            ),
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _loadEntries,
                          color: colorScheme.primary,
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                            itemCount: _entries.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: _buildJournalCard(_entries[index]),
                              );
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildJournalCard(JournalEntry entry) {
    final colorScheme = Theme.of(context).colorScheme;
    final moodColors = {
      '😊 ${AppLocalizations.of(context).t('mood_happy')}': Colors.orange,
      '😢 ${AppLocalizations.of(context).t('mood_sad')}': Colors.blue,
      '😰 ${AppLocalizations.of(context).t('mood_anxious')}': Colors.purple,
      '😌 ${AppLocalizations.of(context).t('mood_calm')}': Colors.teal,
      '😴 ${AppLocalizations.of(context).t('mood_tired')}': Colors.grey,
      '😠 ${AppLocalizations.of(context).t('mood_angry')}': Colors.red,
    };
    final moodColor = moodColors[entry.mood] ?? colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GlassCard(
        padding: EdgeInsets.zero,
        borderRadius: 24,
        child: InkWell(
          onTap: () async {
            await Navigator.push(context, smoothPageRoute(page: JournalDetailScreen(entry: entry)));
            _loadEntries();
          },
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), decoration: BoxDecoration(color: moodColor.withOpacity(0.12), borderRadius: BorderRadius.circular(10)), child: Text(entry.mood, style: TextStyle(fontSize: 12, color: moodColor, fontWeight: FontWeight.bold))),
                    Text(_formatDate(entry.date, context), style: TextStyle(fontSize: 12, color: colorScheme.onSurface.withOpacity(0.4), fontWeight: FontWeight.w500)),
                  ],
                ),
                const SizedBox(height: 16),
                Text(entry.content, maxLines: 3, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 15, color: colorScheme.onSurface.withOpacity(0.8), height: 1.6)),
                const SizedBox(height: 16),
                Row(children: [Icon(Icons.read_more_rounded, size: 16, color: colorScheme.primary.withOpacity(0.5)), const SizedBox(width: 6), Text(AppLocalizations.of(context).t('read_full'), style: TextStyle(fontSize: 12, color: colorScheme.primary.withOpacity(0.6), fontWeight: FontWeight.w600))]),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date, BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final entryDate = DateTime(date.year, date.month, date.day);

    if (entryDate == today) {
      return AppLocalizations.of(context).t('today');
    } else if (entryDate == yesterday) {
      return AppLocalizations.of(context).t('yesterday');
    } else {
      final months = [
        AppLocalizations.of(context).t('jan'),
        AppLocalizations.of(context).t('feb'),
        AppLocalizations.of(context).t('mar'),
        AppLocalizations.of(context).t('apr'),
        AppLocalizations.of(context).t('may'),
        AppLocalizations.of(context).t('jun'),
        AppLocalizations.of(context).t('jul'),
        AppLocalizations.of(context).t('aug'),
        AppLocalizations.of(context).t('sep'),
        AppLocalizations.of(context).t('oct'),
        AppLocalizations.of(context).t('nov'),
        AppLocalizations.of(context).t('dec')
      ];
      return '${date.day} ${months[date.month - 1]} ${date.year}';
    }
  }
}
