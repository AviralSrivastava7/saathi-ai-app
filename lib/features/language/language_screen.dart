import 'package:flutter/material.dart';
import 'dart:ui';
import '../../core/config/app_language.dart';
import '../onboarding/onboarding_screen.dart';
import '../../core/widgets/zen_aura_background.dart';
import '../../core/widgets/smooth_page_route.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  String? _selectedLanguage;

  final List<LanguageOption> _languages = [
    LanguageOption(
      code: 'hi',
      name: 'हिंदी',
      nativeName: 'Hindi',
      flag: '🇮🇳',
      gradient: [const Color(0xFF667eea), const Color(0xFF764ba2)],
    ),
    LanguageOption(
      code: 'en',
      name: 'English',
      nativeName: 'English',
      flag: '🇬🇧',
      gradient: [const Color(0xFF4facfe), const Color(0xFF00f2fe)],
    ),
    LanguageOption(
      code: 'hn',
      name: 'Hinglish',
      nativeName: 'Hinglish',
      flag: '🔤',
      gradient: [const Color(0xFFf6d365), const Color(0xFFfda085)],
    ),
  ];

  Future<void> _selectLanguage(String languageCode) async {
    await AppLanguage.instance.setLanguage(languageCode);

    if (mounted) {
      // Navigate to onboarding screen
      Navigator.of(context).pushReplacement(
        smoothPageRoute(page: const OnboardingScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ZenAuraBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App Icon
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF667EEA).withValues(alpha: 0.5),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.psychology_rounded,
                    size: 50,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 32),

                // Title
                const Text(
                  'Welcome to Saathi',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 8),

                // Subtitle
                Text(
                  'Choose Your Language\nअपनी भाषा चुनें',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withValues(alpha: 0.7),
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 48),

                // Language Options
                ..._languages.map((language) => Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: _buildLanguageCard(language),
                    )),

                const SizedBox(height: 24),

                // Info Text
                Text(
                  'You can change this later in settings',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageCard(LanguageOption language) {
    final isSelected = _selectedLanguage == language.code;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedLanguage = language.code;
        });
        _selectLanguage(language.code);
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isSelected
                    ? [
                        Colors.white.withValues(alpha: 0.25),
                        Colors.white.withValues(alpha: 0.15),
                      ]
                    : [
                        Colors.white.withValues(alpha: 0.1),
                        Colors.white.withValues(alpha: 0.05),
                      ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected
                    ? Colors.white.withValues(alpha: 0.5)
                    : Colors.white.withValues(alpha: 0.2),
                width: isSelected ? 2 : 1.5,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: language.gradient[0].withValues(alpha: 0.3),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ]
                  : [],
            ),
            child: Row(
              children: [
                // Flag
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: language.gradient),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      language.flag,
                      style: const TextStyle(fontSize: 32),
                    ),
                  ),
                ),

                const SizedBox(width: 20),

                // Language Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        language.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        language.nativeName,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),

                // Selection Indicator
                if (isSelected)
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: language.gradient),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class LanguageOption {
  final String code;
  final String name;
  final String nativeName;
  final String flag;
  final List<Color> gradient;

  LanguageOption({
    required this.code,
    required this.name,
    required this.nativeName,
    required this.flag,
    required this.gradient,
  });
}
