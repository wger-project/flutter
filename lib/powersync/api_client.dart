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

/// Thin REST client used by the PowerSync connector.
///
/// In production the [http.Client] passed in is the project-wide
/// `AuthHttpClient`, which injects the right `Authorization` header
/// (`Bearer` for headless JWT, `Token` for legacy permanent tokens) and
/// runs pre-emptive refresh ahead of token expiry. This class itself
/// therefore stays auth-agnostic: it only sets `Content-Type` and lets
/// the client own everything else.
class ApiClient {
  late final uri = Uri.parse('$serverUrl/api/v2/upload-powersync-data');

  final String serverUrl;
  final http.Client _client;

  ApiClient(this.serverUrl, {http.Client? client}) : _client = client ?? http.Client();

  Map<String, String> getHeaders() {
    return {HttpHeaders.contentTypeHeader: 'application/json'};
  }

  /// Fetches a short-lived PowerSync JWT and its endpoint URL from the
  /// wger backend. The `Authorization` header for this request is set
  /// by the underlying [AuthHttpClient] based on the current auth state.
  Future<Map<String, dynamic>> getPowersyncToken() async {
    final response = await _client.get(
      Uri.parse('$serverUrl/api/v2/powersync-token'),
      headers: getHeaders(),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    throw Exception('Failed to fetch token');
  }

  // Return the raw [http.Response] so the connector can inspect status and
  // body. The backend encodes permanent rejections as 200 + `{'error': ...}`
  // (a non-2xx would trigger PowerSync's retry loop). Infrastructure and
  // unhandled 5xx aren't part of that contract; the connector classifies and
  // retries those.
  Future<http.Response> upsert(Map<String, dynamic> record) {
    return _client.put(uri, headers: getHeaders(), body: json.encode(record));
  }

  Future<http.Response> update(Map<String, dynamic> record) {
    return _client.patch(uri, headers: getHeaders(), body: json.encode(record));
  }

  Future<http.Response> delete(Map<String, dynamic> record) {
    return _client.delete(uri, headers: getHeaders(), body: json.encode(record));
  }
}
