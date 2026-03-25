import 'package:flutter/material.dart';
import 'login_screen.dart';
import '../screens/home_screen.dart';
import '../services/auth_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;

    final loggedIn = await AuthService.isLoggedIn();
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => loggedIn ? const HomeScreen() : const LoginScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF8B3A10),
      body: Center(
        child: Text(
          "Qwik",
          style: TextStyle(
            fontSize: 52,
            fontWeight: FontWeight.bold,
            color: const Color(0xFFFFD700),
            shadows: [
              Shadow(
                blurRadius: 10,
                color: Colors.black.withOpacity(0.3),
                offset: const Offset(2, 2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}