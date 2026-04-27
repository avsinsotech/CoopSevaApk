import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;

class CustomerProfileService {
  static const String _baseUrl =
      'https://swiftkyc.avsinsotech.com/api/CustomerProfile';

  Future<Map<String, dynamic>?> checkExistence(
    String paramName,
    String value,
  ) async {
    try {
      final url = '$_baseUrl/check-existence?$paramName=$value';
      print('Calling API: $url');
      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      print('Check Existence Status Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        print('Check Existence Error Body: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Check Existence Exception: $e');
      return null;
    }
  }

  /// POST updated profile to the server.
  /// Returns `{'success': true, 'data': ...}` on 200,
  /// or `{'success': false, 'error': '...'}` otherwise.
  Future<Map<String, dynamic>> updateProfile(
    String referenceId,
    Map<String, dynamic> payload,
  ) async {
    try {
      final url = '$_baseUrl/update-profile/$referenceId';
      print('Calling Update API: $url');
      log('Update Payload: ${json.encode(payload)}');

      final response = await http.put(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(payload),
      );

      print('Update Status Code: ${response.statusCode}');
      print('Update Response Body: ${response.body}');

      if (response.statusCode == 200) {
        return {'success': true, 'data': json.decode(response.body)};
      } else {
        return {
          'success': false,
          'error': 'Status ${response.statusCode}: ${response.body}',
        };
      }
    } catch (e) {
      print('Update Profile Exception: $e');
      return {'success': false, 'error': e.toString()};
    }
  }
}
