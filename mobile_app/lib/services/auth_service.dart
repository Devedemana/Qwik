import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const _keyIsLoggedIn = 'is_logged_in';
  static const _keyUsername = 'username';

  // Hardcoded local users — replace with a backend later
  static const Map<String, String> _users = {
    'nessa': 'password123',
    'admin': 'admin123',
  };

  /// Validate credentials and save login state
  static Future<bool> login(String username, String password) async {
    final storedPassword = _users[username.toLowerCase()];
    if (storedPassword != null && storedPassword == password) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyIsLoggedIn, true);
      await prefs.setString(_keyUsername, username);
      return true;
    }
    return false;
  }

  /// Check if user is already logged in
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  /// Get the stored username
  static Future<String> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUsername) ?? '';
  }

  /// Clear login state
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyIsLoggedIn);
    await prefs.remove(_keyUsername);
  }
}
