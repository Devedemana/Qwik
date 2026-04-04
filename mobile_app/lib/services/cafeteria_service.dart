import 'api_service.dart';
import 'local_storage_service.dart';
import '../models/cafeteria.dart';
import '../models/food_item.dart';

class CafeteriaService {
  static Future<List<Cafeteria>> listCafeterias() async {
    try {
      final res = await ApiService.get('/api/cafeterias');
      final data = (res['data'] as List<dynamic>).cast<Map<String, dynamic>>();
      // Persist to cache
      await LocalStorageService.saveCafeterias(data);
      return data.map((j) => Cafeteria.fromJson(j)).toList();
    } catch (_) {
      // Offline fallback — serve from cache
      final cached = LocalStorageService.getCafeterias();
      if (cached != null) return cached.map((j) => Cafeteria.fromJson(j)).toList();
      rethrow;
    }
  }

  static Future<List<FoodItem>> getMenu(String cafeteriaId, {String? category}) async {
    final query = category != null ? '?category=$category' : '';
    try {
      final res = await ApiService.get('/api/cafeterias/$cafeteriaId/menu$query');
      final data = (res['data'] as List<dynamic>).cast<Map<String, dynamic>>();
      if (category == null) {
        await LocalStorageService.saveMenuItems(cafeteriaId, data);
      }
      return data.map((j) => FoodItem.fromJson(j)).toList();
    } catch (_) {
      final cached = LocalStorageService.getMenuItems(cafeteriaId);
      if (cached != null) return cached.map((j) => FoodItem.fromJson(j)).toList();
      rethrow;
    }
  }

  static Future<List<FoodItem>> search(String query) async {
    final res = await ApiService.get('/api/cafeterias/search?q=$query');
    final data = res['data'] as List<dynamic>;
    return data.map((j) => FoodItem.fromJson(j as Map<String, dynamic>)).toList();
  }

  static Future<List<FoodItem>> getAllMenuItems() async {
    try {
      final cafeterias = await listCafeterias();
      final List<Map<String, dynamic>> allRaw = [];
      final List<FoodItem> all = [];
      for (final c in cafeterias) {
        final res = await ApiService.get('/api/cafeterias/${c.id}/menu');
        final data = (res['data'] as List<dynamic>).cast<Map<String, dynamic>>();
        allRaw.addAll(data);
        all.addAll(data.map((j) => FoodItem.fromJson(j)));
      }
      await LocalStorageService.saveAllMenuItems(allRaw);
      return all;
    } catch (_) {
      final cached = LocalStorageService.getAllMenuItems();
      if (cached != null) return cached.map((j) => FoodItem.fromJson(j)).toList();
      rethrow;
    }
  }
}
