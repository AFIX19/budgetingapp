// lib/utils/category_icons.dart
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CategoryIcons {
  // Mapping untuk ikon berdasarkan nama kategori
  static final Map<String, IconData> iconMap = {
    'Makanan & Minuman': Icons.fastfood,
    'Transportasi': Icons.directions_car,
    'Belanja': Icons.shopping_bag,
    'Hiburan': Icons.movie,
    'Tagihan': Icons.receipt,
    'Gaji': FontAwesomeIcons.moneyBillWave,
    'Investasi': Icons.area_chart,
    'Hadiah': Icons.card_giftcard,
    'Kesehatan': Icons.medical_services,
    'Pendidikan': Icons.school,
    'Lain-lain': Icons.category, // Default
    // Tambahkan lebih banyak kategori dan ikon sesuai kebutuhan
  };

  // Mapping untuk warna berdasarkan nama kategori
  // Anda bisa membuat warna berbeda untuk income/expense jika diinginkan
  static final Map<String, Color> colorMapExpense = {
    'Makanan & Minuman': Colors.orange,
    'Transportasi': Colors.blue,
    'Belanja': Colors.purple,
    'Hiburan': Colors.pink,
    'Tagihan': Colors.red,
    'Lain-lain': Colors.grey, // Default
  };

  static final Map<String, Color> colorMapIncome = {
    'Gaji': Colors.green,
    'Investasi': Colors.teal,
    'Hadiah': Colors.lightGreen,
    'Lain-lain': Colors.blueGrey, // Default
  };

  static IconData getCategoryIcon(String categoryName) {
    return iconMap[categoryName] ?? Icons.category; // Default jika tidak ditemukan
  }

  static Color getCategoryColor(String categoryName, String transactionType) {
    if (transactionType == 'expense') {
      return colorMapExpense[categoryName] ?? Colors.grey;
    } else if (transactionType == 'income') {
      return colorMapIncome[categoryName] ?? Colors.grey;
    }
    return Colors.grey; // Default
  }
}