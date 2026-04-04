import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../models/order.dart';
import '../models/cafeteria.dart';
import '../models/food_item.dart';
import '../models/special.dart';
import '../services/merchant_service.dart';
import '../services/cafeteria_service.dart';
import '../services/auth_service.dart';
import '../services/special_service.dart';
import '../Frontend/login_screen.dart';

class StaffDashboardScreen extends StatefulWidget {
  const StaffDashboardScreen({super.key});

  @override
  State<StaffDashboardScreen> createState() => _StaffDashboardScreenState();
}

class _StaffDashboardScreenState extends State<StaffDashboardScreen>
    with SingleTickerProviderStateMixin {
  TabController? _tabs;

  List<Cafeteria> _cafeterias = [];
  Cafeteria? _selected;
  List<Order> _queue = [];
  bool _loadingCafeterias = true;
  bool _loadingQueue = false;
  String _capacityStatus = 'GREEN';
  String _role = 'STAFF';

  bool get _isAdmin => _role == 'ADMIN';

  @override
  void initState() {
    super.initState();
    _loadRole();
  }

  Future<void> _loadRole() async {
    final user = await AuthService.getCurrentUser();
    final role = user?.role ?? 'STAFF';
    if (mounted) {
      setState(() {
        _role = role;
        _tabs = TabController(length: _isAdmin ? 4 : 2, vsync: this);
      });
    }
    _loadCafeterias();
  }

  @override
  void dispose() {
    _tabs?.dispose();
    super.dispose();
  }

  Future<void> _loadCafeterias() async {
    try {
      final list = await CafeteriaService.listCafeterias();
      if (mounted) {
        setState(() {
          _cafeterias = list;
          _loadingCafeterias = false;
          if (list.isNotEmpty) {
            _selected = list.first;
            _capacityStatus = list.first.capacityStatus;
          }
        });
        if (_selected != null) _loadQueue();
      }
    } catch (_) {
      if (mounted) setState(() => _loadingCafeterias = false);
    }
  }

  Future<void> _loadQueue() async {
    if (_selected == null) return;
    setState(() => _loadingQueue = true);
    try {
      final orders = await MerchantService.getQueue(_selected!.id);
      if (mounted) setState(() => _queue = orders);
    } catch (_) {
    } finally {
      if (mounted) setState(() => _loadingQueue = false);
    }
  }

  Future<void> _advanceOrder(Order order) async {
    final next = _nextStatus(order.status);
    if (next == null) return;
    try {
      await MerchantService.advanceOrder(order.id, next);
      await _loadQueue();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e')),
        );
      }
    }
  }

  Future<void> _setCapacity(String status) async {
    if (_selected == null) return;
    try {
      await MerchantService.updateCapacityStatus(_selected!.id, status);
      if (mounted) setState(() => _capacityStatus = status);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e')),
        );
      }
    }
  }

  String? _nextStatus(String current) {
    switch (current) {
      case 'RECEIVED':
        return 'PREPPING';
      case 'PREPPING':
        return 'READY';
      case 'READY':
        return 'COMPLETED';
      default:
        return null;
    }
  }

  String _nextLabel(String current) {
    switch (current) {
      case 'RECEIVED':
        return 'Start Prepping';
      case 'PREPPING':
        return 'Mark Ready';
      case 'READY':
        return 'Complete';
      default:
        return '';
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'RECEIVED':
        return Colors.blue;
      case 'PREPPING':
        return Colors.amber.shade700;
      case 'READY':
        return Colors.green;
      case 'COMPLETED':
        return Colors.green.shade800;
      case 'CANCELLED':
        return Colors.red;
      default:
        return AppColors.subtext;
    }
  }

  Color _capacityColor(String s) {
    switch (s) {
      case 'GREEN':
        return Colors.green;
      case 'YELLOW':
        return Colors.orange;
      case 'RED':
        return Colors.red;
      default:
        return AppColors.subtext;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.rust,
        foregroundColor: Colors.white,
        title: const Text('Staff Dashboard',
            style: TextStyle(fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadQueue,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final nav = Navigator.of(context);
              await AuthService.logout();
              nav.pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (r) => false,
              );
            },
          ),
        ],
        bottom: _tabs == null
            ? null
            : TabBar(
                controller: _tabs,
                indicatorColor: Colors.white,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white60,
                tabs: [
                  const Tab(icon: Icon(Icons.list_alt), text: 'Order Queue'),
                  const Tab(icon: Icon(Icons.storefront), text: 'My Cafeteria'),
                  if (_isAdmin)
                    const Tab(icon: Icon(Icons.edit_note), text: 'Menu Admin'),
                  if (_isAdmin)
                    const Tab(icon: Icon(Icons.local_offer_outlined), text: 'Specials'),
                ],
              ),
      ),
      body: _tabs == null || _loadingCafeterias
          ? const Center(child: CircularProgressIndicator())
          : _cafeterias.isEmpty
              ? const Center(child: Text('No cafeterias assigned'))
              : TabBarView(
                  controller: _tabs,
                  children: [
                    _buildQueueTab(),
                    _buildCafeteriaTab(),
                    if (_isAdmin) _buildAdminMenuTab(),
                    if (_isAdmin) const _SpecialsAdminTab(),
                  ],
                ),
    );
  }

  Widget _buildQueueTab() {
    return Column(
      children: [
        // Cafeteria selector
        if (_cafeterias.length > 1)
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: DropdownButtonFormField<Cafeteria>(
              value: _selected,
              decoration: InputDecoration(
                labelText: 'Cafeteria',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10)),
                isDense: true,
              ),
              items: _cafeterias
                  .map((c) =>
                      DropdownMenuItem(value: c, child: Text(c.name)))
                  .toList(),
              onChanged: (c) {
                setState(() => _selected = c);
                _loadQueue();
              },
            ),
          ),
        // Queue count header
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Row(
            children: [
              Text(
                '${_queue.length} active order${_queue.length == 1 ? '' : 's'}',
                style: const TextStyle(
                    color: AppColors.darkBrown,
                    fontWeight: FontWeight.w600,
                    fontSize: 15),
              ),
              const Spacer(),
              if (_loadingQueue)
                const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2)),
            ],
          ),
        ),
        Expanded(
          child: _queue.isEmpty && !_loadingQueue
              ? const Center(
                  child: Text('No active orders',
                      style: TextStyle(color: AppColors.subtext)))
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  itemCount: _queue.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: 12),
                  itemBuilder: (_, i) => _OrderQueueCard(
                    order: _queue[i],
                    onAdvance: () => _advanceOrder(_queue[i]),
                    nextLabel: _nextLabel(_queue[i].status),
                    statusColor: _statusColor(_queue[i].status),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildCafeteriaTab() {
    if (_selected == null) {
      return const Center(child: Text('No cafeteria selected'));
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cafeteria info card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppColors.rust.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.storefront,
                      color: AppColors.rust, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_selected!.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              color: AppColors.darkBrown)),
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: _capacityColor(_capacityStatus),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(_capacityStatus,
                              style: TextStyle(
                                  color: _capacityColor(_capacityStatus),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text('Capacity Status',
              style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: AppColors.darkBrown)),
          const SizedBox(height: 10),
          Row(
            children: ['GREEN', 'YELLOW', 'RED'].map((s) {
              final selected = _capacityStatus == s;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: GestureDetector(
                    onTap: () => _setCapacity(s),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: selected
                            ? _capacityColor(s)
                            : _capacityColor(s).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: selected
                            ? Border.all(
                                color: _capacityColor(s), width: 2)
                            : null,
                      ),
                      child: Center(
                        child: Text(
                          s,
                          style: TextStyle(
                            color: selected
                                ? Colors.white
                                : _capacityColor(s),
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 28),
          _MenuManagementSection(cafeteriaId: _selected!.id),
        ],
      ),
    );
  }

  Widget _buildAdminMenuTab() {
    if (_selected == null) {
      return const Center(child: Text('No cafeteria selected'));
    }
    return _AdminMenuTab(cafeteriaId: _selected!.id);
  }
}

// ── Admin Menu Tab ────────────────────────────────────────────────────────────

class _AdminMenuTab extends StatefulWidget {
  final String cafeteriaId;
  const _AdminMenuTab({required this.cafeteriaId});

  @override
  State<_AdminMenuTab> createState() => _AdminMenuTabState();
}

class _AdminMenuTabState extends State<_AdminMenuTab> {
  List<FoodItem> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final items = await CafeteriaService.getMenu(widget.cafeteriaId);
      if (mounted) setState(() { _items = items; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _delete(FoodItem item) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Item'),
        content: Text('Remove "${item.name}" from the menu?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      await MerchantService.deleteMenuItem(item.id);
      await _load();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
    }
  }

  void _showItemForm({FoodItem? item}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _MenuItemForm(
        cafeteriaId: widget.cafeteriaId,
        existing: item,
        onSaved: _load,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.rust,
        foregroundColor: Colors.white,
        onPressed: () => _showItemForm(),
        icon: const Icon(Icons.add),
        label: const Text('Add Item'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
              ? const Center(child: Text('No menu items yet', style: TextStyle(color: AppColors.subtext)))
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                  itemCount: _items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, i) {
                    final item = _items[i];
                    return Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.name,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14,
                                        color: AppColors.darkBrown)),
                                const SizedBox(height: 2),
                                Text('₵${item.price.toStringAsFixed(2)}  •  ${item.category}',
                                    style: const TextStyle(color: AppColors.subtext, fontSize: 12)),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, color: AppColors.rust),
                            onPressed: () => _showItemForm(item: item),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.red),
                            onPressed: () => _delete(item),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}

// ── Menu Item Form (add / edit) ───────────────────────────────────────────────

class _MenuItemForm extends StatefulWidget {
  final String cafeteriaId;
  final FoodItem? existing;
  final VoidCallback onSaved;

  const _MenuItemForm({
    required this.cafeteriaId,
    this.existing,
    required this.onSaved,
  });

  @override
  State<_MenuItemForm> createState() => _MenuItemFormState();
}

class _MenuItemFormState extends State<_MenuItemForm> {
  final _nameCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _categoryCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _imageCtrl = TextEditingController();
  final _allergensCtrl = TextEditingController();
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    if (e != null) {
      _nameCtrl.text = e.name;
      _priceCtrl.text = e.price.toString();
      _categoryCtrl.text = e.category;
      _descCtrl.text = e.description;
      _imageCtrl.text = e.imageUrl;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose(); _priceCtrl.dispose(); _categoryCtrl.dispose();
    _descCtrl.dispose(); _imageCtrl.dispose(); _allergensCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    final priceText = _priceCtrl.text.trim();
    final category = _categoryCtrl.text.trim();
    if (name.isEmpty || priceText.isEmpty || category.isEmpty) {
      setState(() => _error = 'Name, price, and category are required');
      return;
    }
    final price = double.tryParse(priceText);
    if (price == null || price <= 0) {
      setState(() => _error = 'Enter a valid price');
      return;
    }
    final allergens = _allergensCtrl.text.trim().isEmpty
        ? <String>[]
        : _allergensCtrl.text.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();

    setState(() { _saving = true; _error = null; });
    try {
      if (widget.existing == null) {
        await MerchantService.addMenuItem(
          cafeteriaId: widget.cafeteriaId,
          name: name,
          price: price,
          category: category,
          description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
          allergenTags: allergens,
          imageUrl: _imageCtrl.text.trim().isEmpty ? null : _imageCtrl.text.trim(),
        );
      } else {
        await MerchantService.updateMenuItem(widget.existing!.id, {
          'name': name,
          'price': price,
          'category': category,
          if (_descCtrl.text.trim().isNotEmpty) 'description': _descCtrl.text.trim(),
          'allergenTags': allergens,
          if (_imageCtrl.text.trim().isNotEmpty) 'imageUrl': _imageCtrl.text.trim(),
        });
      }
      if (mounted) {
        Navigator.pop(context);
        widget.onSaved();
      }
    } catch (e) {
      if (mounted) setState(() { _saving = false; _error = e.toString(); });
    }
  }

  Widget _field(String label, TextEditingController ctrl,
      {TextInputType type = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: ctrl,
        keyboardType: type,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          isDense: true,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(isEdit ? 'Edit Menu Item' : 'Add Menu Item',
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.darkBrown)),
            const SizedBox(height: 16),
            _field('Name *', _nameCtrl),
            _field('Price (₵) *', _priceCtrl, type: TextInputType.numberWithOptions(decimal: true)),
            _field('Category *', _categoryCtrl),
            _field('Description', _descCtrl),
            _field('Allergens (comma-separated)', _allergensCtrl),
            _field('Image URL', _imageCtrl, type: TextInputType.url),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 13)),
              ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.rust,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text(isEdit ? 'Save Changes' : 'Add Item'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Order Queue Card ──────────────────────────────────────────────────────────

class _OrderQueueCard extends StatelessWidget {
  final Order order;
  final VoidCallback onAdvance;
  final String nextLabel;
  final Color statusColor;

  const _OrderQueueCard({
    required this.order,
    required this.onAdvance,
    required this.nextLabel,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order #${order.id.substring(0, 8).toUpperCase()}',
                      style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: AppColors.darkBrown),
                    ),
                    Text(
                      '${order.items.length} item${order.items.length == 1 ? '' : 's'}  •  ₵${order.totalAmount.toStringAsFixed(2)}',
                      style: const TextStyle(
                          color: AppColors.subtext, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  order.statusDisplay,
                  style: TextStyle(
                      color: statusColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Items list
          ...order.items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  const Icon(Icons.circle,
                      size: 6, color: AppColors.subtext),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text('${item.quantity}× ${item.name}',
                        style: const TextStyle(
                            fontSize: 13, color: AppColors.darkBrown)),
                  ),
                  Text('₵${(item.price * item.quantity).toStringAsFixed(2)}',
                      style: const TextStyle(
                          fontSize: 13, color: AppColors.subtext)),
                ],
              ),
            ),
          ),
          if (nextLabel.isNotEmpty) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onAdvance,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.rust,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  elevation: 0,
                ),
                child: Text(nextLabel,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Menu Management Section ───────────────────────────────────────────────────

class _MenuManagementSection extends StatefulWidget {
  final String cafeteriaId;
  const _MenuManagementSection({required this.cafeteriaId});

  @override
  State<_MenuManagementSection> createState() =>
      _MenuManagementSectionState();
}

class _MenuManagementSectionState extends State<_MenuManagementSection> {
  List<FoodItem> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final menu = await CafeteriaService.getMenu(widget.cafeteriaId);
      if (mounted) setState(() { _items = menu; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _toggle(FoodItem item) async {
    final newVal = !item.isAvailable;
    try {
      await MerchantService.toggleInventory(item.id, newVal);
      await _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Menu Inventory',
            style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 15,
                color: AppColors.darkBrown)),
        const SizedBox(height: 10),
        if (_loading)
          const Center(child: CircularProgressIndicator())
        else if (_items.isEmpty)
          const Text('No menu items',
              style: TextStyle(color: AppColors.subtext))
        else
          ..._items.map((item) => _MenuItemRow(
                name: item.name,
                price: item.price,
                available: item.isAvailable,
                onToggle: () => _toggle(item),
              )),
      ],
    );
  }
}

class _MenuItemRow extends StatelessWidget {
  final String name;
  final double price;
  final bool available;
  final VoidCallback onToggle;
  const _MenuItemRow({
    required this.name,
    required this.price,
    required this.available,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: available
                            ? AppColors.darkBrown
                            : AppColors.subtext)),
                Text('₵${price.toStringAsFixed(2)}',
                    style: const TextStyle(
                        color: AppColors.subtext, fontSize: 12)),
              ],
            ),
          ),
          Switch(
            value: available,
            activeColor: AppColors.rust,
            onChanged: (_) => onToggle(),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Specials Admin Tab
// ─────────────────────────────────────────────────────────────────────────────

class _SpecialsAdminTab extends StatefulWidget {
  const _SpecialsAdminTab();

  @override
  State<_SpecialsAdminTab> createState() => _SpecialsAdminTabState();
}

class _SpecialsAdminTabState extends State<_SpecialsAdminTab> {
  List<Special> _specials = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final list = await SpecialService.getAllSpecials();
      if (mounted) setState(() { _specials = list; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _delete(String id) async {
    await SpecialService.deleteSpecial(id);
    _load();
  }

  void _openForm([Special? special]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _SpecialForm(
        existing: special,
        onSaved: _load,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.rust,
        onPressed: () => _openForm(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _specials.isEmpty
              ? const Center(child: Text('No specials yet. Tap + to add one.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _specials.length,
                  itemBuilder: (_, i) {
                    final s = _specials[i];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: s.imageAsset.isNotEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(s.imageAsset, width: 48, height: 48, fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported)),
                              )
                            : const Icon(Icons.local_offer, color: AppColors.rust),
                        title: Text(s.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text('${s.tag}\n${s.period}',
                            style: const TextStyle(fontSize: 11, color: AppColors.subtext)),
                        isThreeLine: true,
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: s.isActive ? Colors.green.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(s.isActive ? 'Active' : 'Inactive',
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: s.isActive ? Colors.green : Colors.grey,
                                      fontWeight: FontWeight.w600)),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit_outlined, size: 20),
                              onPressed: () => _openForm(s),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, size: 20, color: Colors.red),
                              onPressed: () async {
                                final ok = await showDialog<bool>(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: const Text('Delete Special'),
                                    content: Text('Delete "${s.title}"?'),
                                    actions: [
                                      TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                        onPressed: () => Navigator.pop(ctx, true),
                                        child: const Text('Delete', style: TextStyle(color: Colors.white)),
                                      ),
                                    ],
                                  ),
                                );
                                if (ok == true) _delete(s.id);
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

class _SpecialForm extends StatefulWidget {
  final Special? existing;
  final VoidCallback onSaved;
  const _SpecialForm({this.existing, required this.onSaved});

  @override
  State<_SpecialForm> createState() => _SpecialFormState();
}

class _SpecialFormState extends State<_SpecialForm> {
  late final TextEditingController _tag;
  late final TextEditingController _title;
  late final TextEditingController _subtitle;
  late final TextEditingController _imageUrl;
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 14));
  bool _isActive = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _tag = TextEditingController(text: e?.tag ?? '');
    _title = TextEditingController(text: e?.title ?? '');
    _subtitle = TextEditingController(text: e?.subtitle ?? '');
    _imageUrl = TextEditingController(text: e?.imageAsset ?? '');
    if (e != null) {
      _startDate = e.startDate;
      _endDate = e.endDate;
      _isActive = e.isActive;
    }
  }

  @override
  void dispose() {
    _tag.dispose(); _title.dispose(); _subtitle.dispose(); _imageUrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate(bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : _endDate,
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
    );
    if (picked != null) setState(() => isStart ? _startDate = picked : _endDate = picked);
  }

  Future<void> _save() async {
    if (_title.text.trim().isEmpty || _tag.text.trim().isEmpty) return;
    setState(() => _saving = true);
    try {
      if (widget.existing == null) {
        await SpecialService.createSpecial(
          tag: _tag.text.trim(),
          title: _title.text.trim(),
          subtitle: _subtitle.text.trim(),
          imageUrl: _imageUrl.text.trim(),
          startDate: _startDate,
          endDate: _endDate,
        );
      } else {
        await SpecialService.updateSpecial(widget.existing!.id, {
          'tag': _tag.text.trim(),
          'title': _title.text.trim(),
          'subtitle': _subtitle.text.trim(),
          'imageUrl': _imageUrl.text.trim(),
          'startDate': _startDate.toUtc().toIso8601String(),
          'endDate': _endDate.toUtc().toIso8601String(),
          'isActive': _isActive,
        });
      }
      widget.onSaved();
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(isEdit ? 'Edit Special' : 'New Special',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.darkBrown)),
            const SizedBox(height: 16),
            _field('Tag (e.g. #eatwelleveryday)', _tag),
            const SizedBox(height: 10),
            _field('Title', _title),
            const SizedBox(height: 10),
            _field('Subtitle', _subtitle),
            const SizedBox(height: 10),
            _field('Image URL', _imageUrl),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(child: _dateTile('Start', _startDate, () => _pickDate(true))),
                const SizedBox(width: 12),
                Expanded(child: _dateTile('End', _endDate, () => _pickDate(false))),
              ],
            ),
            if (isEdit) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  const Text('Active', style: TextStyle(fontWeight: FontWeight.w500)),
                  const Spacer(),
                  Switch(value: _isActive, activeColor: AppColors.rust,
                      onChanged: (v) => setState(() => _isActive = v)),
                ],
              ),
            ],
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.rust,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(width: 20, height: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text(isEdit ? 'Save Changes' : 'Create Special',
                        style: const TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(String label, TextEditingController ctrl) {
    return TextField(
      controller: ctrl,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        isDense: true,
      ),
    );
  }

  Widget _dateTile(String label, DateTime date, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade400),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 11, color: AppColors.subtext)),
            const SizedBox(height: 2),
            Text('${date.day}/${date.month}/${date.year}',
                style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
