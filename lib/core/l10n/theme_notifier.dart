import 'package:flutter/material.dart';

import 'package:helpi_admin/core/services/preferences_service.dart';

/// Obavještava widget stablo o promjeni teme (light/dark/system).
class ThemeNotifier extends ValueNotifier<ThemeMode> {
  ThemeNotifier() : super(_load());

  static ThemeMode _load() {
    final saved = PreferencesService.instance.getThemeMode();
    return _parse(saved);
  }

  void setThemeMode(ThemeMode mode) {
    value = mode;
    PreferencesService.instance.setThemeMode(_toStr(mode));
  }

  static ThemeMode _parse(String s) => switch (s) {
    'light' => ThemeMode.light,
    'dark' => ThemeMode.dark,
    _ => ThemeMode.system,
  };

  static String _toStr(ThemeMode m) => switch (m) {
    ThemeMode.light => 'light',
    ThemeMode.dark => 'dark',
    ThemeMode.system => 'system',
  };
}
