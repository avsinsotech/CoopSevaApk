import 'package:flutter/material.dart';
import 'package:form_app_27_3_2026/color_constants.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: AppColors.darkNavy,
      scaffoldBackgroundColor: AppColors.bgGrey,
      fontFamily: 'Roboto', // Or your preferred font
      // Define the standard Card Theme based on your snippet
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 8,
        shadowColor: AppColors.navyAccent.withOpacity(0.15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),

      // Define standard Input Fields (Matches your _buildModernField)
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.darkNavy, width: 2),
        ),
        prefixIconColor: AppColors.darkNavy,
        hintStyle: TextStyle(color: Colors.grey.shade400),
      ),

      // Standard App Bar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkNavy,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.0,
        ),
      ),
    );
  }
}
