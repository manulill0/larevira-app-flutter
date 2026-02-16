import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends ChangeNotifier {
  ThemeController._(this._prefs, this._mode);

  static const _storageKey = 'theme_mode_v1';

  final SharedPreferencesAsync _prefs;
  ThemeMode _mode;

  ThemeMode get mode => _mode;

  static Future<ThemeController> create() async {
    final prefs = SharedPreferencesAsync();
    final raw = await prefs.getString(_storageKey);

    final mode = switch (raw) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };

    return ThemeController._(prefs, mode);
  }

  Future<void> setMode(ThemeMode mode) async {
    _mode = mode;
    await _prefs.setString(_storageKey, _toRaw(mode));
    notifyListeners();
  }

  String _toRaw(ThemeMode mode) {
    return switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };
  }
}
