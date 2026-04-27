import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/theme/theme_manager.dart';
import 'core/storage/stats_storage.dart';
import 'core/services/notification_service.dart';
import 'core/localization/app_localizations.dart';
import 'core/config/app_language.dart';

import 'features/splash/splash_screen.dart';
import 'features/language/language_screen.dart';
import 'features/onboarding/onboarding_screen.dart' as modular_onboarding;
import 'features/home/home_screen.dart';
import 'features/journal/journal_screen.dart' as modular_journal;
import 'features/sos/sos_screen.dart' as modular_sos;
import 'features/chat/chat_screen.dart' as modular_chat;
import 'features/profile/profile_screen.dart' as modular_profile;
import 'core/ai/saathi_brain.dart';
import 'core/ai/llm_offline_engine.dart';
import 'core/ai/model_manager.dart';
import 'core/widgets/biometric_gate.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // 1. Core Brain Init
    await SaathiBrain.init();
    
    // 1b. Fire-and-forget LLM engine init — starts loading the model
    // in the background so it's ready by the time user opens chat/voice.
    // This runs async and does NOT block app startup.
    ModelManager.getActiveModel().then((model) {
      if (model != null) {
        debugPrint('[Saathi] Early LLM init — model found, starting background load…');
        ExperimentalLLMEngine.init();
      }
    }).catchError((_) {});
    
    // 2. Notifications (Safely guarded for Windows inside the service)
    final notifications = NotificationService();
    await notifications.init();
    
    await notifications.scheduleDailyReminder(
      id: 101,
      title: 'Morning Motivation 🌞',
      body: 'Take a deep breath and start your day with mindfulness.',
      hour: 8,
      minute: 0,
    );
    
    await notifications.scheduleDailyReminder(
      id: 102,
      title: 'Checklist Reminder 📝',
      body: 'Don\'t forget to complete your daily wellness checklist!',
      hour: 20,
      minute: 0,
    );

    // 3. Buddy engagement notifications
    await notifications.scheduleDailyReminder(
      id: 201,
      title: 'Buddy misses you! 🐾',
      body: 'Come play with your Buddy — they\'re waiting for you!',
      hour: 10,
      minute: 0,
    );

    await notifications.scheduleDailyReminder(
      id: 202,
      title: 'Time to play! 🎮',
      body: 'Challenge your Buddy to Tic-Tac-Toe or Rock Paper Scissors!',
      hour: 15,
      minute: 0,
    );

    await notifications.scheduleDailyReminder(
      id: 203,
      title: 'Buddy says goodnight! 🌙',
      body: 'Visit your Buddy before bed for a peaceful night.',
      hour: 21,
      minute: 0,
    );

    // 4. App Language & Theme
    await AppLanguage.instance.load();
    final prefs = await SharedPreferences.getInstance();
    final isDarkMode = prefs.getBool('dark_mode') ?? false;
    ThemeManager().setInitialTheme(isDarkMode);

    // 5. Persistent Stats
    await StatsStorage.loadAllStats();
  } catch (e) {
    debugPrint('[Initialization Error] $e');
    // We still continue to runApp so the UI can at least tell the user something is wrong
  }

  runApp(const SaathiApp());
}

class SaathiApp extends StatelessWidget {
  const SaathiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([ThemeManager(), AppLanguage.instance]),
      builder: (context, child) {
        return MaterialApp(
          title: 'Saathi',
          theme: ThemeManager().currentTheme,
          locale: AppLanguage.instance.currentLocale,
          home: const BiometricGate(
            sectionName: 'Saathi App',
            child: SplashScreen(),
          ),
          debugShowCheckedModeBanner: false,
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: TextScaler.noScaling,
              ),
              child: DefaultTextStyle(
                style: const TextStyle(
                  decoration: TextDecoration.none,
                ),
                child: child!,
              ),
            );
          },
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'),
            Locale('hi'),
            Locale('pa'),
          ],
          routes: {
            '/home': (context) => const HomeScreen(),
            '/splash': (context) => const BiometricGate(sectionName: 'Saathi App', child: SplashScreen()),
            '/onboarding': (context) => const modular_onboarding.OnboardingScreen(),
            '/language': (context) => const LanguageScreen(),
            '/profile': (context) => const modular_profile.ProfileScreen(),
            '/journal': (context) => const modular_journal.JournalScreen(),
            '/sos': (context) => const modular_sos.SOSScreen(),
            '/chat': (context) => const modular_chat.ChatScreen(),
          },
        );
      },
    );
  }
}
