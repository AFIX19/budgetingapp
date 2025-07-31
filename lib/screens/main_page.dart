import 'package:flutter/material.dart';
import '../pages/home/home_page.dart';
import '../pages/grafik/grafik_page.dart';
import '../pages/laporan/laporan_page.dart';
import '../pages/profile/profile_page.dart';
import '../pages/transaction/add_edit_record_page.dart';


class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    HomePage(),
    GrafikPage(),
    LaporanPage(),
    ProfilePage(),
  ];

  void _onTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final double bottomSystemPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      extendBody: true,
      body: SafeArea(
        child: _pages[_selectedIndex],
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.black,
        child: SizedBox(
          height: 60.0 + bottomSystemPadding,
          child: Padding(
            padding: EdgeInsets.fromLTRB(8.0, 0, 8.0, bottomSystemPadding),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, Icons.receipt_long, 'Catatan'),
                _buildNavItem(1, Icons.pie_chart, 'Grafik'),
                _buildAddButton(),
                _buildNavItem(2, Icons.article, 'Laporan'),
                _buildNavItem(3, Icons.person, 'Saya'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final bool isSelected = _selectedIndex == index;

    return InkWell(
      onTap: () => _onTap(index),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        constraints: const BoxConstraints(minWidth: 60, minHeight: 48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isSelected ? Colors.yellow : Colors.grey[600], size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? Colors.yellow : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddButton() {
    return InkWell(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AddEditRecordPage()),
        );

        if (result == true && _selectedIndex == 0) {
          setState(() {}); // merefresh HomePage
        }
      },
      borderRadius: BorderRadius.circular(30),
      child: Container(
        width: 50,
        height: 50,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.yellow,
        ),
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }
}
