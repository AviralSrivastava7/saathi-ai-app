// lib/features/games/breathing_game.dart
import 'package:flutter/material.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_colors.dart';
import '../../core/localization/app_localizations.dart';

class BreathingGame extends StatefulWidget {
  const BreathingGame({super.key});

  @override
  State<BreathingGame> createState() => _BreathingGameState();
}

class _BreathingGameState extends State<BreathingGame>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  int _breathCount = 0;
  String _instructionKey = 'inhale'; // Changed to match registry
  bool _isInhale = true;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );

    _scaleAnim = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _controller.addListener(() {
      if (_controller.value >= 0.98) {
        if (_isInhale) {
          setState(() {
            _isInhale = false;
            _instructionKey = 'exhale';
          });
        }
      }
    });

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() => _breathCount++);
        _controller.reverse();
      } else if (status == AnimationStatus.dismissed) {
        setState(() {
          _isInhale = true;
          _instructionKey = 'inhale';
        });
        _controller.forward();
      }
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localization = AppLocalizations.of(context);
    
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: AppColors.backgroundDark,
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 40),

              Text(
                localization.t('breathing_bubbles'),
                style: AppTextStyles.display.copyWith(fontSize: 32),
              ),

              const SizedBox(height: 12),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  localization.t('follow_bubble'),
                  textAlign: TextAlign.center,
                  style: AppTextStyles.body.copyWith(
                    color: Colors.white70,
                  ),
                ),
              ),

              const Spacer(),

              // Breathing Bubble
              AnimatedBuilder(
                animation: _scaleAnim,
                builder: (_, __) {
                  return Container(
                    width: 300 * _scaleAnim.value,
                    height: 300 * _scaleAnim.value,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          Colors.white.withOpacity(0.3),
                          Colors.cyan.withOpacity(0.1),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.cyan.withOpacity(0.5),
                          blurRadius: 40 * _scaleAnim.value,
                          spreadRadius: 10 * _scaleAnim.value,
                        ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 40),

              Text(
                localization.t(_instructionKey),
                style: AppTextStyles.heading.copyWith(
                  color: Colors.white,
                  fontSize: 32,
                ),
              ),

              const Spacer(),

              // Stats
              Container(
                padding: const EdgeInsets.all(24),
                margin: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Text(
                          '$_breathCount',
                          style: AppTextStyles.display.copyWith(
                            fontSize: 36,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          localization.t('breaths_label'),
                          style: AppTextStyles.body.copyWith(
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      width: 2,
                      height: 60,
                      color: Colors.white.withOpacity(0.2),
                    ),
                    Column(
                      children: [
                        Icon(
                          _isInhale
                              ? Icons.arrow_circle_up_rounded
                              : Icons.arrow_circle_down_rounded,
                          size: 48,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          localization.t(_isInhale ? 'inhale' : 'exhale'),
                          style: AppTextStyles.body.copyWith(
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
