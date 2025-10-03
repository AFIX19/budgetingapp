import 'package:flutter/material.dart';
import '../home/home_page.dart';
import '../grafik/grafik_page.dart';
import '../laporan/laporan_page.dart';
import '../profile/profile_page.dart';
import '../transaction/add_edit_record_page.dart';
import 'widgets/bottom_nav_bar.dart';

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
    return Scaffold(
      extendBody: true,
      body: SafeArea(child: _pages[_selectedIndex]),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onTap: _onTap,
        onAdd: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddEditRecordPage()),
          );

          if (result == true && _selectedIndex == 0) {
            setState(() {}); // refresh HomePage
          }
        },
      ),
    );
  }
}
