import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../screens/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      setState(() => _errorMessage = 'Please enter username and password');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final success = await AuthService.login(username, password);

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else {
      setState(() => _errorMessage = 'Invalid username or password');
    }
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
            onPressed: () {},
            child: const Text("Register", style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Center(
            child: Text(
              "Qwik",
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: const Color(0xFFFFD700),
                shadows: [
                  Shadow(
                    blurRadius: 8,
                    color: Colors.brown.withValues(alpha: 0.5),
                    offset: const Offset(2, 2),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Text("Login", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
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
                  _inputField("UserName", controller: _usernameController),
                  const SizedBox(height: 16),
                  _inputField("Password", controller: _passwordController, obscure: true),
                  const SizedBox(height: 8),
                  if (_errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: Color(0xFFFFD700), fontSize: 14),
                      ),
                    ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {},
                      child: const Text("Forgot Password?",
                          style: TextStyle(color: Colors.white70)),
                    ),
                  ),
                  const Text("Or login with",
                      style: TextStyle(color: Colors.white70)),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _socialButton("G", const Color(0xFFFFD700)),
                      const SizedBox(width: 16),
                      _socialButton("", const Color(0xFFFFD700),
                          icon: Icons.apple),
                    ],
                  ),
                  const Spacer(),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      minimumSize: const Size(double.infinity, 55),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: _isLoading ? null : _handleLogin,
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text("Login",
                            style: TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _inputField(String hint, {
    required TextEditingController controller,
    bool obscure = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: Colors.white24,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
      style: const TextStyle(color: Colors.white),
    );
  }

  Widget _socialButton(String label, Color color, {IconData? icon}) {
    return CircleAvatar(
      backgroundColor: color,
      radius: 22,
      child: icon != null
          ? Icon(icon, color: Colors.white)
          : Text(label,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.white)),
    );
  }
}
