import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageViewmodel extends ChangeNotifier {
  Locale _currentLocale = const Locale('en');
  static const String _languageKey = 'language_code';

  Locale get currentLocale => _currentLocale;

  final List<LocaleOption> supportedLanguages = [
    LocaleOption(locale: const Locale('en'), name: 'English', flag: '🇬🇧'),
    LocaleOption(locale: const Locale('es'), name: 'Español', flag: '🇪🇸'),
    LocaleOption(locale: const Locale('de'), name: 'Deutsch', flag: '🇩🇪'),
    LocaleOption(locale: const Locale('it'), name: 'Italiano', flag: '🇮🇹'),
  ];

  LanguageViewmodel() {
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString(_languageKey) ?? 'en';
    _currentLocale = Locale(languageCode);
    notifyListeners();
  }

  Future<void> changeLanguage(Locale locale) async {
    if (_currentLocale == locale) return;
    _currentLocale = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, locale.languageCode);
    notifyListeners();
  }
}

class LocaleOption {
  final Locale locale;
  final String name;
  final String flag;

  LocaleOption({required this.locale, required this.name, required this.flag});
}
