import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppLanguage extends ChangeNotifier {
  static final AppLanguage instance = AppLanguage._();
  AppLanguage._();

  String _current = 'en';
  String get current => _current;

  /// Returns a valid Flutter Locale for MaterialApp.
  /// Maps our custom 'hn' (Hinglish) to 'en' since Flutter doesn't know 'hn'.
  /// The actual language code is preserved in [current] for translation lookups.
  Locale get currentLocale {
    // 'hn' is our custom Hinglish code — not a real Flutter locale.
    // Map it to 'en' so GlobalMaterialLocalizations is happy.
    if (_current == 'hn') return const Locale('en');
    return Locale(_current);
  }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    // Standardizing on 'selected_language' key used by LanguageScreen
    _current = prefs.getString('selected_language') ?? 'en';
    notifyListeners();
  }

  Future<void> setLanguage(String lang) async {
    _current = lang;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_language', lang);
    notifyListeners();
  }
}
