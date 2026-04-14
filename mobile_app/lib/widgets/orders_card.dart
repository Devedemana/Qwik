import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/app_colors.dart';
import '../services/cart_service.dart';
import '../widgets/cart_item_card.dart';
import '../widgets/order_summary.dart';
import '../Frontend/payment.dart';
import '../Frontend/login_screen.dart';

class CartScreen extends StatelessWidget {
  final bool isGuest;
  const CartScreen({super.key, this.isGuest = false});

  @override
  Widget build(BuildContext context) {
    return Consumer<CartService>(
      builder: (context, cart, _) {
        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: Column(
              children: [
                _buildAppBar(context),
                Expanded(
                  child: cart.isEmpty
                      ? _buildEmpty(context)
                      : ListView(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          children: [
                            ...cart.entries.map((entry) => CartItemCard(
                                  item: _toCartItem(entry),
                                  onIncrement: () => cart.increment(entry.item.id),
                                  onDecrement: () => cart.decrement(entry.item.id),
                                )),
                            const SizedBox(height: 24),
                            OrderSummary(
                              subtotal: cart.subtotal,
                              taxes: cart.taxes,
                              delivery: cart.deliveryFee,
                              total: cart.total,
                            ),
                            if (cart.splitCount > 1) ...[
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: AppColors.orange.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Your share (${cart.splitCount} people)',
                                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.darkBrown)),
                                    Text('₵${cart.perPerson.toStringAsFixed(2)}',
                                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.orange)),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                ),
                if (!cart.isEmpty) _buildBillSplitRow(context, cart),
                if (!cart.isEmpty) _buildCheckoutButton(context, cart),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          const SizedBox(width: 46),
          const Expanded(
            child: Center(
              child: Text(
                'My Cart',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.darkBrown,
                ),
              ),
            ),
          ),
          Consumer<CartService>(
            builder: (context, cart, _) => cart.isEmpty
                ? const SizedBox(width: 46)
                : _CircleButton(
                    icon: Icons.delete_outline,
                    onTap: () => cart.clear(),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_bag_outlined, size: 72, color: AppColors.subtext.withValues(alpha: 0.4)),
          const SizedBox(height: 16),
          const Text(
            'Your cart is empty',
            style: TextStyle(fontSize: 18, color: AppColors.subtext),
          ),
          const SizedBox(height: 8),
          const Text(
            'Add items from the menu to get started',
            style: TextStyle(fontSize: 14, color: AppColors.subtext),
          ),
        ],
      ),
    );
  }

  Widget _buildBillSplitRow(BuildContext context, CartService cart) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: GestureDetector(
        onTap: () => _showBillSplitSheet(context, cart),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
          decoration: BoxDecoration(
            color: cart.splitCount > 1 ? AppColors.orange.withValues(alpha: 0.12) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: cart.splitCount > 1 ? AppColors.orange : Colors.grey.shade300),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.call_split, size: 18,
                  color: cart.splitCount > 1 ? AppColors.orange : AppColors.subtext),
              const SizedBox(width: 6),
              Text(
                cart.splitCount > 1
                    ? 'Split bill ÷${cart.splitCount}  •  ₵${cart.perPerson.toStringAsFixed(2)} each'
                    : 'Split the bill',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: cart.splitCount > 1 ? AppColors.orange : AppColors.subtext,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static void _showBillSplitSheet(BuildContext context, CartService cart) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _BillSplitSheet(cart: cart),
    );
  }

  Widget _buildCheckoutButton(BuildContext context, CartService cart) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      child: SizedBox(
        width: double.infinity,
        height: 58,
        child: ElevatedButton(
          onPressed: () {
            if (isGuest) {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Login required'),
                  content: const Text('You need an account to place orders. Sign in or register to continue.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const LoginScreen()),
                        );
                      },
                      child: const Text('Login / Register'),
                    ),
                  ],
                ),
              );
              return;
            }
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ChangeNotifierProvider.value(
                  value: cart,
                  child: const PaymentPage(),
                ),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.darkBrown,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: Text(
            cart.splitCount > 1
                ? 'Checkout  •  ₵${cart.perPerson.toStringAsFixed(2)} each'
                : 'Checkout  •  ₵${cart.total.toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }

  dynamic _toCartItem(CartEntry entry) => _CartItemAdapter(entry);
}

