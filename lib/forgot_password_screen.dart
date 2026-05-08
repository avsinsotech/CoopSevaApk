import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:form_app_27_3_2026/color_constants.dart';
import 'package:form_app_27_3_2026/login_service.dart';
import 'package:form_app_27_3_2026/reset_password_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _loginService = LoginService();
  final _identifierController = TextEditingController();
  
  bool _isLoading = false;
  String _identifierType = 'Mobile'; // 'Mobile' or 'UserID'

  @override
  void dispose() {
    _identifierController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.bgGrey,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      extendBodyBehindAppBar: true,
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
                  vertical: 100, // Adjusted padding
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.lock_reset,
                      color: Colors.white,
                      size: 60,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "FORGOT PASSWORD",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Select identifier type to receive OTP",
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
                            // TYPE SELECTION
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildRadioOption('Mobile'),
                                const SizedBox(width: 20),
                                _buildRadioOption('UserID'),
                              ],
                            ),
                            const SizedBox(height: 25),

                            _buildLabel(_identifierType == 'Mobile' ? "Mobile Number" : "User ID"),
                            TextFormField(
                              controller: _identifierController,
                              keyboardType: _identifierType == 'Mobile' ? TextInputType.phone : TextInputType.text,
                              maxLength: _identifierType == 'Mobile' ? 10 : null,
                              inputFormatters: _identifierType == 'Mobile'
                                  ? [FilteringTextInputFormatter.digitsOnly]
                                  : null,
                              decoration: _inputDecoration(
                                _identifierType == 'Mobile' ? "Enter 10-digit mobile number" : "Enter User ID",
                                _identifierType == 'Mobile' ? Icons.phone_android : Icons.person_outline,
                              ),
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) {
                                  return "Required";
                                }
                                if (_identifierType == 'Mobile') {
                                  if (val.trim().length != 10 || !RegExp(r'^[0-9]+$').hasMatch(val.trim())) {
                                    return "Enter a valid 10-digit mobile number";
                                  }
                                }
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

                                          final identifier = _identifierController.text.trim();
                                          final result = await _loginService.sendForgotPasswordOtp(identifier);

                                          if (mounted) {
                                            setState(() {
                                              _isLoading = false;
                                            });

                                            if (result.success) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text(result.message),
                                                  backgroundColor: Colors.green,
                                                  duration: const Duration(seconds: 2),
                                                ),
                                              );
                                              
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) => ResetPasswordScreen(identifier: identifier),
                                                ),
                                              );
                                            } else {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text(result.message),
                                                  backgroundColor: Colors.red,
                                                  duration: const Duration(seconds: 3),
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
                                            "SEND OTP",
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

  Widget _buildRadioOption(String type) {
    bool isSelected = _identifierType == type;
    return GestureDetector(
      onTap: () {
        setState(() {
          _identifierType = type;
          _identifierController.clear(); // Clear text when switching
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.darkNavy : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.darkNavy : Colors.grey.shade300,
          ),
        ),
        child: Text(
          type == 'Mobile' ? 'Mobile Number' : 'User ID',
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey.shade600,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
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

  InputDecoration _inputDecoration(String hint, IconData icon, {Widget? suffixIcon}) {
    return InputDecoration(
      hintText: hint,
      counterText: "", // Hide character counter
      prefixIcon: Icon(icon, color: AppColors.darkNavy),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.grey.shade50,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }
}
