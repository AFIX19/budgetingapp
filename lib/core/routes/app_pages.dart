import 'package:budgetting_app/presentation/screens/main/main_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
// screens
import '../../presentation/screens/auth/login_page.dart';
import '../../presentation/screens/home/home_page.dart';
import '../../presentation/screens/grafik/grafik_page.dart';
import '../../presentation/screens/laporan/laporan_page.dart';
import '../../presentation/screens/profile/profile_page.dart';
import '../../presentation/screens/search/search_page.dart';
import '../../presentation/screens/transaction/add_edit_record_page.dart';

// routes
import 'app_routes.dart';

class AppPages {
  static Map<String, WidgetBuilder> routes = {
    AppRoutes.login: (context) => const LoginPage(),
    AppRoutes.home: (context) => const MainPage(),
    AppRoutes.grafik: (context) => const GrafikPage(),
    AppRoutes.laporan: (context) => const LaporanPage(),
    AppRoutes.profile: (context) => const ProfilePage(),
    AppRoutes.search: (context) => const SearchPage(transactions: null),
    AppRoutes.addEditRecord: (context) => const AddEditRecordPage(),
  };

  /// halaman pertama sesuai kondisi login
  static Widget initialPage() {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Colors.black,
            body: Center(
              child: CircularProgressIndicator(color: Colors.yellow),
            ),
          );
        }
        if (snapshot.hasData) {
          return const MainPage();
        }
        return const LoginPage();
      },
    );
  }
}
