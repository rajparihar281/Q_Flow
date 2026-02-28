import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static Future<Map<String, dynamic>> get(String url) async {
    // removed logs to improve performance
    final response = await http.get(Uri.parse(url));
    // removed logs
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      // removed logs
      return data;
    }
    // removed logs
    throw Exception('Failed: ${response.statusCode}');
  }

  static Future<Map<String, dynamic>> post(
    String url,
    Map<String, dynamic> body,
  ) async {
    // removed logs
    // removed logs
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(body),
    );
    // removed logs
    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = json.decode(response.body);
      // removed logs
      return data;
    }
    // removed logs
    throw Exception('Failed: ${response.statusCode}');
  }

  static Future<Map<String, dynamic>> patch(
    String url,
    Map<String, dynamic> body,
  ) async {
    // removed logs
    final response = await http.patch(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(body),
    );
    // removed logs
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    // removed logs
    throw Exception('Failed: ${response.statusCode}');
  }

  static Future<Map<String, dynamic>> delete(String url) async {
    // removed logs
    final response = await http.delete(Uri.parse(url));
    // removed logs
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    // removed logs
    throw Exception('Failed: ${response.statusCode}');
  }
}
