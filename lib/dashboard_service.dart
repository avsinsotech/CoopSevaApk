// import 'dart:convert';
// import 'package:http/http.dart' as http;

// class DashboardService {
//   static const String baseUrl = "http://110.227.207.211:4000/api/Complaint";

//   Future<Map<String, dynamic>> getDashboardStats(String clientCode) async {
//     final url = Uri.parse("$baseUrl/dashboard-stats/$clientCode");
//     try {
//       final response = await http.get(url);

//       if (response.statusCode == 200) {
//         return jsonDecode(response.body);
//       } else {
//         throw Exception("Failed to load dashboard stats");
//       }
//     } catch (e) {
//       rethrow;
//     }
//   }
// }
