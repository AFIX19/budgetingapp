import 'package:flutter/material.dart';
import 'grafik_bar_page.dart';
import 'grafik_pie_page.dart';

class GrafikTabPage extends StatelessWidget {
  const GrafikTabPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: const Text("Grafik"),
          bottom: const TabBar(
            tabs: [
              Tab(text: "Bar Chart"),
              Tab(text: "Pie Chart"),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            GrafikBarPage(),
            GrafikPiePage(),
          ],
        ),
      ),
    );
  }
}
