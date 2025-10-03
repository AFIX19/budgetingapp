import 'package:flutter/material.dart';
import '../../../data/enums/transaction_type.dart';

class CategorySelector extends StatelessWidget {
  final TransactionType selectedType;
  final IconData selectedIcon;
  final Color selectedColor;
  final String selectedCategoryName;
  final Function(Map<String, dynamic>) onCategorySelected;

  const CategorySelector({
    super.key,
    required this.selectedType,
    required this.selectedIcon,
    required this.selectedColor,
    required this.selectedCategoryName,
    required this.onCategorySelected,
  });

  static const List<Map<String, dynamic>> _categories = [
    {'name': 'Belanja', 'icon': Icons.shopping_bag, 'color': Colors.orange},
    {'name': 'Makanan', 'icon': Icons.fastfood, 'color': Colors.red},
    {'name': 'Telepon', 'icon': Icons.phone, 'color': Colors.blue},
    {'name': 'Hiburan', 'icon': Icons.movie, 'color': Colors.purple},
    {'name': 'Pendidikan', 'icon': Icons.school, 'color': Colors.green},
    {'name': 'Transportasi', 'icon': Icons.directions_bus, 'color': Colors.teal},
    {'name': 'Rumah', 'icon': Icons.home, 'color': Colors.brown},
    {'name': 'Kesehatan', 'icon': Icons.health_and_safety, 'color': Colors.pink},
    {'name': 'Gaji', 'icon': Icons.attach_money, 'color': Colors.lightGreen},
    {'name': 'Investasi', 'icon': Icons.trending_up, 'color': Colors.blueGrey},
    {'name': 'Paruh waktu', 'icon': Icons.work, 'color': Colors.cyan},
    {'name': 'Penghargaan', 'icon': Icons.emoji_events, 'color': Colors.amber},
    {'name': 'Lain-lain', 'icon': Icons.category, 'color': Colors.grey},
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Kategori', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.0,
          ),
          itemCount: _categories.length,
          itemBuilder: (context, index) {
            final category = _categories[index];
            bool isExpenseCategory = ['Belanja', 'Makanan', 'Telepon', 'Hiburan', 'Pendidikan', 'Transportasi', 'Rumah', 'Kesehatan', 'Lain-lain'].contains(category['name']);
            bool isIncomeCategory = ['Gaji', 'Investasi', 'Paruh waktu', 'Penghargaan'].contains(category['name']);

            if (selectedType == TransactionType.expense && !isExpenseCategory) return const SizedBox.shrink();
            if (selectedType == TransactionType.income && !isIncomeCategory) return const SizedBox.shrink();

            return GestureDetector(
              onTap: () => onCategorySelected(category),
              child: Container(
                decoration: BoxDecoration(
                  color: category['color'].withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: selectedIcon == category['icon'] && selectedColor == category['color']
                        ? Colors.yellow
                        : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(category['icon'], color: category['color'], size: 30),
                    const SizedBox(height: 5),
                    Text(
                      category['name'],
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
