import 'package:flutter/material.dart';
import 'storage_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 1. Load the saved theme from disk BEFORE the app starts
  bool savedTheme = await StorageHelper.loadTheme();
  
  runApp(MyApp(isDarkMode: savedTheme));
}

class MyApp extends StatefulWidget {
  final bool isDarkMode;
  const MyApp({super.key, required this.isDarkMode});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // 2. Keep the theme in a local variable
  late bool _isDark;

  @override
  void initState() {
    super.initState();
    _isDark = widget.isDarkMode;
  }

  void _updateTheme(bool value) {
    setState(() {
      _isDark = value;
    });
    // 3. Persist the new choice to local storage
    StorageHelper.saveTheme(value);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      themeMode: _isDark ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      home: Scaffold(
        appBar: AppBar(title: const Text("Local Storage Theme")),
        body: Center(
          child: SwitchListTile(
            title: const Text("Dark Mode"),
            value: _isDark,
            onChanged: _updateTheme,
          ),
        ),
      ),
    );
  }
}