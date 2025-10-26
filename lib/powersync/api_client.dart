/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (c) 2020,  wger Team
 *
 * wger Workout Manager is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'package:wger/helpers/shared_preferences.dart';

import '../helpers/consts.dart';

class ApiClient {
  final _logger = Logger('powersync-ApiClient');
  late final uri = Uri.parse('$baseUrl/api/v2/upload-powersync-data');

  final String baseUrl;
  String token = '';

  ApiClient(this.baseUrl);

  Map<String, String> getHeaders() {
    return {
      HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.authorizationHeader: 'Token $token',
    };
  }

  /// Returns a powersync JWT token token
  ///
  /// Note that at the moment we use the permanent API token for authentication
  /// but this should be probably changed to the wger API JWT tokens in the
  /// future since they are not permanent and could be easily revoked.
  Future<Map<String, dynamic>> getPowersyncToken() async {
    final prefs = PreferenceHelper.asyncPref;

    final apiData = json.decode((await prefs.getString(PREFS_USER))!);
    // _logger.info('posting our token "${apiData["token"]}" to $baseUrl/api/v2/powersync-token');

    token = apiData['token'];
    final response = await http.get(
      Uri.parse('$baseUrl/api/v2/powersync-token'),
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.authorizationHeader: 'Token ${apiData["token"]}',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    throw Exception('Failed to fetch token');
  }

  Future<void> upsert(Map<String, dynamic> record) async {
    await http.put(
      uri,
      headers: getHeaders(),
      body: json.encode(record),
    );
  }

  Future<void> update(Map<String, dynamic> record) async {
    await http.patch(
      uri,
      headers: getHeaders(),
      body: json.encode(record),
    );
  }

  Future<void> delete(Map<String, dynamic> record) async {
    await http.delete(
      uri,
      headers: getHeaders(),
      body: json.encode(record),
    );
  }
}
