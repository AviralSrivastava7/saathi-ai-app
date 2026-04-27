// lib/features/journal/journal_detail_screen.dart
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/localization/app_localizations.dart';
import 'models/journal_entry.dart';
import 'services/journal_service.dart';

class JournalDetailScreen extends StatelessWidget {
  final JournalEntry entry;

  const JournalDetailScreen({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Map mood to colors for better visibility
    final moodColors = {
      '😊 ${AppLocalizations.of(context).t('mood_happy')}': Colors.orange,
      '😢 ${AppLocalizations.of(context).t('mood_sad')}': Colors.blue,
      '😰 ${AppLocalizations.of(context).t('mood_anxious')}': Colors.purple,
      '😌 ${AppLocalizations.of(context).t('mood_calm')}': Colors.teal,
      '😴 ${AppLocalizations.of(context).t('mood_tired')}': Colors.grey,
      '😠 ${AppLocalizations.of(context).t('mood_angry')}': Colors.red,
    };

    final moodColor = moodColors[entry.mood] ?? AppColors.primaryPurple;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: Colors.white,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_rounded,
                  color: AppColors.onSurface, size: 18),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: IconButton(
                icon:
                    const Icon(Icons.delete_outline_rounded, color: Colors.red),
                onPressed: () => _showDeleteDialog(context),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Decoration
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _formatDate(entry.date, context),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.onSurface.withOpacity(0.4),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        AppLocalizations.of(context).t('journal_entry_label'),
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.onSurface,
                          letterSpacing: -1,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: moodColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: moodColor.withOpacity(0.2)),
                    ),
                    child: Text(
                      entry.mood,
                      style: TextStyle(
                        color: moodColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Content Paper
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: SelectionArea(
                  child: Text(
                    entry.content,
                    style: TextStyle(
                      fontSize: 18,
                      height: 1.8,
                      color: AppColors.onSurface.withOpacity(0.85),
                      fontFamily: 'Georgia', // Serif-like for long reading
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showDeleteDialog(BuildContext context) async {
    final confirm = await showGeneralDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, anim1, anim2) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text(AppLocalizations.of(context).t('delete_entry_title'),
              style: const TextStyle(fontWeight: FontWeight.bold)),
          content: Text(AppLocalizations.of(context).t('delete_entry_desc')),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(AppLocalizations.of(context).t('no'), style: const TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(AppLocalizations.of(context).t('yes_delete'),
                  style: const TextStyle(
                      color: Colors.red, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );

    if (confirm == true && context.mounted) {
      await JournalService().deleteEntry(entry.id);
      if (context.mounted) {
        Navigator.pop(context);
      }
    }
  }

  String _formatDate(DateTime date, BuildContext context) {
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
