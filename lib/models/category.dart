// lib/models/category.dart
import 'package:flutter/material.dart';

class Category {
  final String id;
  final String name;
  final IconData icon;
  final Color color;

  Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
  });

  // Anda bisa tambahkan fromJson/toJson jika Anda berencana menyimpan kategori di Firestore
  // Tapi untuk saat ini, list statis cukup.
}