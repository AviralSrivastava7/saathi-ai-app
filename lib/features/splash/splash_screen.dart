import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ✓ Corrected imports - single source for each screen
import 'package:saathi/features/language/language_screen.dart';
import 'package:saathi/features/onboarding/onboarding_screen.dart';
import '../home/home_screen.dart';
import '../ai/model_select_sheet.dart';
import '../../core/storage/ai_popup_storage.dart';
import '../../core/widgets/zen_aura_background.dart';
import '../../core/widgets/smooth_page_route.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _controller.forward();
    _navigateToNextScreen();
  }

  Future<void> _navigateToNextScreen() async {
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();
    final hasSeenOnboarding = prefs.getBool('seen_onboarding') ?? false;
    final hasSelectedLanguage = prefs.getString('selected_language') != null;

    Widget nextScreen;

    if (!hasSelectedLanguage) {
      nextScreen = const LanguageScreen();
    } else if (!hasSeenOnboarding) {
      nextScreen = const OnboardingScreen();
    } else {
      nextScreen = const HomeScreen();
    }

    if (!mounted) return;

    await Navigator.of(context).pushReplacement(
      smoothPageRoute(page: nextScreen),
    );

    // Show model picker popup only once — after onboarding is complete
    if (hasSeenOnboarding && hasSelectedLanguage && mounted) {
      final hasSeenModelPopup = await AIPopupStorage.hasSeenModelPopup();
      if (!hasSeenModelPopup && mounted) {
        await AIPopupStorage.markModelPopupShown();
        // Small delay so HomeScreen is fully rendered first
        await Future.delayed(const Duration(milliseconds: 400));
        if (mounted) {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            enableDrag: true,
            backgroundColor: Colors.transparent,
            builder: (_) => const ModelSelectSheet(),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ZenAuraBackground(
        child: Center(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Opacity(
                opacity: _fadeAnimation.value,
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // App Logo/Icon
                      Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withOpacity(0.1),
                              blurRadius: 40,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: const Stack(
                          alignment: Alignment.center,
                          children: [
                            Icon(
                              Icons.auto_awesome,
                              size: 70,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      // App Name
                      const Text(
                        'Saathi',
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Tagline
                      Text(
                        'Your Mental Health Companion',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.8),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Privacy Tagline - Highlighted
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withOpacity(0.1),
                              blurRadius: 20,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.shield_rounded, color: Colors.greenAccent, size: 18),
                            SizedBox(width: 8),
                            Text(
                              'Aapka Data, Sirf Aapke Paas 🔒',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.greenAccent,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
