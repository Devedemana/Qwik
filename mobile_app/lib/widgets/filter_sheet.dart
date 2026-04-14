import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class FilterSheet extends StatefulWidget {
  final Set<String> selectedDietary;
  final bool expressOnly;
  final Function(Set<String> dietary, bool expressOnly) onApply;

  const FilterSheet({
    super.key,
    required this.selectedDietary,
    required this.expressOnly,
    required this.onApply,
  });

  @override
  State<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<FilterSheet> {
  late Set<String> _dietary;
  late bool _expressOnly;

  static const _dietaryOptions = ['Vegan', 'Keto', 'Halal'];
  static const _allergenOptions = ['Peanuts', 'Gluten', 'Dairy', 'Shellfish', 'Fish'];

  @override
  void initState() {
    super.initState();
    _dietary = Set.from(widget.selectedDietary);
    _expressOnly = widget.expressOnly;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text('Filter Menu', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.darkBrown)),

          const SizedBox(height: 20),

          // Express meals toggle
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Row(
              children: [
                Icon(Icons.bolt, color: AppColors.orange, size: 20),
                SizedBox(width: 6),
                Text('Express Meals Only', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              ],
            ),
            subtitle: const Text('Ready in under 10 minutes', style: TextStyle(fontSize: 12)),
            value: _expressOnly,
            activeColor: AppColors.orange,
            onChanged: (v) => setState(() => _expressOnly = v),
          ),

          const SizedBox(height: 16),

          // Dietary lifestyle
          const Text('Dietary Lifestyle', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.darkBrown)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _dietaryOptions.map((tag) {
              final selected = _dietary.contains(tag);
              return FilterChip(
                label: Text(tag),
                selected: selected,
                selectedColor: AppColors.rust.withValues(alpha: 0.2),
                checkmarkColor: AppColors.rust,
                onSelected: (v) => setState(() {
                  v ? _dietary.add(tag) : _dietary.remove(tag);
                }),
              );
            }).toList(),
          ),

          const SizedBox(height: 20),

          // Exclude allergens info
          const Text('Allergen Tags', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.darkBrown)),
          const SizedBox(height: 6),
          Text('Items display allergen badges: ${_allergenOptions.join(", ")}', style: TextStyle(fontSize: 12, color: AppColors.subtext)),

          const SizedBox(height: 24),

          // Apply button
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _dietary.clear();
                      _expressOnly = false;
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    side: const BorderSide(color: AppColors.darkBrown),
                  ),
                  child: const Text('Clear All', style: TextStyle(color: AppColors.darkBrown)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: () {
                    widget.onApply(_dietary, _expressOnly);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.darkBrown,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('Apply Filters', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
