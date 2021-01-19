/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (C) 2020 wger Team
 *
 * wger Workout Manager is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * wger Workout Manager is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:wger/models/http_exception.dart';
import 'package:wger/providers/auth.dart';

/// Base provider class.
///
/// Provides a couple of comfort functions so we avoid a bit of boilerplate.
class WgerBaseProvider {
  Auth auth;
  http.Client client;

  WgerBaseProvider(auth, [client]) {
    this.auth = auth;
    this.client = client ?? http.Client();
  }

  /// Helper function to make a URL.
  makeUrl(String path, {String id, Map<String, dynamic> query}) {
    Uri uriServer = Uri.parse(auth.serverUrl);

    var pathList = ['api', 'v2', path];
    if (id != null) {
      pathList.add(id);
    }
    final uri = Uri(
      scheme: uriServer.scheme,
      host: uriServer.host,
      port: uriServer.port,
      path: pathList.join('/') + '/',
      queryParameters: query,
    );

    return uri.toString();
  }

  /// Fetch and retrieve the overview list of objects, returns the JSON parsed response
  Future<Map<String, dynamic>> fetch([String urlPath]) async {
    // Send the request
    final response = await client.get(
      urlPath,
      headers: {
        HttpHeaders.authorizationHeader: 'Token ${auth.token}',
        HttpHeaders.userAgentHeader: 'wger Workout Manager App',
      },
    );

    // Something wrong with our request
    if (response.statusCode >= 400) {
      print(response);
      throw WgerHttpException(response.body);
    }

    // Process the response
    return json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
  }

  /// POSTs a new object
  Future<Map<String, dynamic>> add(Map<String, dynamic> data, String urlPath) async {
    final response = await client.post(
      urlPath,
      headers: {
        HttpHeaders.authorizationHeader: 'Token ${auth.token}',
        HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
        HttpHeaders.userAgentHeader: 'wger Workout Manager App',
      },
      body: json.encode(data),
    );

    // Something wrong with our request
    if (response.statusCode >= 400) {
      throw WgerHttpException(response.body);
    }

    return json.decode(response.body);
  }

  /// DELETEs an existing object
  Future<Response> deleteRequest(String url, int id) async {
    final deleteUrl = makeUrl(url, id: id.toString());

    final response = await client.delete(
      deleteUrl,
      headers: {
        HttpHeaders.authorizationHeader: 'Token ${auth.token}',
        HttpHeaders.userAgentHeader: 'wger Workout Manager App',
      },
    );

    // Something wrong with our request
    if (response.statusCode >= 400) {
      throw WgerHttpException(response.body);
    }
    return response;
  }
}
