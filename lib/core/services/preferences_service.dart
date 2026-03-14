import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Centralizirani servis za lokalne korisničke preferencije.
///
/// Pamti grid/list view, sort odabir i aktivni tab za svaki ekran.
/// Na webu nakon hot-restart plugin može biti nedostupan — servis
/// tada radi u fallback modu (in-memory, bez perzistencije).
class PreferencesService {
  PreferencesService._();
  static final instance = PreferencesService._();

  SharedPreferences? _prefs;
  bool _initialized = false;

  /// In-memory fallback kada SharedPreferences nije dostupan (web hot-restart).
  final Map<String, Object> _fallback = {};

  Future<void> init() async {
    if (_initialized) return;
    try {
      _prefs = await SharedPreferences.getInstance();
    } catch (e) {
      debugPrint(
        'SharedPreferences nedostupan, koristim in-memory fallback: $e',
      );
      _prefs = null;
    }
    _initialized = true;
  }

  // ─── Keys ──────────────────────────────────────────────────

  static const _keyGridView = 'gridView_';
  static const _keySort = 'sort_';
  static const _keyTab = 'tab_';
  static const _keySectionOrder = 'sectionOrder_';

  // ─── Grid / List ───────────────────────────────────────────

  bool getGridView(String screen) {
    final key = '$_keyGridView$screen';
    return (_prefs?.getBool(key) ?? _fallback[key] as bool?) ?? true;
  }

  Future<void> setGridView(String screen, {required bool isGrid}) async {
    final key = '$_keyGridView$screen';
    if (_prefs != null) {
      await _prefs!.setBool(key, isGrid);
    } else {
      _fallback[key] = isGrid;
    }
  }

  // ─── Sort ──────────────────────────────────────────────────

  String? getSort(String screen) {
    final key = '$_keySort$screen';
    return _prefs?.getString(key) ?? _fallback[key] as String?;
  }

  Future<void> setSort(String screen, String sortName) async {
    final key = '$_keySort$screen';
    if (_prefs != null) {
      await _prefs!.setString(key, sortName);
    } else {
      _fallback[key] = sortName;
    }
  }

  // ─── Tab ───────────────────────────────────────────────────

  int getTab(String screen) {
    final key = '$_keyTab$screen';
    return (_prefs?.getInt(key) ?? _fallback[key] as int?) ?? 0;
  }

  Future<void> setTab(String screen, int index) async {
    final key = '$_keyTab$screen';
    if (_prefs != null) {
      await _prefs!.setInt(key, index);
    } else {
      _fallback[key] = index;
    }
  }

  // ─── Section Order ─────────────────────────────────────────

  /// Returns saved section order, or null if not set.
  List<int>? getSectionOrder(String screen) {
    final key = '$_keySectionOrder$screen';
    final raw = _prefs?.getStringList(key) ?? _fallback[key] as List<String>?;
    if (raw == null) return null;
    return raw.map(int.parse).toList();
  }

  Future<void> setSectionOrder(String screen, List<int> order) async {
    final key = '$_keySectionOrder$screen';
    final raw = order.map((e) => e.toString()).toList();
    if (_prefs != null) {
      await _prefs!.setStringList(key, raw);
    } else {
      _fallback[key] = raw;
    }
  }
}
