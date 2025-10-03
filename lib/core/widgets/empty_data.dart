// lib/widgets/empty_data.dart
import 'package:flutter/material.dart';

class EmptyData extends StatelessWidget {
  const EmptyData({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt, size: 50, color: Colors.grey[700]), // Warna lebih gelap
          const SizedBox(height: 10),
          Text(
            'Tidak ada catatan',
            style: TextStyle(color: Colors.grey[700]), // Warna lebih gelap
          ),
        ],
      ),
    );
  }
}