import 'api_service.dart';
import '../models/special.dart';

class SpecialService {
  static Future<List<Special>> getActiveSpecials() async {
    final res = await ApiService.get('/api/specials', auth: true);
    final data = res['data'] as List<dynamic>;
    return data.map((j) => Special.fromJson(j as Map<String, dynamic>)).toList();
  }

  static Future<List<Special>> getAllSpecials() async {
    final res = await ApiService.get('/api/specials/all', auth: true);
    final data = res['data'] as List<dynamic>;
    return data.map((j) => Special.fromJson(j as Map<String, dynamic>)).toList();
  }

  static Future<Special> createSpecial({
    required String tag,
    required String title,
    required String subtitle,
    required String imageUrl,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final res = await ApiService.post('/api/specials', {
      'tag': tag,
      'title': title,
      'subtitle': subtitle,
      'imageUrl': imageUrl,
      'startDate': startDate.toUtc().toIso8601String(),
      'endDate': endDate.toUtc().toIso8601String(),
    }, auth: true);
    return Special.fromJson(res['data'] as Map<String, dynamic>);
  }

  static Future<void> updateSpecial(String id, Map<String, dynamic> fields) async {
    await ApiService.patch('/api/specials/$id', fields, auth: true);
  }

  static Future<void> deleteSpecial(String id) async {
    await ApiService.delete('/api/specials/$id', auth: true);
  }
}
