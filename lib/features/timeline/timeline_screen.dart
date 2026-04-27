import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_colors.dart';
import '../../core/storage/journey_storage.dart';
import '../../core/widgets/zen_aura_background.dart';
import '../../core/localization/app_localizations.dart';

class TimelineScreen extends StatelessWidget {
  const TimelineScreen({super.key});

  String _prettyDate(String raw) {
    try {
      DateTime d;

      if (raw.contains('T')) {
        d = DateTime.parse(raw);
      } else if (raw.contains('-')) {
        final parts = raw.split('-');
        d = DateTime(
          int.parse(parts[0]),
          int.parse(parts[1]),
          int.parse(parts[2]),
        );
      } else {
        d = DateTime.now();
      }

      final months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec'
      ];
      return '${d.day} ${months[d.month - 1]} ${d.year}';
    } catch (e) {
      print("Date parsing error: $e for date: $raw");
      final now = DateTime.now();
      final months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec'
      ];
      return '${now.day} ${months[now.month - 1]} ${now.year}';
    }
  }

  Color _getMoodColor(String label) {
    final l = label.toLowerCase();
    if (l.contains('ok') || l.contains('happy')) return AppColors.moodHappy;
    if (l.contains('calm') || l.contains('normal')) return AppColors.moodCalm;
    if (l.contains('heavy') || l.contains('sad')) return AppColors.moodSad;
    return AppColors.moodAnxious;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(AppLocalizations.of(context).t('your_journey')),
      ),
      body: ZenAuraBackground(
        child: SafeArea(
          child: FutureBuilder(
            future: JourneyStorage.load(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final data = snapshot.data ?? [];

              if (data.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.3),
                                blurRadius: 30,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Text('🌱', style: TextStyle(fontSize: 56)),
                          ),
                        ),
                        const SizedBox(height: 32),
                        const Text(
                          'Tum akela nahi ho.',
                          style: AppTextStyles.headingSmall,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Jaise-jaise likhte jaoge,\ntumhari journey yahan dikhegi.',
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: AppColors.textSecondary,
                            height: 1.6,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 80, 20, 20),
                itemCount: data.length,
                itemBuilder: (_, i) {
                  final d = data[data.length - 1 - i];
                  final moodColor = _getMoodColor(d['moodLabel'] ?? 'Unknown');

                  // ✅ FIX: Added ValueKey
                  return _TimelineCard(
                    key: ValueKey('timeline_${d['date']}_$i'),
                    date: _prettyDate(d['date'] ?? DateTime.now().toString()),
                    emoji: d['moodEmoji'] ?? '🙂',
                    label: d['moodLabel'] ?? 'Unknown',
                    journal: d['journal'] ?? '',
                    chat: d['chat'] ?? '',
                    color: moodColor,
                    isFirst: i == 0,
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

class _TimelineCard extends StatelessWidget {
  final String date;
  final String emoji;
  final String label;
  final String journal;
  final String chat;
  final Color color;
  final bool isFirst;

  const _TimelineCard({
    super.key, // ✅ Added super.key
    required this.date,
    required this.emoji,
    required this.label,
    required this.journal,
    required this.chat,
    required this.color,
    required this.isFirst,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 📍 TIMELINE INDICATOR
          Column(
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color, color.withValues(alpha: 0.6)],
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.5),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
              if (!isFirst)
                Container(
                  width: 2,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        color.withValues(alpha: 0.5),
                        color.withValues(alpha: 0.1),
                      ],
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(width: 16),

          // 🎴 CARD
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withValues(alpha: 0.1),
                        Colors.white.withValues(alpha: 0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 📅 DATE
                      Text(
                        date,
                        style: AppTextStyles.label.copyWith(
                          color: color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // 🎭 MOOD
                      Row(
                        children: [
                          Text(emoji, style: const TextStyle(fontSize: 32)),
                          const SizedBox(width: 12),
                          Text(
                            label,
                            style: AppTextStyles.subHeading.copyWith(
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),

                      // 📝 JOURNAL
                      if (journal.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(
                                    Icons.book_outlined,
                                    size: 16,
                                    color: AppColors.textHint,
                                  ),
                                  SizedBox(width: 6),
                                  Text(
                                    'Journal',
                                    style: AppTextStyles.label,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                journal,
                                style: AppTextStyles.bodySmall.copyWith(
                                  height: 1.5,
                                ),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],

                      // 💬 CHAT
                      if (chat.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(
                                    Icons.chat_bubble_outline,
                                    size: 16,
                                    color: AppColors.textHint,
                                  ),
                                  SizedBox(width: 6),
                                  Text(
                                    'Shared',
                                    style: AppTextStyles.label,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                chat,
                                style: AppTextStyles.bodySmall.copyWith(
                                  height: 1.5,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
