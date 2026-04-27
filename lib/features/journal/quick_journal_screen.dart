// lib/features/journal/quick_journal_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import '../../core/theme/app_colors.dart';
import 'models/journal_entry.dart';
import 'services/journal_service.dart';
import '../../core/localization/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QuickJournalScreen extends StatefulWidget {
  const QuickJournalScreen({super.key});

  @override
  State<QuickJournalScreen> createState() => _QuickJournalScreenState();
}

class _QuickJournalScreenState extends State<QuickJournalScreen>
    with TickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final JournalService _journalService = JournalService();
  String _selectedMoodKey = 'mood_happy';
  bool _isSaving = false;
  String _buddyName = 'Buddy';

  // Animation Controllers
  late AnimationController _floatController;
  late AnimationController _bounceController;
  late AnimationController _blinkController;
  late AnimationController _waveController;
  late Animation<double> _floatAnimation;
  late Animation<double> _bounceAnimation;
  late Animation<double> _waveAnimation;

  // Character state
  final String _characterMessage = 'Hey! Aapke thoughts share karo! 💭';
  final bool _isCharacterHappy = true;
  final int _writingProgress = 0;

  final List<String> _moods = [
    '😊 Happy',
    '😢 Sad',
    '😰 Anxious',
    '😌 Calm',
    '😴 Tired',
    '😠 Angry',
  ];

  // Motivational messages based on writing progress
  final List<String> _progressMessages = [
    'Start karo! Main wait kar raha hoon! 😊',
    'Awesome! Keep going! ✨',
    'Bohot achha likh rahe ho! 💪',
    'You\'re doing great! Keep it up! 🌟',
  ];

  @override
  void initState() {
    super.initState();
    _loadBuddyName();
    _controller.addListener(_onTextChanged);
  }

  Future<void> _loadBuddyName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _buddyName = prefs.getString('buddy_display_name') ?? 'Buddy');
  }

  void _onTextChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _saveEntry() async {
    if (_controller.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).t('write_something_first')),
          backgroundColor: AppColors.primaryPurple,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    final entry = JournalEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: DateTime.now(),
      mood: '😊 ${AppLocalizations.of(context).t(_selectedMoodKey)}',
      content: _controller.text.trim(),
    );

    final success = await _journalService.saveEntry(entry);

    if (mounted) {
      setState(() => _isSaving = false);
      if (success) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).t('journal_saved_success')),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).t('journal_save_error')),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Material(
        color: Colors.transparent,
        child: Stack(
          children: [
            // 🎨 Calming Background Image (Low Opacity)
            Positioned.fill(
              child: Opacity(
                opacity: 0.1, // Very subtle to keep text readable
                child: Image.asset(
                  'assets/images/journal_bg.jpg',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                ),
              ),
            ),
            SafeArea(
              child: Column(
                children: [
                  // Pull Bar
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),

                  // Header Section
                  Padding(
                    padding: const EdgeInsets.fromLTRB(28, 24, 20, 16),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.primaryPurple.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(Icons.edit_note_rounded,
                              color: AppColors.primaryPurple, size: 28),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppLocalizations.of(context).t('today_journal'),
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.onSurface,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              Text(
                                AppLocalizations.of(context).t('write_from_heart'),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.onSurface.withOpacity(0.5),
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close_rounded,
                              color: AppColors.onSurface.withOpacity(0.3)),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),

                  const Divider(height: 1),

                  // Scrollable Content
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Mood Question
                          Text(
                            AppLocalizations.of(context).t('how_are_you_feeling'),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.onSurface,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Refined Mood Selector
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                'mood_happy',
                                'mood_sad',
                                'mood_anxious',
                                'mood_calm',
                                'mood_tired',
                                'mood_angry',
                              ].map((moodKey) {
                                final isSelected = moodKey == _selectedMoodKey;
                                final emoji = {
                                  'mood_happy': '😊',
                                  'mood_sad': '😢',
                                  'mood_anxious': '😰',
                                  'mood_calm': '😌',
                                  'mood_tired': '😴',
                                  'mood_angry': '😠',
                                }[moodKey]!;
                                final label = AppLocalizations.of(context).t(moodKey);
                                return GestureDetector(
                                  onTap: () {
                                    setState(() => _selectedMoodKey = moodKey);
                                    HapticFeedback.lightImpact();
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.only(right: 10),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? AppColors.primaryPurple
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: isSelected
                                            ? AppColors.primaryPurple
                                            : Colors.grey.withOpacity(0.2),
                                      ),
                                      boxShadow: isSelected
                                          ? [
                                              BoxShadow(
                                                color: AppColors.primaryPurple
                                                    .withOpacity(0.3),
                                                blurRadius: 10,
                                                offset: const Offset(0, 4),
                                              )
                                            ]
                                          : null,
                                    ),
                                    child: Text(
                                      '$emoji $label',
                                      style: TextStyle(
                                        color: isSelected
                                            ? Colors.white
                                            : AppColors.onSurface,
                                        fontWeight: isSelected
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),

                          const SizedBox(height: 32),

                          // Journal Paper
                          Container(
                            constraints: const BoxConstraints(minHeight: 300),
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9), // Slightly transparent paper
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.02),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: TextField(
                              controller: _controller,
                              maxLines: null,
                              autofocus: true,
                              style: const TextStyle(
                                fontSize: 17,
                                height: 1.6,
                                color: AppColors.onSurface,
                              ),
                              decoration: InputDecoration(
                                hintText: AppLocalizations.of(context).t('start_here_hint'),
                                hintStyle: TextStyle(
                                  color: AppColors.onSurface.withOpacity(0.3),
                                ),
                                border: InputBorder.none,
                                counterText: '',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Bottom Save Bar
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _saveEntry,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryPurple,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        child: _isSaving
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2.5, color: Colors.white),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.check_circle_rounded, size: 22),
                                  const SizedBox(width: 12),
                                  Text(
                                    AppLocalizations.of(context).t('save_journal'),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
