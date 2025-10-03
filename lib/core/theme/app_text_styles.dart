import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  // heading besar / judul utama
  static const heading1 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  // heading sedang / subjudul
  static const heading2 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  // body kecil / subjudul kecil
  static const heading3 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  // body utama / isi text normal
  static const body = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
  );

  // body kecil / deskripsi tambahan
  static const bodySmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
  );

  // caption/ hint text
  static const caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w300,
    color: AppColors.textSecondary,
  );

  // untuk tombol/ style text tombol
  static const button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: AppColors.background,
  );
}
