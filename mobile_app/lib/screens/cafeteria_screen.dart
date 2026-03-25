import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../data/sample_data.dart';
import '../widgets/food_card.dart';
import '../widgets/section_widgets.dart';

class CafeteriaScreen extends StatefulWidget {
  const CafeteriaScreen({super.key});

  @override
  State<CafeteriaScreen> createState() => _CafeteriaScreenState();
}

class _CafeteriaScreenState extends State<CafeteriaScreen> {
  @override
  Widget build(BuildContext context) {
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
                  const SizedBox(height: 20),
                  _buildSearchBar(),
                  const SizedBox(height: 24),
                  buildSectionRow('Cafeterias'),
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
        children: [],
      ),
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
}
