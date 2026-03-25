import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../data/sample_data.dart';
import '../widgets/notification_bell.dart';
import '../widgets/special_card.dart';
import '../widgets/cafeteria_card.dart';
import '../widgets/food_card.dart';
import '../widgets/section_widgets.dart';
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
          const CafeteriaScreen(),
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
            child: SingleChildScrollView(
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
              const Text(
                'Hello, Nessa',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkBrown,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 2),
              const Row(
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: 13,
                    color: AppColors.subtext,
                  ),
                  SizedBox(width: 2),
                  Text(
                    'Ashesi , Off-Campus',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.subtext,
                      fontWeight: FontWeight.w400,
                    ),
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
    return Column(
      children: [
        SizedBox(
          height: 150,
          child: PageView.builder(
            controller: _pageController,
            itemCount: specials.length,
            onPageChanged: (i) => setState(() => _currentSpecial = i),
            itemBuilder: (context, index) {
              final s = specials[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SpecialCard(special: s),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(specials.length, (i) {
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
                    style: TextStyle(
                      color: AppColors.subtext,
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
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
    return SizedBox(
      height: 200,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: cafeterias.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          return CafeteriaCard(cafeteria: cafeterias[index]);
        },
      ),
    );
  }

  Widget _buildRecommendedGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: recommended.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: 0.78,
        ),
        itemBuilder: (context, index) {
          return FoodCard(item: recommended[index]);
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
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
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
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
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
              );
            }),
          ),
        ),
      ),
    );
  }
}
