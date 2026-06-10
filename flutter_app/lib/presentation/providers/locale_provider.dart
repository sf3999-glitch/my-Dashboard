import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';

class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier() : super(const Locale('en')) {
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString(AppConstants.keyLocale) ?? 'en';
    state = Locale(languageCode);
  }

  Future<void> setLocale(String languageCode) async {
    state = Locale(languageCode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.keyLocale, languageCode);
  }

  String get currentLanguageCode => state.languageCode;

  Map<String, String>? get currentLanguageInfo {
    return AppConstants.supportedLanguages.firstWhere(
      (l) => l['code'] == state.languageCode,
      orElse: () => AppConstants.supportedLanguages.first,
    );
  }

  bool get isRtl => state.languageCode == 'ar' || state.languageCode == 'ur';
}

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier();
});