class _CartItemAdapter implements CartItemLike {
  final CartEntry entry;
  _CartItemAdapter(this.entry);
  @override String get name => entry.item.name;
  @override String get subtitle => entry.item.description;
  @override double get price => entry.item.price;
  @override String get imagePath => entry.item.imageUrl;
  @override int get quantity => entry.quantity;
}

class _BillSplitSheet extends StatefulWidget {
  final CartService cart;
  const _BillSplitSheet({required this.cart});

  @override
  State<_BillSplitSheet> createState() => _BillSplitSheetState();
}

class _BillSplitSheetState extends State<_BillSplitSheet> {
  late int _count;

  @override
  void initState() {
    super.initState();
    _count = widget.cart.splitCount;
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.cart.total;
    final perPerson = _count > 1 ? total / _count : total;
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(height: 20),
          const Text('Split the Bill', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.darkBrown)),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _splitBtn(Icons.remove, () { if (_count > 1) setState(() => _count--); }),
              const SizedBox(width: 24),
              Column(
                children: [
                  Text('$_count', style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w700, color: AppColors.darkBrown)),
                  Text(_count == 1 ? 'person' : 'people', style: const TextStyle(color: AppColors.subtext, fontSize: 13)),
                ],
              ),
              const SizedBox(width: 24),
              _splitBtn(Icons.add, () => setState(() => _count++)),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total', style: TextStyle(fontSize: 14, color: AppColors.darkBrown)),
                    Text('₵${total.toStringAsFixed(2)}', style: const TextStyle(fontSize: 14, color: AppColors.darkBrown)),
                  ],
                ),
                const SizedBox(height: 8),
                const Divider(height: 1),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Per person', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.darkBrown)),
                    Text('₵${perPerson.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.rust)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () {
                widget.cart.setSplitCount(_count);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.darkBrown,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: Text(
                _count > 1 ? 'Split ÷$_count' : 'No split',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          if (_count > 1) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                onPressed: () => _shareSplit(context, total, perPerson),
                icon: const Icon(Icons.share, size: 18),
                label: const Text('Share with friends'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.rust,
                  side: BorderSide(color: AppColors.rust.withValues(alpha: 0.5)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _shareSplit(BuildContext context, double total, double perPerson) {
    final items = widget.cart.entries
        .map((e) => '  • ${e.quantity}x ${e.item.name}')
        .join('\n');
    final message =
        'Hey! We ordered from Qwik 🍔\n\n'
        '$items\n\n'
        'Total: ₵${total.toStringAsFixed(2)}\n'
        'Split $_count ways → *₵${perPerson.toStringAsFixed(2)} each*\n\n'
        'Send your share via MoMo. Thanks!';

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Share split details',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.chat, color: Color(0xFF25D366)),
              title: const Text('WhatsApp', style: TextStyle(fontWeight: FontWeight.w600)),
              onTap: () async {
                Navigator.pop(ctx);
                final encoded = Uri.encodeComponent(message);
                final uri = Uri.parse('https://wa.me/?text=$encoded');
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.sms, color: AppColors.rust),
              title: const Text('SMS', style: TextStyle(fontWeight: FontWeight.w600)),
              onTap: () async {
                Navigator.pop(ctx);
                final encoded = Uri.encodeComponent(message);
                final uri = Uri.parse('sms:?body=$encoded');
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri);
                }
              },
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.copy, color: AppColors.darkBrown),
              title: const Text('Copy to clipboard', style: TextStyle(fontWeight: FontWeight.w600)),
              onTap: () {
                Clipboard.setData(ClipboardData(text: message));
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Copied to clipboard')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _splitBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44, height: 44,
        decoration: BoxDecoration(
          color: AppColors.rust.withValues(alpha: 0.12),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: AppColors.rust),
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _CircleButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 46,
        height: 46,
        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
        child: Icon(icon, color: AppColors.darkBrown, size: 20),
      ),
    );
  }
}
