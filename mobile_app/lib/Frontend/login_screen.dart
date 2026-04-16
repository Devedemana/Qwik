import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/local_auth_service.dart';
import '../services/notification_service.dart';
import '../screens/home_screen.dart';
import '../screens/staff_dashboard_screen.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isBiometricLoading = false;
  String? _errorMessage;
  bool _biometricAvailable = false;
  bool _biometricEnabled = false;

  @override
  void initState() {
    super.initState();
    _checkBiometrics();
  }

  Future<void> _checkBiometrics() async {
    final available = await LocalAuthService.isAvailable();
    final enabled = await LocalAuthService.isEnabled();
    if (mounted) {
      setState(() {
        _biometricAvailable = available;
        _biometricEnabled = enabled;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      setState(() => _errorMessage = 'Please enter your email and password');
      return;
    }

    setState(() { _isLoading = true; _errorMessage = null; });

    try {
      final user = await AuthService.login(email, password);
      if (!mounted) return;

      // After first successful login, offer to enable biometrics
      if (_biometricAvailable && !_biometricEnabled) {
        final enabled = await _offerBiometricSetup();
        if (enabled) {
          await LocalAuthService.saveCredentials(email, password);
          setState(() => _biometricEnabled = true);
        }
      } else if (_biometricEnabled) {
        // Already enabled — refresh saved credentials in case password changed
        await LocalAuthService.saveCredentials(email, password);
      }

      _navigateHome(user.role, user.id);
    } catch (e) {
      if (!mounted) return;
      setState(() { _isLoading = false; _errorMessage = e.toString(); });
    }
  }

  Future<void> _handleBiometricLogin() async {
    setState(() { _isBiometricLoading = true; _errorMessage = null; });
    try {
      final passed = await LocalAuthService.authenticate(
        reason: 'Sign in to Qwik with biometrics',
      );
      if (!mounted) return;
      if (!passed) {
        setState(() { _isBiometricLoading = false; _errorMessage = 'Biometric authentication failed'; });
        return;
      }

      // Use saved credentials to get a fresh token (works even after logout)
      final creds = await LocalAuthService.getCredentials();
      if (!mounted) return;
      if (creds == null) {
        setState(() { _isBiometricLoading = false; _errorMessage = 'No saved credentials. Please log in once with your password.'; });
        return;
      }

      final user = await AuthService.login(creds.email, creds.password);
      if (!mounted) return;
      _navigateHome(user.role, user.id);
    } catch (e) {
      if (!mounted) return;
      setState(() { _isBiometricLoading = false; _errorMessage = e.toString(); });
    }
  }

  Future<bool> _offerBiometricSetup() async {
    final enable = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Enable Biometric Login?'),
        content: const Text('Use fingerprint or face ID to sign in faster next time.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Not now')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Enable')),
        ],
      ),
    );
    if (enable == true) {
      await LocalAuthService.setEnabled(true);
      return true;
    }
    return false;
  }

  void _navigateHome(String role, String userId) {
    context.read<NotificationService>().connectSocket(userId);
    final isStaff = role == 'STAFF' || role == 'ADMIN';
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => isStaff ? const StaffDashboardScreen() : const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5EFE6),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen())),
            child: const Text('Register', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Center(
            child: Text(
              'Qwik',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: const Color(0xFFFFD700),
                shadows: [Shadow(blurRadius: 8, color: Colors.brown.withValues(alpha: 0.5), offset: const Offset(2, 2))],
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Text('Login', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Color(0xFF8B3A10),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  _inputField('Email', controller: _emailController, keyboardType: TextInputType.emailAddress),
                  const SizedBox(height: 16),
                  _inputField('Password', controller: _passwordController, obscure: true),
                  const SizedBox(height: 8),
                  if (_errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(_errorMessage!,
                          style: const TextStyle(color: Color(0xFFFFD700), fontSize: 14),
                          textAlign: TextAlign.center),
                    ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
                      ),
                      child: const Text('Forgot Password?', style: TextStyle(color: Colors.white70)),
                    ),
                  ),
                  const Spacer(),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      minimumSize: const Size(double.infinity, 55),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    onPressed: _isLoading ? null : _handleLogin,
                    child: _isLoading
                        ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('Login', style: TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                  // Biometric button — shown when device supports it and user has enabled it
                  if (_biometricAvailable && _biometricEnabled) ...[
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white54),
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                      onPressed: _isBiometricLoading ? null : _handleBiometricLogin,
                      icon: _isBiometricLoading
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Icon(Icons.fingerprint, size: 22),
                      label: const Text('Use Biometrics'),
                    ),
                  ],
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const HomeScreen(isGuest: true)),
                    ),
                    child: const Text(
                      'Browse as Guest',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _inputField(String hint, {required TextEditingController controller, bool obscure = false, TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: Colors.white24,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
      style: const TextStyle(color: Colors.white),
    );
  }
}
