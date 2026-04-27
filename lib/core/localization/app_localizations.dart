import 'package:flutter/material.dart';
import 'translations.dart';
import '../config/app_language.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  String translate(String key, [Object? val]) {
    // Use the REAL language code from AppLanguage, not the Flutter locale.
    // This is critical because Hinglish ('hn') is mapped to 'en' at the
    // Flutter level, but we need the actual 'hn' code for our translations.
    final realLang = AppLanguage.instance.current;
    return Translations.get(key, realLang, val);
  }

  // Shorthand getter
  String t(String key, [Object? val]) => translate(key, val);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    // We support en, hi, pa directly. 'hn' is mapped to 'en' at Flutter level.
    return ['en', 'hi', 'pa'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
