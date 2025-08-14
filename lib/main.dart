import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'database/firebase_options.dart';
import 'presentation/screens/home/home_page.dart';
import 'presentation/screens/grafik/grafik_page.dart';
import 'presentation/screens/laporan/laporan_page.dart';
import 'presentation/screens/profile/profile_page.dart';
import 'presentation/screens/transaction/add_edit_record_page.dart';
import 'presentation/screens/auth/login_page.dart';
import 'providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'providers/transaction_provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'pages/search_page.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await initializeDateFormatting('id_ID', null);
  runApp(const BudgetApp());
}

class BudgetApp extends StatelessWidget {
  const BudgetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
      ],
      child: MaterialApp(
        title: 'Pengelola Keuangan',
        theme: ThemeData.dark().copyWith(
          scaffoldBackgroundColor: Colors.black,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.black,
            elevation: 0,
          ),
          colorScheme: const ColorScheme.dark(
            primary: Colors.yellow,
            onSurface: Colors.white,
          ),
          textTheme: const TextTheme(
            bodyLarge: TextStyle(color: Colors.white),
            bodyMedium: TextStyle(color: Colors.white),
            titleLarge: TextStyle(color: Colors.white),
            titleMedium: TextStyle(color: Colors.white),
            titleSmall: TextStyle(color: Colors.white),
            labelLarge: TextStyle(color: Colors.white),
          ),
        ),

        home: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(), // Mendengarkan perubahan status autentikasi
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
        ),
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale("id", "ID"),
        ],
        
        debugShowCheckedModeBanner: false,
      ),
      
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  static const _pages = [
    HomePage(),
    GrafikPage(),
    LaporanPage(),
    ProfilePage(),
  ];

  void _onTap(int idx) => setState(() => _selectedIndex = idx);

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
                _buildAddButtonAsItem(),
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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _onTap(index),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          constraints: const BoxConstraints(minWidth: 60, minHeight: 48.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: _selectedIndex == index ? Colors.yellow : Colors.grey[700],
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: _selectedIndex == index ? Colors.yellow : Colors.grey[700],
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddButtonAsItem() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(50),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const AddEditRecordPage()),
          ).then((value) {
            if (value == true && _selectedIndex == 0) {
              setState(() {});
            }
          });
        },
        child: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.yellow,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.add,
            color: Colors.black,
            size: 30,
          ),
        ),
      ),
    );
  }
}