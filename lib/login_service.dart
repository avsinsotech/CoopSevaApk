import 'dart:convert';
import 'package:http/http.dart' as http;

class LoginService {
  final String _authBaseUrl = 'https://swiftkyc.avsinsotech.com/api/Auth';

  Future<LoginResult> login(String username, String password) async {
    final url = Uri.parse('$_authBaseUrl/app-login');
    final body = json.encode({"username": username, "password": password});

    print(body);
    print(url);

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          final dataNode = responseData['data'] ?? {};
          return LoginResult(
            success: true,
            message: responseData['message'] ?? "Login successfully",
            userID: dataNode['userID'],
            username: dataNode['username'],
            fullName: dataNode['fullName'],
            branchName: dataNode['branchName'],
          );
        } else {
          return LoginResult(
            success: false,
            message: responseData['message'] ?? "Invalid username or password.",
          );
        }
      } else {
        String errorMsg =
            'Login failed. Please check your credentials and try again.';
        try {
          final errData = json.decode(response.body);
          if (errData['message'] != null) {
            errorMsg = errData['message'];
          }
        } catch (_) {}
        return LoginResult(success: false, message: errorMsg);
      }
    } catch (e) {
      return LoginResult(
        success: false,
        message: 'Network error or server unreachable. Please try again.',
      );
    }
  }

  Future<LoginResult> sendForgotPasswordOtp(String identifier) async {
    final url = Uri.parse('$_authBaseUrl/forgot-password/send-otp');
    final body = json.encode({"identifier": identifier});

    print('URL: $url');
    print('Payload: $body');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );
      
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return LoginResult(
          success: responseData['success'] ?? false,
          message: responseData['message'] ?? "OTP sent successfully.",
        );
      } else {
        String errorMsg = 'Failed to send OTP. Please try again.';
        try {
          final errData = json.decode(response.body);
          if (errData['message'] != null) {
            errorMsg = errData['message'];
          }
        } catch (_) {}
        return LoginResult(success: false, message: errorMsg);
      }
    } catch (e) {
      print('Error in sendForgotPasswordOtp: $e');
      return LoginResult(
        success: false,
        message: 'Network error or server unreachable. Please try again.',
      );
    }
  }

  Future<LoginResult> resetPassword(String identifier, String otpCode, String newPassword) async {
    final url = Uri.parse('$_authBaseUrl/forgot-password/reset');
    final body = json.encode({
      "identifier": identifier,
      "otpCode": otpCode,
      "newPassword": newPassword
    });

    print('URL: $url');
    print('Payload: $body');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return LoginResult(
          success: responseData['success'] ?? false,
          message: responseData['message'] ?? "Password reset successfully.",
        );
      } else {
        String errorMsg = 'Failed to reset password. Please try again.';
        try {
          final errData = json.decode(response.body);
          if (errData['message'] != null) {
            errorMsg = errData['message'];
          }
        } catch (_) {}
        return LoginResult(success: false, message: errorMsg);
      }
    } catch (e) {
      print('Error in resetPassword: $e');
      return LoginResult(
        success: false,
        message: 'Network error or server unreachable. Please try again.',
      );
    }
  }
}

class LoginResult {
  final bool success;
  final String message;
  final int? userID;
  final String? username;
  final String? fullName;
  final String? branchName;

  LoginResult({
    required this.success,
    required this.message,
    this.userID,
    this.username,
    this.fullName,
    this.branchName,
  });
}
