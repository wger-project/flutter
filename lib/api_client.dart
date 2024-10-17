import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helpers/consts.dart';

final log = Logger('powersync-test');

class ApiClient {
  final String baseUrl;

  const ApiClient(this.baseUrl);

  /// Returns a powersync JWT token token
  ///
  /// Note that at the moment we use the permanent API token for authentication
  /// but this should be probably changed to the wger API JWT tokens in the
  /// future since they are not permanent and could be easily revoked.
  Future<Map<String, dynamic>> getPowersyncToken() async {
    final prefs = await SharedPreferences.getInstance();
    final apiData = json.decode(prefs.getString(PREFS_USER)!);
    print('posting our token "${apiData["token"]}" to $baseUrl/api/v2/powersync-token');
    final response = await http.get(
      Uri.parse('$baseUrl/api/v2/powersync-token'),
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.authorizationHeader: 'Token ${apiData["token"]}',
      },
    );
    print('response: status ${response.statusCode}, body ${response.body}');
    if (response.statusCode == 200) {
      log.log(Level.ALL, response.body);
      return json.decode(response.body);
    }
    throw Exception('Failed to fetch token');
  }

  Future<void> upsert(Map<String, dynamic> record) async {
    await http.put(
      Uri.parse('$baseUrl/api/upload-powersync-data'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(record),
    );
  }

  Future<void> update(Map<String, dynamic> record) async {
    await http.patch(
      Uri.parse('$baseUrl/api/upload-powersync-data'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(record),
    );
  }

  Future<void> delete(Map<String, dynamic> record) async {
    await http.delete(
      Uri.parse('$baseUrl/api/v2/upload-powersync-data'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(record),
    );
  }
}
