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

import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:wger/models/http_exception.dart';
import 'package:wger/providers/auth.dart';

/// Base provider class.
/// Provides a couple of comfort functions so we avoid a bit of boilerplate.
class WgerBaseProvider {
  String requestUrl;
  Auth auth;

  WgerBaseProvider(auth, urlPath) {
    this.auth = auth;
    this.requestUrl = makeUrl(urlPath);
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
  Future<Map<String, dynamic>> fetch(http.Client client, [String urlPath]) async {
    if (client == null) {
      client = http.Client();
    }

    // Send the request
    final response = await client.get(
      urlPath,
      headers: {
        'Authorization': 'Token ${auth.token}',
        'User-Agent': 'wger Workout Manager App',
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
  Future<Map<String, dynamic>> add(Map<String, dynamic> data, http.Client client,
      [String urlPath]) async {
    if (client == null) {
      client = http.Client();
    }

    if (urlPath != null) {
      requestUrl = makeUrl(urlPath);
    }

    final response = await client.post(
      requestUrl,
      headers: {
        'Authorization': 'Token ${auth.token}',
        'Content-Type': 'application/json; charset=UTF-8',
        'User-Agent': 'wger Workout Manager App',
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
  Future<Response> deleteRequest(String url, int id, http.Client client) async {
    final deleteUrl = makeUrl(url, id: id.toString());

    final response = await client.delete(
      deleteUrl,
      headers: {
        'Authorization': 'Token ${auth.token}',
        'User-Agent': 'wger Workout Manager App',
      },
    );

    // Something wrong with our request
    if (response.statusCode >= 400) {
      throw WgerHttpException(response.body);
    }
    return response;
  }
}
