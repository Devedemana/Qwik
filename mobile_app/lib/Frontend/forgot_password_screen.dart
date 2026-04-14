import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailCtrl = TextEditingController();
  final _otpCtrl = TextEditingController();
  final _newPassCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();

  bool _loading = false;
  bool _codeSent = false;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _otpCtrl.dispose();
    _newPassCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendCode() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty) {
      setState(() => _error = 'Please enter your email');
      return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      await ApiService.post('/api/auth/forgot-password', {'email': email}, auth: false);
      if (mounted) setState(() { _codeSent = true; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  Future<void> _resetPassword() async {
    final otp = _otpCtrl.text.trim();
    final newPass = _newPassCtrl.text;
    final confirm = _confirmPassCtrl.text;

    if (otp.isEmpty || newPass.isEmpty) {
      setState(() => _error = 'Please fill in all fields');
      return;
    }
    if (newPass != confirm) {
      setState(() => _error = 'Passwords do not match');
      return;
    }
    if (newPass.length < 6) {
      setState(() => _error = 'Password must be at least 6 characters');
      return;
    }

    setState(() { _loading = true; _error = null; });
    try {
      await ApiService.post('/api/auth/reset-password', {
        'email': _emailCtrl.text.trim(),
        'otp': otp,
        'newPassword': newPass,
      }, auth: false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password updated! Please log in.'), backgroundColor: Colors.green),
      );
      Navigator.pop(context);
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5EFE6),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Forgot Password', style: TextStyle(color: Colors.black)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Text(
              _codeSent
                  ? 'Enter the 6-digit code sent to ${_emailCtrl.text.trim()}'
                  : 'Enter your email and we\'ll send you a reset code.',
              style: const TextStyle(color: Colors.black87, fontSize: 15),
            ),
            const SizedBox(height: 24),
            _field('Email', _emailCtrl,
                enabled: !_codeSent,
                keyboardType: TextInputType.emailAddress),
            if (_codeSent) ...[
              const SizedBox(height: 16),
              _field('6-digit code', _otpCtrl, keyboardType: TextInputType.number),
              const SizedBox(height: 16),
              _field('New password', _newPassCtrl, obscure: true),
              const SizedBox(height: 16),
              _field('Confirm password', _confirmPassCtrl, obscure: true),
            ],
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 13)),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B3A10),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                onPressed: _loading ? null : (_codeSent ? _resetPassword : _sendCode),
                child: _loading
                    ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text(_codeSent ? 'Reset Password' : 'Send Code',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
            if (_codeSent) ...[
              const SizedBox(height: 12),
              Center(
                child: TextButton(
                  onPressed: _loading ? null : () => setState(() { _codeSent = false; _error = null; }),
                  child: const Text('Change email / resend', style: TextStyle(color: Color(0xFF8B3A10))),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _field(String label, TextEditingController ctrl,
      {bool obscure = false, bool enabled = true, TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      controller: ctrl,
      obscureText: obscure,
      enabled: enabled,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}
