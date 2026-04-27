import 'package:flutter/material.dart';
import 'dart:math';
import '../../core/localization/app_localizations.dart';
import '../../core/widgets/zen_aura_background.dart';

class AffirmationsScreen extends StatefulWidget {
  const AffirmationsScreen({super.key});

  @override
  State<AffirmationsScreen> createState() => _AffirmationsScreenState();
}

class _AffirmationsScreenState extends State<AffirmationsScreen> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  static const List<_Affirmation> _affirmations = [
    _Affirmation('aff_1', '💛', 'aff_cat_1', Color(0xFFF59E0B)),
    _Affirmation('aff_2', '🕊️', 'aff_cat_2', Color(0xFF6366F1)),
    _Affirmation('aff_3', '💖', 'aff_cat_3', Color(0xFFEC4899)),
    _Affirmation('aff_4', '🌊', 'aff_cat_4', Color(0xFF3B82F6)),
    _Affirmation('aff_5', '🍃', 'aff_cat_5', Color(0xFF10B981)),
    _Affirmation('aff_6', '🌱', 'aff_cat_6', Color(0xFF22C55E)),
    _Affirmation('aff_7', '🧘', 'aff_cat_7', Color(0xFF8B5CF6)),
    _Affirmation('aff_8', '✨', 'aff_cat_8', Color(0xFFF97316)),
    _Affirmation('aff_9', '☁️', 'aff_cat_9', Color(0xFF06B6D4)),
    _Affirmation('aff_10', '🌟', 'aff_cat_10', Color(0xFFEAB308)),
    _Affirmation('aff_11', '🦋', 'aff_cat_11', Color(0xFFA855F7)),
    _Affirmation('aff_12', '🌈', 'aff_cat_12', Color(0xFFEF4444)),
    _Affirmation('aff_13', '🤝', 'aff_cat_13', Color(0xFF14B8A6)),
    _Affirmation('aff_14', '🏔️', 'aff_cat_14', Color(0xFF64748B)),
    _Affirmation('aff_15', '🌬️', 'aff_cat_15', Color(0xFF0EA5E9)),
    _Affirmation('aff_16', '🌻', 'aff_cat_16', Color(0xFFFBBF24)),
    _Affirmation('aff_17', '🤍', 'aff_cat_17', Color(0xFF94A3B8)),
    _Affirmation('aff_18', '💫', 'aff_cat_18', Color(0xFFD946EF)),
    _Affirmation('aff_19', '🚀', 'aff_cat_19', Color(0xFF7C3AED)),
    _Affirmation('aff_20', '🌸', 'aff_cat_20', Color(0xFFFB7185)),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = Random().nextInt(_affirmations.length);
    _pageController.addListener(() {
      if (_pageController.page != null) {
        setState(() => _currentIndex = _pageController.page!.round());
      }
    });
  }

  @override
  void dispose() { 
    _pageController.dispose(); 
    super.dispose(); 
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final current = _affirmations[_currentIndex % _affirmations.length];

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ZenAuraBackground(
        child: SafeArea(
          child: Column(
            children: [
              AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  icon: Icon(Icons.arrow_back_ios_new_rounded, color: colorScheme.onSurface), 
                  onPressed: () => Navigator.pop(context)
                ),
                title: Text(
                  AppLocalizations.of(context).t('affirmations'), 
                  style: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.w900, fontSize: 24, letterSpacing: -0.5)
                ),
              ),
              const SizedBox(height: 16),
              // Hero Card — swipeable
              Expanded(
                flex: 3,
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _affirmations.length,
                  onPageChanged: (i) => setState(() => _currentIndex = i),
                  itemBuilder: (context, index) {
                    final a = _affirmations[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [a.color, a.color.withOpacity(0.6)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                          borderRadius: BorderRadius.circular(36),
                          boxShadow: [BoxShadow(color: a.color.withOpacity(0.35), blurRadius: 25, offset: const Offset(0, 12))],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(36),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(a.emoji, style: const TextStyle(fontSize: 56)),
                              const SizedBox(height: 28),
                              Text(
                                AppLocalizations.of(context).t(a.textKey),
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold, height: 1.4, letterSpacing: -0.5),
                              ),
                              const SizedBox(height: 20),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                                child: Text(AppLocalizations.of(context).t(a.categoryKey), style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 13, fontWeight: FontWeight.w600)),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Page indicator dots
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('${_currentIndex + 1}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: current.color)),
                    Text(' / ${_affirmations.length}', style: TextStyle(fontSize: 14, color: colorScheme.onSurface.withOpacity(0.4))),
                  ],
                ),
              ),

              // Swipe hint
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(AppLocalizations.of(context).t('swipe_for_more'), style: TextStyle(fontSize: 13, color: colorScheme.onSurface.withOpacity(0.3))),
              ),

              // Quick Affirmation Grid
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(AppLocalizations.of(context).t('quick_picks'), style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colorScheme.onSurface, letterSpacing: -0.5)),
                      const SizedBox(height: 12),
                      Expanded(
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _affirmations.length,
                          itemBuilder: (context, i) {
                            final a = _affirmations[i];
                            final selected = i == _currentIndex;
                            return GestureDetector(
                              onTap: () {
                                _pageController.animateToPage(i, duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
                              },
                              child: Container(
                                width: 130,
                                margin: const EdgeInsets.only(right: 12),
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: selected ? a.color.withOpacity(0.12) : colorScheme.surface,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: selected ? a.color.withOpacity(0.3) : colorScheme.onSurface.withOpacity(0.04)),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(a.emoji, style: const TextStyle(fontSize: 28)),
                                    const SizedBox(height: 8),
                                    Text(AppLocalizations.of(context).t(a.categoryKey), textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: selected ? a.color : colorScheme.onSurface.withOpacity(0.6))),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _Affirmation {
  final String textKey, emoji, categoryKey;
  final Color color;
  const _Affirmation(this.textKey, this.emoji, this.categoryKey, this.color);
}
