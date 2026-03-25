import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../services/auth_service.dart';
import '../Frontend/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _editProfileExpanded = false;
  bool _invoicesExpanded = false;
  bool _paymentDetailsExpanded = false;

  String _username = '';

  @override
  void initState() {
    super.initState();
    _loadUsername();
  }

  Future<void> _loadUsername() async {
    final name = await AuthService.getUsername();
    if (mounted) {
      setState(() => _username = name);
    }
  }

  Future<void> _handleLogout() async {
    await AuthService.logout();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildTopBar(),
                const SizedBox(height: 28),
                _buildAvatar(),
                const SizedBox(height: 20),
                Text(
                  _username.isNotEmpty ? _username : 'User',
                  style: const TextStyle(
                    color: AppColors.darkBrown,
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Student',
                  style: TextStyle(
                    color: AppColors.subtext,
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 36),
                _buildAccordionItem(
                  icon: Icons.edit_outlined,
                  label: 'Edit Profile',
                  isExpanded: _editProfileExpanded,
                  onTap: () => setState(
                      () => _editProfileExpanded = !_editProfileExpanded),
                  content: _editProfileContent(),
                ),
                const SizedBox(height: 14),
                _buildAccordionItem(
                  icon: Icons.receipt_long_outlined,
                  label: 'Invoices',
                  isExpanded: _invoicesExpanded,
                  onTap: () =>
                      setState(() => _invoicesExpanded = !_invoicesExpanded),
                  content: _invoicesContent(),
                ),
                const SizedBox(height: 14),
                _buildAccordionItem(
                  icon: Icons.credit_card_outlined,
                  label: 'Payment Details',
                  isExpanded: _paymentDetailsExpanded,
                  onTap: () => setState(
                      () => _paymentDetailsExpanded = !_paymentDetailsExpanded),
                  content: _paymentContent(),
                ),
                const SizedBox(height: 28),
                _buildLogoutButton(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return const Row(
      children: [
        SizedBox(width: 46),
        Expanded(
          child: Center(
            child: Text(
              'Profile',
              style: TextStyle(
                color: AppColors.darkBrown,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        SizedBox(width: 46),
      ],
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 180,
      height: 180,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.background,
      ),
      clipBehavior: Clip.hardEdge,
      child: const Icon(
        Icons.person,
        size: 80,
        color: AppColors.subtext,
      ),
    );
  }

  Widget _buildAccordionItem({
    required IconData icon,
    required String label,
    required bool isExpanded,
    required VoidCallback onTap,
    required Widget content,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: AppColors.rust,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: onTap,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 280),
                    child: const Icon(
                      Icons.keyboard_arrow_down,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 280),
            crossFadeState: isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: const SizedBox(width: double.infinity),
            secondChild: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: content,
            ),
          ),
        ],
      ),
    );
  }

  Widget _editProfileContent() {
    return Column(
      children: [
        _profileField('Full Name', _username),
        const SizedBox(height: 10),
        _profileField('Email', ''),
        const SizedBox(height: 10),
        _profileField('Phone', ''),
        const SizedBox(height: 14),
        _saveButton('Save Changes'),
      ],
    );
  }

  Widget _invoicesContent() {
    return Column(
      children: [
        _invoiceRow('INV-001', 'Mar 10, 2026', '\$320.00'),
        _divider(),
        _invoiceRow('INV-002', 'Feb 18, 2026', '\$540.00'),
        _divider(),
        _invoiceRow('INV-003', 'Jan 05, 2026', '\$210.00'),
      ],
    );
  }

  Widget _paymentContent() {
    return Column(
      children: [
        _profileField('Card Number', '**** **** **** 4242'),
        const SizedBox(height: 10),
        _profileField('Expiry', '08 / 28'),
        const SizedBox(height: 14),
        _saveButton('Update Payment'),
      ],
    );
  }

  Widget _profileField(String hint, String value) {
    return TextField(
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        labelText: hint,
        labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.65), fontSize: 13),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
      controller: TextEditingController(text: value),
    );
  }

  Widget _invoiceRow(String id, String date, String amount) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(id,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w600)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(date,
                style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 13)),
          ),
          Text(amount,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _divider() => Divider(color: Colors.white.withValues(alpha: 0.2), height: 1);

  Widget _saveButton(String label) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: AppColors.rust,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 12),
          elevation: 0,
        ),
        child: Text(label,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _handleLogout,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.darkBrown,
          foregroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          padding: const EdgeInsets.symmetric(vertical: 20),
          elevation: 0,
          side: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: const Text(
          'Logout',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.4,
          ),
        ),
      ),
    );
  }
}
