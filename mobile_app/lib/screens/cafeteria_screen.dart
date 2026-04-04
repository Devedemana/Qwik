import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/app_colors.dart';
import '../models/cafeteria.dart';
import '../models/food_item.dart';
import '../services/cafeteria_service.dart';
import '../services/cart_service.dart';
import '../widgets/food_card.dart';

class CafeteriaScreen extends StatefulWidget {
  final List<Cafeteria> cafeterias;

  const CafeteriaScreen({super.key, required this.cafeterias});

  @override
  State<CafeteriaScreen> createState() => _CafeteriaScreenState();
}

class _CafeteriaScreenState extends State<CafeteriaScreen> {
  Cafeteria? _selected;
  List<FoodItem> _menuItems = [];
  bool _loadingMenu = false;
  final _searchController = TextEditingController();
  List<FoodItem> _searchResults = [];
  bool _searching = false;

  @override
  void initState() {
    super.initState();
    if (widget.cafeterias.isNotEmpty) {
      _selectCafeteria(widget.cafeterias.first);
    }
  }

  @override
  void didUpdateWidget(covariant CafeteriaScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.cafeterias.isEmpty && widget.cafeterias.isNotEmpty && _selected == null) {
      _selectCafeteria(widget.cafeterias.first);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _selectCafeteria(Cafeteria c) async {
    setState(() {
      _selected = c;
      _loadingMenu = true;
      _menuItems = [];
    });
    try {
      final items = await CafeteriaService.getMenu(c.id);
      if (!mounted) return;
      setState(() {
        _menuItems = items;
        _loadingMenu = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingMenu = false);
    }
  }

  Future<void> _onSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searching = false;
        _searchResults = [];
      });
      return;
    }
    setState(() => _searching = true);
    try {
      final results = await CafeteriaService.search(query);
      if (!mounted) return;
      setState(() => _searchResults = results);
    } catch (_) {
      if (!mounted) return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayItems = _searching ? _searchResults : _menuItems;

    return SafeArea(
      child: Column(
        children: [
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Menu',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.darkBrown,
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildSearchBar(),
          const SizedBox(height: 16),
          if (widget.cafeterias.isNotEmpty) _buildCafeteriaTabs(),
          const SizedBox(height: 16),
          Expanded(
            child: _loadingMenu
                ? const Center(child: CircularProgressIndicator())
                : displayItems.isEmpty
                    ? Center(
                        child: Text(
                          _searching ? 'No results found' : 'No items available',
                          style: const TextStyle(color: AppColors.subtext),
                        ),
                      )
                    : _buildGrid(displayItems),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TextField(
        controller: _searchController,
        onChanged: _onSearch,
        decoration: InputDecoration(
          hintText: 'Search menu items...',
          hintStyle: const TextStyle(color: AppColors.subtext),
          prefixIcon: const Icon(Icons.search, color: AppColors.subtext),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: AppColors.subtext),
                  onPressed: () {
                    _searchController.clear();
                    _onSearch('');
                  },
                )
              : null,
          filled: true,
          fillColor: AppColors.searchBg,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildCafeteriaTabs() {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: widget.cafeterias.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          final c = widget.cafeterias[i];
          final isSelected = _selected?.id == c.id;
          return GestureDetector(
            onTap: () => _selectCafeteria(c),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.rust : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? AppColors.rust : AppColors.subtext.withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                c.name,
                style: TextStyle(
                  color: isSelected ? Colors.white : AppColors.darkBrown,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGrid(List<FoodItem> items) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.builder(
        physics: const BouncingScrollPhysics(),
        itemCount: items.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: 0.78,
        ),
        itemBuilder: (context, index) {
          final item = items[index];
          return FoodCard(
            item: item,
            onAddToCart: () {
              final cafeteria = widget.cafeterias
                  .where((c) => c.id == item.cafeteriaId)
                  .firstOrNull;
              context.read<CartService>().addItem(
                    item,
                    cafeteriaId: item.cafeteriaId,
                    cafeteriaName: cafeteria?.name,
                  );
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${item.name} added to cart'),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
