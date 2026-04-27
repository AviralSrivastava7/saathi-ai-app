import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:ui';
import '../../core/widgets/zen_aura_background.dart';
import '../../core/widgets/smooth_page_route.dart';

// Import HomeScreen - make sure this path is correct
import '../home/home_screen.dart';
import '../../core/localization/app_localizations.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingData> _pages = [
    OnboardingData(
      title: 'Main Hoon Saathi',
      subtitle: 'Aapka Personal Mental Health Companion',
      description: 'Jeevan ki har mushkil mein aapke saath',
      icon: Icons.favorite_rounded,
      gradient: [const Color(0xFF667eea), const Color(0xFF764ba2)],
    ),
    OnboardingData(
      title: 'Baat Karo Freely',
      subtitle: 'Koi Judgment Nahi',
      description:
          'Apne dil ki baat share karo, main hamesha sunne ke liye yahan hoon',
      icon: Icons.chat_bubble_rounded,
      gradient: [const Color(0xFFf093fb), const Color(0xFFF5576C)],
    ),
    OnboardingData(
      title: 'Apna Khayal Rakho',
      subtitle: 'Daily Tips & Support',
      description:
          'Mental health exercises, mood tracking aur personalized guidance',
      icon: Icons.self_improvement_rounded,
      gradient: [const Color(0xFF4facfe), const Color(0xFF00f2fe)],
    ),
    OnboardingData(
      title: 'Aapka Data, Sirf Aapke Paas',
      subtitle: '100% Private & Offline AI 🔒',
      description:
          'Aapki saari baatein sirf aapke phone mein rehti hain. Na koi server, na koi cloud — poori privacy aapke haath mein!',
      icon: Icons.shield_rounded,
      gradient: [const Color(0xFF11998e), const Color(0xFF38ef7d)],
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    try {
      debugPrint('🔵 Completing onboarding...');

      final prefs = await SharedPreferences.getInstance();

      // Set BOTH keys for safety
      await prefs.setBool('onboarding_seen', true);
      await prefs.setBool('seen_onboarding', true);

      debugPrint('✅ Onboarding preferences saved');
      debugPrint('📱 Navigating to HomeScreen...');

      if (!mounted) {
        debugPrint('❌ Widget not mounted, canceling navigation');
        return;
      }

      // Navigate to home screen
      Navigator.of(context).pushReplacement(
        smoothPageRoute(page: const HomeScreen()),
      );

      debugPrint('✅ Navigation completed');
    } catch (e) {
      debugPrint('❌ Error in _completeOnboarding: $e');

      // Show error dialog
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(AppLocalizations.of(context).t('error')),
            content: Text('Navigation failed: $e'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ZenAuraBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Skip button
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextButton(
                    onPressed: () {
                      debugPrint('⏭️ Skip button pressed');
                      _completeOnboarding();
                    },
                    child: Text(
                      'Skip',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),

              // Page View
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                    debugPrint('📄 Page changed to: $index');
                  },
                  itemCount: _pages.length,
                  itemBuilder: (context, index) {
                    return _buildOnboardingPage(_pages[index]);
                  },
                ),
              ),

              // Page Indicators
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _pages.length,
                    (index) => _buildIndicator(index == _currentPage),
                  ),
                ),
              ),

              // Next/Get Started Button
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      debugPrint('🔘 Button pressed on page $_currentPage');

                      if (_currentPage < _pages.length - 1) {
                        debugPrint('➡️ Moving to next page');
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      } else {
                        debugPrint('🎯 Last page - completing onboarding');
                        _completeOnboarding();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF667eea),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 8,
                      shadowColor: Colors.white.withValues(alpha: 0.3),
                    ),
                    child: Text(
                      _currentPage < _pages.length - 1
                          ? 'Aage Badho'
                          : 'Shuru Karo',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
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

  Widget _buildOnboardingPage(OnboardingData data) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon with glassmorphism effect
          ClipRRect(
            borderRadius: BorderRadius.circular(40),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Container(
                padding: const EdgeInsets.all(40),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.15),
                      Colors.white.withValues(alpha: 0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(40),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                    width: 1.5,
                  ),
                ),
                child: Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: data.gradient),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: data.gradient[0].withValues(alpha: 0.5),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Icon(
                    data.icon,
                    size: 80,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 48),

          // Title
          Text(
            data.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.2,
            ),
          ),

          const SizedBox(height: 16),

          // Subtitle
          Text(
            data.subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),

          const SizedBox(height: 24),

          // Description
          Text(
            data.description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withValues(alpha: 0.7),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIndicator(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 8,
      width: isActive ? 24 : 8,
      decoration: BoxDecoration(
        color: isActive ? Colors.white : Colors.white.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class OnboardingData {
  final String title;
  final String subtitle;
  final String description;
  final IconData icon;
  final List<Color> gradient;

  OnboardingData({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.gradient,
  });
}
