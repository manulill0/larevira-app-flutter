import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritesController extends ChangeNotifier {
  FavoritesController._(this._prefs, this._favoriteSlugs);

  static const _storageKey = 'favorite_brotherhood_slugs';

  final SharedPreferencesAsync _prefs;
  final Set<String> _favoriteSlugs;

  static Future<FavoritesController> create() async {
    final prefs = SharedPreferencesAsync();
    final values = await prefs.getStringList(_storageKey) ?? const <String>[];
    return FavoritesController._(prefs, values.toSet());
  }

  Set<String> get all => Set<String>.unmodifiable(_favoriteSlugs);

  bool isFavorite(String slug) => _favoriteSlugs.contains(slug);

  Future<void> toggle(String slug) async {
    if (slug.isEmpty) {
      return;
    }

    if (_favoriteSlugs.contains(slug)) {
      _favoriteSlugs.remove(slug);
    } else {
      _favoriteSlugs.add(slug);
    }

    await _prefs.setStringList(_storageKey, _favoriteSlugs.toList()..sort());
    notifyListeners();
  }
}
