import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';

final log = Logger('powersync-test');

class ApiClient {
  final String baseUrl;

  ApiClient(this.baseUrl);

  Future<Map<String, dynamic>> authenticate(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'username': username, 'password': password}),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to authenticate');
    }
  }

  Future<Map<String, dynamic>> getToken(String userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/get_powersync_token/'),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to fetch token');
    }
  }

  Future<void> upsert(Map<String, dynamic> record) async {
    await http.put(
      Uri.parse('$baseUrl/api/upload_data/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(record),
    );
  }

  Future<void> update(Map<String, dynamic> record) async {
    await http.patch(
      Uri.parse('$baseUrl/api/upload_data/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(record),
    );
  }

  Future<void> delete(Map<String, dynamic> record) async {
    await http.delete(
      Uri.parse('$baseUrl/api/upload_data/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(record),
    );
  }
}
