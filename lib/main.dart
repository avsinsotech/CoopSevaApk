import 'package:flutter/material.dart';
import 'package:form_app_27_3_2026/app_theme.dart';
import 'package:form_app_27_3_2026/dashboard_screen.dart';
import 'package:form_app_27_3_2026/login_screen.dart';

import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

  runApp(AvsServiceApp(isLoggedIn: isLoggedIn));
}

class AvsServiceApp extends StatelessWidget {
  final bool isLoggedIn;

  const AvsServiceApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AVS CoopSeva 360',
      theme: AppTheme.lightTheme,
      home: isLoggedIn ? const DashboardScreen() : const LoginScreen(),
      // home: DashboardScreen(),
    );
  }
}
