import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // 10.0.2.2 = Android emulator → host localhost
  // localhost = Windows desktop / web / physical device on same network
  static const String baseUrl = 'https://qwik-production-1b55.up.railway.app';

  static const _keyToken = 'auth_token';

  // ── Token management ──────────────────────────────────────────────────────

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyToken);
  }

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyToken, token);
  }

  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyToken);
  }

  // ── HTTP helpers ──────────────────────────────────────────────────────────

  static Future<Map<String, String>> _headers({bool auth = false}) async {
    final headers = {'Content-Type': 'application/json'};
    if (auth) {
      final token = await getToken();
      if (token != null) headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  static Future<Map<String, dynamic>> _parseResponse(http.Response response) async {
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    }
    if (response.statusCode == 401) {
      // Token expired or invalid — clear it so future checks skip the request
      await clearToken();
    }
    throw ApiException(
      body['error'] as String? ?? 'Request failed',
      response.statusCode,
    );
  }

  /// Returns true if an unauthenticated request should trigger logout.
  static bool isUnauthorized(Object e) =>
      e is ApiException && e.statusCode == 401;

  // ── Public methods ────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> get(String path, {bool auth = false}) async {
    final response = await http.get(
      Uri.parse('$baseUrl$path'),
      headers: await _headers(auth: auth),
    );
    return await _parseResponse(response);
  }

  static Future<Map<String, dynamic>> post(
    String path,
    Map<String, dynamic> body, {
    bool auth = false,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl$path'),
      headers: await _headers(auth: auth),
      body: jsonEncode(body),
    );
    return await _parseResponse(response);
  }

  static Future<Map<String, dynamic>> put(
    String path,
    Map<String, dynamic> body, {
    bool auth = false,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl$path'),
      headers: await _headers(auth: auth),
      body: jsonEncode(body),
    );
    return await _parseResponse(response);
  }

  static Future<Map<String, dynamic>> patch(
    String path,
    Map<String, dynamic> body, {
    bool auth = false,
  }) async {
    final response = await http.patch(
      Uri.parse('$baseUrl$path'),
      headers: await _headers(auth: auth),
      body: jsonEncode(body),
    );
    return await _parseResponse(response);
  }

  static Future<Map<String, dynamic>> delete(
    String path, {
    bool auth = false,
  }) async {
    final response = await http.delete(
      Uri.parse('$baseUrl$path'),
      headers: await _headers(auth: auth),
    );
    return await _parseResponse(response);
  }
}

class ApiException implements Exception {
  final String message;
  final int statusCode;
  ApiException(this.message, this.statusCode);

  @override
  String toString() => message;
}
