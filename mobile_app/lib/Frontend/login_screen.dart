import 'package:flutter/material.dart';
import 'success_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

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
                    color: Colors.brown.withOpacity(0.5),
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
                  _inputField("UserName"),
                  const SizedBox(height: 16),
                  _inputField("Password", obscure: true),
                  const SizedBox(height: 8),
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
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const SuccessScreen()),
                      );
                    },
                    child: const Text("Login",
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

  Widget _inputField(String hint, {bool obscure = false}) {
    return TextField(
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