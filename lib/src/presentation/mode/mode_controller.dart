import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ModeController extends ChangeNotifier {
  ModeController._(this._prefs, this._mode);

  static const _storageKey = 'app_mode_v1';
  static const Set<String> _validModes = {'all', 'live', 'official'};

  final SharedPreferencesAsync _prefs;
  String _mode;

  String get mode => _mode;

  static Future<ModeController> create({required String initialMode}) async {
    final prefs = SharedPreferencesAsync();
    final raw = await prefs.getString(_storageKey);
    final mode = _sanitize(raw) ?? _sanitize(initialMode) ?? 'all';
    return ModeController._(prefs, mode);
  }

  Future<void> setMode(String mode) async {
    final next = _sanitize(mode);
    if (next == null || next == _mode) {
      return;
    }

    _mode = next;
    await _prefs.setString(_storageKey, next);
    notifyListeners();
  }

  static String? _sanitize(String? mode) {
    if (mode == null) {
      return null;
    }
    return _validModes.contains(mode) ? mode : null;
  }
}
