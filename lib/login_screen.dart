import 'package:flutter/material.dart';
import 'package:form_app_27_3_2026/color_constants.dart';
import 'package:form_app_27_3_2026/dashboard_screen.dart';
import 'package:form_app_27_3_2026/login_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'dart:async';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _loginService = LoginService();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.bgGrey,
      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: size.height),
          child: Stack(
            children: [
              // 1. BACKGROUND
              Container(
                height: size.height * 0.4,
                decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(60),
                    bottomRight: Radius.circular(60),
                  ),
                ),
              ),
              Positioned(
                top: -60,
                left: -60,
                child: Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    shape: BoxShape.circle,
                  ),
                ),
              ),

              // 2. FORM
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 80,
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.lock_person,
                      color: Colors.white,
                      size: 60,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "WELCOME BACK",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Login to continue",
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    const SizedBox(height: 40),

                    Container(
                      padding: const EdgeInsets.all(25),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.navyAccent.withOpacity(0.1),
                            blurRadius: 30,
                            offset: const Offset(0, 15),
                          ),
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel("Username"),
                            TextFormField(
                              controller: _usernameController,
                              keyboardType: TextInputType.text,
                              decoration: _inputDecoration(
                                "Enter Username",
                                Icons.person_outline,
                              ),
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) {
                                  return "Required";
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),

                            _buildLabel("Password"),
                            TextFormField(
                              controller: _passwordController,
                              keyboardType: TextInputType.visiblePassword,
                              obscureText: true,
                              enabled: !_isLoading,
                              decoration: _inputDecoration(
                                "Enter Password",
                                Icons.lock_outline,
                              ),
                              validator: (val) {
                                if (val == null || val.trim().isEmpty)
                                  return "Required";
                                return null;
                              },
                            ),
                            const SizedBox(height: 40),

                            SizedBox(
                              width: double.infinity,
                              height: 55,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                onPressed: _isLoading
                                    ? null
                                    : () async {
                                        if (_formKey.currentState!.validate()) {
                                          setState(() {
                                            _isLoading = true;
                                          });

                                          final result = await _loginService
                                              .login(
                                                _usernameController.text,
                                                _passwordController.text,
                                              );

                                          if (mounted) {
                                            setState(() {
                                              _isLoading = false;
                                            });

                                            if (result.success) {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Text(result.message),
                                                  backgroundColor: Colors.green,
                                                  duration: const Duration(
                                                    seconds: 2,
                                                  ),
                                                ),
                                              );

                                              final prefs =
                                                  await SharedPreferences.getInstance();
                                              await prefs.setBool(
                                                'isLoggedIn',
                                                true,
                                              );
                                              if (result.userID != null) {
                                                await prefs.setInt(
                                                  'userID',
                                                  result.userID!,
                                                );
                                              }
                                              if (result.username != null) {
                                                await prefs.setString(
                                                  'username',
                                                  result.username!,
                                                );
                                              }
                                              if (result.fullName != null) {
                                                await prefs.setString(
                                                  'fullName',
                                                  result.fullName!,
                                                );
                                              }
                                              if (result.branchName != null) {
                                                await prefs.setString(
                                                  'branchName',
                                                  result.branchName!,
                                                );
                                              }

                                              if (!mounted) return;
                                              Navigator.pushReplacement(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) =>
                                                      const DashboardScreen(),
                                                ),
                                              );
                                            } else {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Text(result.message),
                                                  backgroundColor: Colors.red,
                                                  duration: const Duration(
                                                    seconds: 3,
                                                  ),
                                                ),
                                              );
                                            }
                                          }
                                        }
                                      },
                                child: Ink(
                                  decoration: BoxDecoration(
                                    gradient: AppColors.buttonGradient,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Center(
                                    child: _isLoading
                                        ? const SizedBox(
                                            height: 24,
                                            width: 24,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : const Text(
                                            "LOGIN",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 1,
                                            ),
                                          ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 6),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.grey.shade600,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: AppColors.darkNavy),
      filled: true,
      fillColor: Colors.grey.shade50,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }
}
