// lib/screens/main_screen.dart
import 'package:flutter/material.dart';
import '../pages/home/home_page.dart';
import '../pages/grafik/grafik_page.dart';
import '../pages/laporan/laporan_page.dart';
import '../pages/profile/profile_page.dart';
import '../pages/transaction/add_edit_record_page.dart'; 

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const GrafikPage(), 
    const SizedBox(), 
    const LaporanPage(), 
    const ProfilePage(),
  ];

  void _onTabTapped(int index) {
    if (index == 2) {
      // FAB Add
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AddEditRecordPage()),
      );
    } else {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        backgroundColor: Colors.black,
        selectedItemColor: Colors.yellow,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt),
            label: 'Catatan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Grafik',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle, size: 40), 
            label: 'Tambah',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: 'Laporan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Saya',
          ),
        ],
      ),
    );
  }
}