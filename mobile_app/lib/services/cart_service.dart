import 'package:flutter/foundation.dart';
import '../models/food_item.dart';

class CartEntry {
  final FoodItem item;
  int quantity;

  CartEntry({required this.item, this.quantity = 1});
}

class CartService extends ChangeNotifier {
  static final CartService _instance = CartService._internal();
  factory CartService() => _instance;
  CartService._internal();

  final List<CartEntry> _entries = [];
  String? _cafeteriaId;
  String? _cafeteriaName;

  List<CartEntry> get entries => List.unmodifiable(_entries);
  String? get cafeteriaId => _cafeteriaId;
  String? get cafeteriaName => _cafeteriaName;
  bool get isEmpty => _entries.isEmpty;
  int get totalItems => _entries.fold(0, (s, e) => s + e.quantity);

  double get subtotal =>
      _entries.fold(0, (s, e) => s + e.item.price * e.quantity);
  double get taxes => subtotal * 0.044;
  double get deliveryFee => isEmpty ? 0 : 6.0;
  double get total => subtotal + taxes + deliveryFee;

  void addItem(FoodItem item, {String? cafeteriaId, String? cafeteriaName}) {
    // If adding from a different cafeteria, clear cart first
    if (_cafeteriaId != null && cafeteriaId != null && _cafeteriaId != cafeteriaId) {
      _entries.clear();
    }
    _cafeteriaId ??= cafeteriaId;
    _cafeteriaName ??= cafeteriaName;

    final existing = _entries.where((e) => e.item.id == item.id).firstOrNull;
    if (existing != null) {
      existing.quantity++;
    } else {
      _entries.add(CartEntry(item: item));
    }
    notifyListeners();
  }

  void increment(String itemId) {
    final entry = _entries.where((e) => e.item.id == itemId).firstOrNull;
    if (entry != null) {
      entry.quantity++;
      notifyListeners();
    }
  }

  void decrement(String itemId) {
    final idx = _entries.indexWhere((e) => e.item.id == itemId);
    if (idx == -1) return;
    if (_entries[idx].quantity > 1) {
      _entries[idx].quantity--;
    } else {
      _entries.removeAt(idx);
      if (_entries.isEmpty) _cafeteriaId = null;
    }
    notifyListeners();
  }

  void clear() {
    _entries.clear();
    _cafeteriaId = null;
    _cafeteriaName = null;
    notifyListeners();
  }

  List<Map<String, dynamic>> toOrderItems() {
    return _entries
        .map((e) => {'menuItemId': e.item.id, 'quantity': e.quantity})
        .toList();
  }
}
