import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SimulatedClockController extends ChangeNotifier {
  SimulatedClockController._(this._prefs, this._simulatedNow);

  static const _storageKey = 'debug_simulated_now_v1';

  final SharedPreferences _prefs;
  DateTime? _simulatedNow;

  static Future<SimulatedClockController> create({
    DateTime? initialSimulatedNow,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    final stored = raw == null ? null : DateTime.tryParse(raw);
    final effective = stored ?? initialSimulatedNow;

    if (stored == null && initialSimulatedNow != null) {
      await prefs.setString(_storageKey, initialSimulatedNow.toIso8601String());
    }

    return SimulatedClockController._(prefs, effective);
  }

  bool get isSimulating => _simulatedNow != null;

  DateTime get now => _simulatedNow ?? DateTime.now();

  DateTime? get simulatedNow => _simulatedNow;

  Future<void> setSimulatedNow(DateTime value) async {
    _simulatedNow = value;
    await _prefs.setString(_storageKey, value.toIso8601String());
    notifyListeners();
  }

  Future<void> clearSimulation() async {
    _simulatedNow = null;
    await _prefs.remove(_storageKey);
    notifyListeners();
  }
}
