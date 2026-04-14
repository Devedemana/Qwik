import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'login_screen.dart';
import '../screens/home_screen.dart';
import '../screens/staff_dashboard_screen.dart';
import '../services/auth_service.dart';
import '../services/local_auth_service.dart';
import '../services/notification_service.dart';

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
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    final loggedIn = await AuthService.isLoggedIn();
    if (!mounted) return;

    if (!loggedIn) {
      _goTo(const LoginScreen());
      return;
    }

    // Valid token — check if biometrics are enabled
    final biometricEnabled = await LocalAuthService.isEnabled();
    final biometricAvailable = await LocalAuthService.isAvailable();

    if (biometricEnabled && biometricAvailable) {
      final passed = await LocalAuthService.authenticate(
        reason: 'Verify your identity to access Qwik',
      );
      if (!mounted) return;
      if (!passed) {
        // Failed biometrics — go to login for fallback
        _goTo(const LoginScreen());
        return;
      }
    }

    // Auth passed — connect socket and go home
    final user = await AuthService.getCurrentUser();
    if (!mounted) return;

    if (user != null) {
      context.read<NotificationService>().connectSocket(user.id);
    }

    final role = user?.role ?? 'CUSTOMER';
    _goTo((role == 'STAFF' || role == 'ADMIN')
        ? const StaffDashboardScreen()
        : const HomeScreen());
  }

  void _goTo(Widget screen) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF8B3A10),
      body: Center(
        child: Text(
          'Qwik',
          style: TextStyle(
            fontSize: 52,
            fontWeight: FontWeight.bold,
            color: const Color(0xFFFFD700),
            shadows: [
              Shadow(
                blurRadius: 10,
                color: Colors.black.withValues(alpha: 0.3),
                offset: const Offset(2, 2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
