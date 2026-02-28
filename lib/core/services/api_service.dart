import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static Future<Map<String, dynamic>> get(String url) async {
    print('GET: $url');
    final response = await http.get(Uri.parse(url));
    print('Response: ${response.statusCode}');
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print('Data: $data');
      return data;
    }
    print('Error: ${response.body}');
    throw Exception('Failed: ${response.statusCode}');
  }

  static Future<Map<String, dynamic>> post(String url, Map<String, dynamic> body) async {
    print('POST: $url');
    print('Body: $body');
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(body),
    );
    print('Response: ${response.statusCode}');
    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = json.decode(response.body);
      print('Data: $data');
      return data;
    }
    print('Error: ${response.body}');
    throw Exception('Failed: ${response.statusCode}');
  }

  static Future<Map<String, dynamic>> patch(String url, Map<String, dynamic> body) async {
    print('PATCH: $url');
    final response = await http.patch(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(body),
    );
    print('Response: ${response.statusCode}');
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    print('Error: ${response.body}');
    throw Exception('Failed: ${response.statusCode}');
  }

  static Future<Map<String, dynamic>> delete(String url) async {
    print('DELETE: $url');
    final response = await http.delete(Uri.parse(url));
    print('Response: ${response.statusCode}');
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    print('Error: ${response.body}');
    throw Exception('Failed: ${response.statusCode}');
  }
}
