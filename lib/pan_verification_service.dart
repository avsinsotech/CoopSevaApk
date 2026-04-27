import 'dart:convert';
import 'package:http/http.dart' as http;

class PanVerificationService {
  final String _baseUrl = 'https://swiftkyc.avsinsotech.com/api/Auth';

  Future<PanVerificationResult> verifyPan(String panNumber) async {
    final url = Uri.parse('$_baseUrl/verify-pan');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({"panNumber": panNumber}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);

        if (data['details']?.toString().toLowerCase() != 'success') {
          return PanVerificationResult(
            success: false,

            message: 'Pan verification failed',
          );
        }

        final providerStr = data['providerResponse'];
        if (providerStr != null) {
          final providerResponse = json.decode(providerStr);
          final providerData = providerResponse['data'];
          if (providerData != null) {
            return PanVerificationResult(
              success: true,
              message: data['message'] ?? 'PAN verified successfully.',
              fullName: providerData['full_name'],
              category: providerData['category'],
            );
          }
        }
        return PanVerificationResult(
          success: true,
          message: data['message'] ?? 'PAN Verified.',
        );
      } else {
        return PanVerificationResult(
          success: false,
          message: 'Failed to verify PAN: ${response.body}',
        );
      }
    } catch (e) {
      return PanVerificationResult(success: false, message: 'Error: $e');
    }
  }
}

class PanVerificationResult {
  final bool success;
  final String message;
  final String? fullName;
  final String? category;

  PanVerificationResult({
    required this.success,
    required this.message,
    this.fullName,
    this.category,
  });
}
