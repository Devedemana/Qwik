import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../services/auth_service.dart';
import '../services/order_service.dart';
import '../services/api_service.dart';
import '../models/order.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../Frontend/login_screen.dart';
import '../Frontend/oder_tracking.dart';
import 'order_history_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _editProfileExpanded = false;
  bool _ordersExpanded = false;
  bool _paymentDetailsExpanded = false;
  bool _preferencesExpanded = false;

  AppUser? _user;
  List<Order> _orders = [];
  bool _loadingOrders = false;
  bool _savingProfile = false;
  bool _savingPreferences = false;

  late final TextEditingController _nameCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _allergiesCtrl;

  static const _dietaryOptions = [
    'Vegetarian', 'Vegan', 'Pescatarian', 'Halal', 'Gluten-Free', 'Dairy-Free',
  ];
  List<String> _selectedDietary = [];

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController();
    _emailCtrl = TextEditingController();
    _allergiesCtrl = TextEditingController();
    _loadUser();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _allergiesCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadUser() async {
    final user = await AuthService.getCurrentUser();
    // Fetch fresh preferences from server
    try {
      final res = await ApiService.get('/api/user/profile', auth: true);
      final data = res['data'] as Map<String, dynamic>;
      final freshUser = AppUser.fromJson(data);
      await AuthService.updatePreferencesCache(freshUser.dietaryLifestyle, freshUser.allergies);
      if (mounted) {
        setState(() {
          _user = freshUser;
          _nameCtrl.text = freshUser.name;
          _emailCtrl.text = freshUser.email;
          _selectedDietary = List<String>.from(freshUser.dietaryLifestyle);
          _allergiesCtrl.text = freshUser.allergies.join(', ');
        });
      }
      return;
    } catch (_) {}
    if (mounted) {
      setState(() {
        _user = user;
        _nameCtrl.text = user?.name ?? '';
        _emailCtrl.text = user?.email ?? '';
        _selectedDietary = List<String>.from(user?.dietaryLifestyle ?? []);
        _allergiesCtrl.text = (user?.allergies ?? []).join(', ');
      });
    }
  }

  Future<void> _savePreferences() async {
    final allergies = _allergiesCtrl.text
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    setState(() => _savingPreferences = true);
    try {
      await ApiService.patch('/api/user/preferences', {
        'dietaryLifestyle': _selectedDietary,
        'allergies': allergies,
      }, auth: true);
      await AuthService.updatePreferencesCache(_selectedDietary, allergies);
      if (mounted) {
        setState(() => _savingPreferences = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Preferences saved')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _savingPreferences = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e')),
        );
      }
    }
  }

  Future<void> _loadOrders() async {
    if (_loadingOrders) return;
    setState(() => _loadingOrders = true);
    try {
      final orders = await OrderService.getUserOrders();
      if (mounted) setState(() => _orders = orders);
    } catch (e) {
      if (mounted && ApiService.isUnauthorized(e)) {
        setState(() => _orders = []);
      }
    } finally {
      if (mounted) setState(() => _loadingOrders = false);
    }
  }

  Future<void> _saveProfile() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return;
    setState(() => _savingProfile = true);
    try {
      await ApiService.patch('/api/user/profile', {'name': name}, auth: true);
      // Update cached name in SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_name', name);
      if (mounted) {
        setState(() {
          _user = _user != null
              ? AppUser(id: _user!.id, name: name, email: _user!.email, role: _user!.role)
              : null;
          _savingProfile = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _savingProfile = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e')),
        );
      }
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
                  _user?.name ?? 'User',
                  style: const TextStyle(
                    color: AppColors.darkBrown,
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _user?.email ?? '',
                  style: const TextStyle(color: AppColors.subtext, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.rust.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _user?.role ?? '',
                    style: const TextStyle(
                        color: AppColors.rust, fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 36),
                _buildAccordionItem(
                  icon: Icons.edit_outlined,
                  label: 'Edit Profile',
                  isExpanded: _editProfileExpanded,
                  onTap: () => setState(() => _editProfileExpanded = !_editProfileExpanded),
                  content: _editProfileContent(),
                ),
                const SizedBox(height: 14),
                _buildAccordionItem(
                  icon: Icons.receipt_long_outlined,
                  label: 'Order History',
                  isExpanded: _ordersExpanded,
                  onTap: () {
                    setState(() => _ordersExpanded = !_ordersExpanded);
                    if (_ordersExpanded && _orders.isEmpty) _loadOrders();
                  },
                  content: _ordersContent(),
                ),
                const SizedBox(height: 14),
                _buildAccordionItem(
                  icon: Icons.credit_card_outlined,
                  label: 'Payment Details',
                  isExpanded: _paymentDetailsExpanded,
                  onTap: () =>
                      setState(() => _paymentDetailsExpanded = !_paymentDetailsExpanded),
                  content: _paymentContent(),
                ),
                const SizedBox(height: 14),
                _buildAccordionItem(
                  icon: Icons.restaurant_menu_outlined,
                  label: 'Dietary Preferences',
                  isExpanded: _preferencesExpanded,
                  onTap: () =>
                      setState(() => _preferencesExpanded = !_preferencesExpanded),
                  content: _preferencesContent(),
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
            child: Text('Profile',
                style: TextStyle(
                    color: AppColors.darkBrown,
                    fontSize: 18,
                    fontWeight: FontWeight.w600)),
          ),
        ),
        SizedBox(width: 46),
      ],
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 100,
      height: 100,
      decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.rust),
      child: Center(
        child: Text(
          _user != null && _user!.name.isNotEmpty ? _user!.name[0].toUpperCase() : '?',
          style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold),
        ),
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
      decoration:
          BoxDecoration(color: AppColors.rust, borderRadius: BorderRadius.circular(18)),
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
                    child: Text(label,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600)),
                  ),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 280),
                    child: const Icon(Icons.keyboard_arrow_down,
                        color: Colors.white, size: 26),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 280),
            crossFadeState:
                isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
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
        _profileField('Full Name', _nameCtrl),
        const SizedBox(height: 10),
        _profileField('Email', _emailCtrl, enabled: false),
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _savingProfile ? null : _saveProfile,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.rust,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(vertical: 12),
              elevation: 0,
            ),
            child: _savingProfile
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.rust))
                : const Text('Save Changes',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
          ),
        ),
      ],
    );
  }

  Widget _ordersContent() {
    if (_loadingOrders) {
      return const Center(
          child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(color: Colors.white)));
    }
    if (_orders.isEmpty) {
      return const Text('No orders yet', style: TextStyle(color: Colors.white70));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ..._orders.take(3).map((o) {
          return GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => OrderTrackingPage(order: o)),
            ),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(o.cafeteriaName,
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 13)),
                        Text(o.statusDisplay,
                            style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.7), fontSize: 11)),
                      ],
                    ),
                  ),
                  Text('₵${o.totalAmount.toStringAsFixed(2)}',
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w600)),
                  const SizedBox(width: 6),
                  const Icon(Icons.chevron_right, color: Colors.white54, size: 18),
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: 4),
        GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const OrderHistoryScreen()),
          ),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(
              child: Text(
                'View All Orders',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _paymentContent() {
    return const Text(
      'Payment method management coming soon.',
      style: TextStyle(color: Colors.white70, fontSize: 13),
    );
  }

  Widget _preferencesContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Lifestyle', style: TextStyle(color: Colors.white70, fontSize: 12)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: _dietaryOptions.map((option) {
            final selected = _selectedDietary.contains(option);
            return GestureDetector(
              onTap: () => setState(() {
                if (selected) {
                  _selectedDietary.remove(option);
                } else {
                  _selectedDietary.add(option);
                }
              }),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: selected ? Colors.white : Colors.white24,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  option,
                  style: TextStyle(
                    color: selected ? AppColors.rust : Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 14),
        const Text('Allergies (comma-separated)', style: TextStyle(color: Colors.white70, fontSize: 12)),
        const SizedBox(height: 6),
        _profileField('e.g. Nuts, Shellfish, Gluten', _allergiesCtrl),
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _savingPreferences ? null : _savePreferences,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.rust,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(vertical: 12),
              elevation: 0,
            ),
            child: _savingPreferences
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.rust))
                : const Text('Save Preferences', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
          ),
        ),
      ],
    );
  }

  Widget _profileField(String hint, TextEditingController ctrl, {bool enabled = true}) {
    return TextField(
      controller: ctrl,
      enabled: enabled,
      style: TextStyle(color: enabled ? Colors.white : Colors.white54, fontSize: 14),
      decoration: InputDecoration(
        labelText: hint,
        labelStyle:
            TextStyle(color: Colors.white.withValues(alpha: 0.65), fontSize: 13),
        filled: true,
        fillColor: Colors.white.withValues(alpha: enabled ? 0.12 : 0.06),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          padding: const EdgeInsets.symmetric(vertical: 20),
          elevation: 0,
        ),
        child: const Text('Logout',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      ),
    );
  }
}
