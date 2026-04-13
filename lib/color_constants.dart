import 'package:flutter/material.dart';

class AppColors {
  // --- Your Default Theme Colors ---
  static const Color darkNavy = Color(0xFF1E2235); // Primary
  static const Color navyAccent = Color(0xFF2A5298); // Gradient End
  static const Color tealAccent = Color(0xFF3B9EB8); // Secondary
  static const Color bgGrey = Color(0xFFF4F6F9); // Scaffolds
  static const Color surface = Colors.white;

  // --- AVS SERVICE Status Colors ---
  static const Color statusPending = Color(0xFFFFC107); // 🟡 Pending
  static const Color statusSolved = Color(0xFF4CAF50); // 🟢 Solved
  static const Color statusHold = Color(0xFF2196F3); // 🔵 Hold
  static const Color statusNotPossible = Color(0xFFF44336); // 🔴 Not Possible

  // --- Gradients ---
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [darkNavy, navyAccent],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient buttonGradient = LinearGradient(
    colors: [darkNavy, tealAccent],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
}
