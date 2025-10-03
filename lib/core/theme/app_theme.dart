import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

class AppTheme {
  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.background,
    //untuk warna tetap hitam dan icon kuning
    appBarTheme: const AppBarTheme(
      foregroundColor: AppColors.primary,
      backgroundColor: AppColors.background,
      elevation: 0,
    ),

    //warna utama aplikasi
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primary,
      background: AppColors.background,
      onBackground: AppColors.textPrimary,
      onPrimary: AppColors.background,
      secondary: AppColors.primary,
    ),

    //teks theme untuk heading, body, caption, tombol, dll
    textTheme: const TextTheme(
      displayLarge: AppTextStyles.heading1, //judul besar
      displayMedium: AppTextStyles.heading2, //subjudul sedang
      displaySmall: AppTextStyles.heading3, //subjudul kecil
      bodyLarge: AppTextStyles.body, //untuk isi text normal
      bodyMedium: AppTextStyles.bodySmall, //isi text kecil/ deskripsi
      bodySmall: AppTextStyles.caption, //catatan/hint text
      labelLarge: AppTextStyles.button, //text tombol
    ),

    //tema untuk bottom navigation bar 
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.background,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textSecondary,
    ),

    //floating action button theme
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.background,
    ),
  );
}
