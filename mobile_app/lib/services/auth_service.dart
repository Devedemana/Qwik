import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';
import 'local_auth_service.dart';
import '../models/user.dart';

class AuthService {
  static const _keyToken = 'auth_token';
  static const _keyUserId = 'user_id';
  static const _keyUserName = 'user_name';
  static const _keyUserEmail = 'user_email';
  static const _keyUserRole = 'user_role';
  static const _keyDietary = 'dietary_lifestyle';
  static const _keyAllergies = 'allergies';

  static Future<AppUser> login(String email, String password) async {
    final res = await ApiService.post('/api/auth/login', {
      'email': email,
      'password': password,
    });
    final data = res['data'] as Map<String, dynamic>;
    final user = AppUser.fromJson(data['user'] as Map<String, dynamic>);
    final token = data['token'] as String;

    await _saveSession(user, token);
    // Save credentials so biometric login can re-authenticate after logout
    if (await LocalAuthService.isEnabled()) {
      await LocalAuthService.saveCredentials(email, password);
    }
    return user;
  }

  static Future<AppUser> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final res = await ApiService.post('/api/auth/register', {
      'name': name,
      'email': email,
      'password': password,
    });
    final data = res['data'] as Map<String, dynamic>;
    final user = AppUser.fromJson(data['user'] as Map<String, dynamic>);
    final token = data['token'] as String;

    await _saveSession(user, token);
    return user;
  }

  static Future<void> _saveSession(AppUser user, String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyToken, token);
    await prefs.setString(_keyUserId, user.id);
    await prefs.setString(_keyUserName, user.name);
    await prefs.setString(_keyUserEmail, user.email);
    await prefs.setString(_keyUserRole, user.role);
    await prefs.setStringList(_keyDietary, user.dietaryLifestyle);
    await prefs.setStringList(_keyAllergies, user.allergies);
    await ApiService.saveToken(token);
  }

  static Future<void> updatePreferencesCache(List<String> dietary, List<String> allergies) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_keyDietary, dietary);
    await prefs.setStringList(_keyAllergies, allergies);
  }

  static Future<bool> isLoggedIn() async {
    final token = await ApiService.getToken();
    if (token == null) return false;
    // Verify token is still valid against the server
    try {
      await ApiService.get('/api/user/profile', auth: true);
      return true;
    } catch (e) {
      // Only clear token on 401 (expired/invalid) — not on network errors
      if (ApiService.isUnauthorized(e)) {
        await ApiService.clearToken();
      }
      return false;
    }
  }

  static Future<AppUser?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString(_keyUserId);
    if (id == null) return null;
    return AppUser(
      id: id,
      name: prefs.getString(_keyUserName) ?? '',
      email: prefs.getString(_keyUserEmail) ?? '',
      role: prefs.getString(_keyUserRole) ?? 'CUSTOMER',
      dietaryLifestyle: prefs.getStringList(_keyDietary) ?? [],
      allergies: prefs.getStringList(_keyAllergies) ?? [],
    );
  }

  static Future<String> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserName) ?? '';
  }

  static Future<String> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserEmail) ?? '';
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyToken);
    await prefs.remove(_keyUserId);
    await prefs.remove(_keyUserName);
    await prefs.remove(_keyUserEmail);
    await prefs.remove(_keyUserRole);
    await prefs.remove(_keyDietary);
    await prefs.remove(_keyAllergies);
    await ApiService.clearToken();
    // biometric_enabled and secure credentials are intentionally kept
    // so the user can log back in with biometrics without re-entering their password
  }
}
