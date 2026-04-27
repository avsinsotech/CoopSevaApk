import 'dart:convert';
import 'package:http/http.dart' as http;

class LoginService {
  final String _authBaseUrl = 'https://swiftkyc.avsinsotech.com/api/Auth';

  Future<LoginResult> login(String username, String password) async {
    final url = Uri.parse('$_authBaseUrl/app-login');
    final body = json.encode({"username": username, "password": password});

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
            message:
                responseData['message'] ??
                "Invalid username or password, or user is inactive.",
          );
        }
      } else {
        return LoginResult(
          success: false,
          message: 'Server responded with ${response.statusCode}.',
        );
      }
    } catch (e) {
      return LoginResult(success: false, message: 'Error: $e');
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
