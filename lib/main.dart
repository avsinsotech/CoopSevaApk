import 'dart:async';
import 'package:flutter/material.dart';
import 'package:form_app_27_3_2026/app_theme.dart';
import 'package:form_app_27_3_2026/login_screen.dart';

import 'package:shared_preferences/shared_preferences.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Clear any existing session to ensure logout on app restart/close
  final prefs = await SharedPreferences.getInstance();
  await prefs.clear(); 

  runApp(const AvsServiceApp());
}

class AvsServiceApp extends StatefulWidget {
  const AvsServiceApp({super.key});

  @override
  State<AvsServiceApp> createState() => _AvsServiceAppState();
}

class _AvsServiceAppState extends State<AvsServiceApp> {
  Timer? _timer;

  void _startInactivityTimer() {
    _timer?.cancel();
    _timer = Timer(const Duration(minutes: 15), () {
      _logoutUser();
    });
  }

  Future<void> _logoutUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    navigatorKey.currentState?.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  void _handleUserInteraction([_]) {
    _startInactivityTimer();
  }

  @override
  void initState() {
    super.initState();
    _startInactivityTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: _handleUserInteraction,
      onPointerMove: _handleUserInteraction,
      onPointerUp: _handleUserInteraction,
      child: MaterialApp(
        navigatorKey: navigatorKey,
        debugShowCheckedModeBanner: false,
        title: 'AVS CoopSeva 360',
        theme: AppTheme.lightTheme,
        home: const LoginScreen(),
      ),
    );
  }
}
