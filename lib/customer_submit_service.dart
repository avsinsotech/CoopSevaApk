import 'dart:convert';
import 'package:http/http.dart' as http;

class CustomerSubmitService {
  Future<Map<String, dynamic>?> submitProfile(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse(
          'https://swiftkyc.avsinsotech.com/api/CustomerProfile/submit-profile',
        ),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );

      print('Submit Status Code: ${response.statusCode}');
      print('Submit Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        return null;
      }
    } catch (e) {
      print("Submit Error: $e");
      return null;
    }
  }
}
