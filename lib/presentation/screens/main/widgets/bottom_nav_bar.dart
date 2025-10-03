import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import 'nav_item.dart';
import 'add_button.dart';

class BottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;
  final VoidCallback onAdd;

  const BottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onTap,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final double bottomSystemPadding = MediaQuery.of(context).padding.bottom;

    return BottomAppBar(
      color: AppColors.background,
      child: SizedBox(
        height: 60.0 + bottomSystemPadding,
        child: Padding(
          padding: EdgeInsets.fromLTRB(8, 0, 8, bottomSystemPadding),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              NavItem(index: 0, icon: Icons.receipt_long, label: 'Catatan', selectedIndex: selectedIndex, onTap: onTap),
              NavItem(index: 1, icon: Icons.pie_chart, label: 'Grafik', selectedIndex: selectedIndex, onTap: onTap),
              AddButton(onTap: onAdd),
              NavItem(index: 2, icon: Icons.article, label: 'Laporan', selectedIndex: selectedIndex, onTap: onTap),
              NavItem(index: 3, icon: Icons.person, label: 'Saya', selectedIndex: selectedIndex, onTap: onTap),
            ],
          ),
        ),
      ),
    );
  }
}
