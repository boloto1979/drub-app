import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'preferences_provider.dart';

part 'locale_provider.g.dart';

const _kLocaleKey = 'locale';
const _kOnboardingDoneKey = 'onboarding_done';

const supportedLocales = [
  Locale('en'),
  Locale('pt'),
];

@Riverpod(keepAlive: true)
class LocaleNotifier extends _$LocaleNotifier {
  @override
  Locale build() {
    final prefs = ref.watch(sharedPreferencesProvider).valueOrNull;
    final saved = prefs?.getString(_kLocaleKey);
    if (saved != null) return Locale(saved);
    return const Locale('en');
  }

  Future<void> setLocale(Locale locale) async {
    final prefs = await ref.read(sharedPreferencesProvider.future);
    await prefs.setString(_kLocaleKey, locale.languageCode);
    state = locale;
  }
}

@Riverpod(keepAlive: true)
class OnboardingNotifier extends _$OnboardingNotifier {
  @override
  bool build() {
    final prefs = ref.watch(sharedPreferencesProvider).valueOrNull;
    return prefs?.getBool(_kOnboardingDoneKey) ?? false;
  }

  Future<void> complete() async {
    final prefs = await ref.read(sharedPreferencesProvider.future);
    await prefs.setBool(_kOnboardingDoneKey, true);
    state = true;
  }

  Future<void> reset() async {
    final prefs = await ref.read(sharedPreferencesProvider.future);
    await prefs.setBool(_kOnboardingDoneKey, false);
    state = false;
  }
}
