import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/app_colors.dart';
import '../models/cafeteria.dart';
import '../models/food_item.dart';
import '../services/cafeteria_service.dart';
import '../services/auth_service.dart';
import '../services/cart_service.dart';
import '../widgets/notification_bell.dart';
import '../widgets/cafeteria_card.dart';
import '../widgets/food_card.dart';
import '../widgets/section_widgets.dart';
import '../widgets/special_card.dart';
import '../models/special.dart';
import '../services/special_service.dart';
import 'cafeteria_screen.dart';
import '../widgets/orders_card.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentSpecial = 0;
  int _currentNavIndex = 0;
  final PageController _pageController = PageController();

  List<Cafeteria> _cafeterias = [];
  List<FoodItem> _recommended = [];
  List<Special> _specials = [];
  bool _loading = true;
  String _error = '';
  String _userName = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() { _loading = true; _error = ''; });
    try {
      final name = await AuthService.getUserName();
      final cafeterias = await CafeteriaService.listCafeterias();
      final allItems = await CafeteriaService.getAllMenuItems();
      final specials = await SpecialService.getActiveSpecials().catchError((_) => <Special>[]);
      if (!mounted) return;
      setState(() {
        _userName = name;
        _cafeterias = cafeterias;
        _recommended = allItems.take(6).toList();
        _specials = specials;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Could not load data. Is the server running?';
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: _buildBottomNav(),
      body: IndexedStack(
        index: _currentNavIndex,
        children: [
          _buildHomeContent(),
          CafeteriaScreen(cafeterias: _cafeterias),
          const CartScreen(),
          const ProfileScreen(),
        ],
      ),
    );
  }

  Widget _buildHomeContent() {
    return SafeArea(
      child: Column(
        children: [
          const SizedBox(height: 16),
          _buildHeader(),
          const SizedBox(height: 20),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error.isNotEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.wifi_off, size: 48, color: AppColors.subtext),
                            const SizedBox(height: 12),
                            Text(_error,
                                style: const TextStyle(color: AppColors.subtext),
                                textAlign: TextAlign.center),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _loadData,
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.rust,
                                  foregroundColor: Colors.white),
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildSectionLabel('Today Specials'),
                        const SizedBox(height: 12),
                        _buildSpecialsCarousel(),
                        const SizedBox(height: 20),
                        _buildSearchBar(),
                        const SizedBox(height: 24),
                        buildSectionRow('Cafeterias'),
                        const SizedBox(height: 12),
                        _buildCafeterias(),
                        const SizedBox(height: 24),
                        buildSectionRow('Recommended for you'),
                        const SizedBox(height: 12),
                        _buildRecommendedGrid(),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hello, ${_userName.isNotEmpty ? _userName.split(' ').first : 'there'}',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkBrown,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 2),
              const Row(
                children: [
                  Icon(Icons.location_on_outlined, size: 13, color: AppColors.subtext),
                  SizedBox(width: 2),
                  Text(
                    'Ashesi University',
                    style: TextStyle(fontSize: 13, color: AppColors.subtext),
                  ),
                ],
              ),
            ],
          ),
          const NotificationBell(),
        ],
      ),
    );
  }

  Widget _buildSpecialsCarousel() {
    if (_specials.isEmpty) return const SizedBox.shrink();
    return Column(
      children: [
        SizedBox(
          height: 150,
          child: PageView.builder(
            controller: _pageController,
            itemCount: _specials.length,
            onPageChanged: (i) => setState(() => _currentSpecial = i),
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SpecialCard(special: _specials[index]),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_specials.length, (i) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: _currentSpecial == i ? 16 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: _currentSpecial == i
                    ? AppColors.rust
                    : AppColors.subtext.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(3),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _currentNavIndex = 1),
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.searchBg,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Row(
                  children: [
                    SizedBox(width: 16),
                    Icon(Icons.search, color: AppColors.subtext, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Find what you want...',
                      style: TextStyle(color: AppColors.subtext, fontSize: 15),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.darkBrown,
              borderRadius: BorderRadius.circular(26),
            ),
            child: const Icon(Icons.tune, color: Colors.white, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildCafeterias() {
    if (_cafeterias.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Text('No cafeterias available', style: TextStyle(color: AppColors.subtext)),
      );
    }
    return SizedBox(
      height: 200,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _cafeterias.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () => setState(() => _currentNavIndex = 1),
            child: CafeteriaCard(cafeteria: _cafeterias[index]),
          );
        },
      ),
    );
  }

  Widget _buildRecommendedGrid() {
    if (_recommended.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _recommended.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: 0.78,
        ),
        itemBuilder: (context, index) {
          return FoodCard(
            item: _recommended[index],
            onAddToCart: () {
              final item = _recommended[index];
              final cafeteria = _cafeterias.where((c) => c.id == item.cafeteriaId).firstOrNull;
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

  Widget _buildBottomNav() {
    const items = [
      Icons.home_rounded,
      Icons.restaurant_menu_rounded,
      Icons.shopping_bag_outlined,
      Icons.person_outline_rounded,
    ];
    return Consumer<CartService>(
      builder: (context, cart, _) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(color: Color(0x0F000000), blurRadius: 10, offset: Offset(0, -2)),
            ],
          ),
          child: SafeArea(
            child: SizedBox(
              height: 60,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(items.length, (i) {
                  final selected = i == _currentNavIndex;
                  return GestureDetector(
                    onTap: () => setState(() => _currentNavIndex = i),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: selected
                                ? AppColors.rust.withValues(alpha: 0.1)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Icon(
                            items[i],
                            color: selected ? AppColors.rust : AppColors.subtext,
                            size: 24,
                          ),
                        ),
                        // Cart badge
                        if (i == 2 && cart.totalItems > 0)
                          Positioned(
                            top: 4,
                            right: 8,
                            child: Container(
                              width: 18,
                              height: 18,
                              decoration: const BoxDecoration(
                                color: AppColors.rust,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  '${cart.totalItems}',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                }),
              ),
            ),
          ),
        );
      },
    );
  }
}
