// lib/features/games/color_therapy_game.dart
import 'package:flutter/material.dart';
import 'dart:math';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_colors.dart';
import '../../core/localization/app_localizations.dart';

class ColorTherapyGame extends StatefulWidget {
  const ColorTherapyGame({super.key});

  @override
  State<ColorTherapyGame> createState() => _ColorTherapyGameState();
}

class _ColorTherapyGameState extends State<ColorTherapyGame> {
  Color _selectedColor = const Color(0xFF43E97B);
  final Random _random = Random();

  final List<Map<String, dynamic>> _colorMoods = [
    {
      'color': const Color(0xFF43E97B),
      'name': 'peaceful_green',
      'mood': 'calm_balanced'
    },
    {
      'color': const Color(0xFF38F9D7),
      'name': 'serene_cyan',
      'mood': 'fresh_clear'
    },
    {
      'color': const Color(0xFF9D50BB),
      'name': 'mystical_purple',
      'mood': 'inspired_creative'
    },
    {
      'color': const Color(0xFFF97316),
      'name': 'vibrant_orange',
      'mood': 'energetic_joyful'
    },
    {
      'color': const Color(0xFF3B82F6),
      'name': 'tranquil_blue',
      'mood': 'peaceful_focused'
    },
    {
      'color': const Color(0xFFEC4899),
      'name': 'loving_pink',
      'mood': 'warm_caring'
    },
    {
      'color': const Color(0xFFEAB308),
      'name': 'sunny_yellow',
      'mood': 'happy_optimistic'
    },
    {
      'color': const Color(0xFF14B8A6),
      'name': 'ocean_teal',
      'mood': 'balanced_refreshed'
    },
  ];

  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentIndex = _random.nextInt(_colorMoods.length);
    _selectedColor = _colorMoods[_currentIndex]['color'];
  }

  void _changeColor() {
    setState(() {
      _currentIndex = (_currentIndex + 1) % _colorMoods.length;
      _selectedColor = _colorMoods[_currentIndex]['color'];
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentMood = _colorMoods[_currentIndex];

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 800),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              _selectedColor,
              _selectedColor.withValues(alpha: 0.7),
              AppColors.backgroundDark,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // App Bar
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_rounded,
                          color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Text(
                      AppLocalizations.of(context).t('color_therapy'),
                      style: AppTextStyles.headingLarge.copyWith(
                        fontSize: 22,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Color Display
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Animated Circle
                    TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 800),
                      tween: Tween(begin: 0.8, end: 1.0),
                      builder: (context, value, child) {
                        return Container(
                          width: 200 * value,
                          height: 200 * value,
                          decoration: BoxDecoration(
                            color: _selectedColor,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: _selectedColor.withValues(alpha: 0.6),
                                blurRadius: 60 * value,
                                spreadRadius: 20 * value,
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 48),

                    // Color Name
                    Text(
                      AppLocalizations.of(context).t(currentMood['name']),
                      style: AppTextStyles.headingLarge.copyWith(
                        color: Colors.white,
                        fontSize: 32,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Mood Description
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 48),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.4),
                          width: 2,
                        ),
                      ),
                      child: Text(
                        AppLocalizations.of(context).t(currentMood['mood']),
                        textAlign: TextAlign.center,
                        style: AppTextStyles.headingSmall.copyWith(
                          color: Colors.white,
                          fontSize: 20,
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Instructions
                    Text(
                      AppLocalizations.of(context).t('color_therapy_instr'),
                      textAlign: TextAlign.center,
                      style: AppTextStyles.body.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Next Button
              Padding(
                padding: const EdgeInsets.all(32),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _changeColor,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          AppLocalizations.of(context).t('next_color'),
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: _selectedColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(Icons.arrow_forward, color: _selectedColor),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
