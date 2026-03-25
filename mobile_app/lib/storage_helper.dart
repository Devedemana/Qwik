import 'package:shared_preferences/shared_preferences.dart';

class StorageHelper {
  static const String _themeKey = "isDarkMode";

  // Save the theme preference
  static Future<void> saveTheme(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, isDark);
  }

  // Load the theme preference (defaults to false if not found)
  static Future<bool> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_themeKey) ?? false;
  }
}