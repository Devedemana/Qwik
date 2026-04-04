import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';

/// Lightweight local cache using Hive.
/// Stores JSON strings keyed by cache key — no code generation needed.
class LocalStorageService {
  static const _boxName = 'qwik_cache';
  static const _keyCafeterias = 'cafeterias';
  static const _keyMenuItems = 'menu_items'; // prefix: menuItems_<cafeteriaId>
  static const _keyAllMenuItems = 'all_menu_items';

  static late Box _box;

  static Future<void> init() async {
    await Hive.initFlutter();
    _box = await Hive.openBox(_boxName);
  }

  // ── Cafeterias ─────────────────────────────────────────────────────────────

  static Future<void> saveCafeterias(List<Map<String, dynamic>> data) async {
    await _box.put(_keyCafeterias, jsonEncode(data));
  }

  static List<Map<String, dynamic>>? getCafeterias() {
    final raw = _box.get(_keyCafeterias) as String?;
    if (raw == null) return null;
    return (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
  }

  // ── Menu items (all) ───────────────────────────────────────────────────────

  static Future<void> saveAllMenuItems(List<Map<String, dynamic>> data) async {
    await _box.put(_keyAllMenuItems, jsonEncode(data));
  }

  static List<Map<String, dynamic>>? getAllMenuItems() {
    final raw = _box.get(_keyAllMenuItems) as String?;
    if (raw == null) return null;
    return (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
  }

  // ── Menu items (per cafeteria) ─────────────────────────────────────────────

  static Future<void> saveMenuItems(String cafeteriaId, List<Map<String, dynamic>> data) async {
    await _box.put('${_keyMenuItems}_$cafeteriaId', jsonEncode(data));
  }

  static List<Map<String, dynamic>>? getMenuItems(String cafeteriaId) {
    final raw = _box.get('${_keyMenuItems}_$cafeteriaId') as String?;
    if (raw == null) return null;
    return (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
  }

  // ── Generic helpers ────────────────────────────────────────────────────────

  static Future<void> clear() async => _box.clear();
}
