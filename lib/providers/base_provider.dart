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
  String url;
  Auth auth;

  WgerBaseProvider(auth, baseUrl) {
    this.auth = auth;
    this.url = auth.serverUrl + baseUrl;
  }

  /// Fetch and retrieve the overview list of objects, returns the JSON parsed response
  Future<Map<String, dynamic>> fetchAndSet(http.Client client) async {
    if (client == null) {
      client = http.Client();
    }

    // Send the request
    final response = await client.get(
      url + '?ordering=-date',
      headers: <String, String>{
        'Authorization': 'Token ${auth.token}',
        'User-Agent': 'wger Workout Manager App',
      },
    );

    // Something wrong with our request
    if (response.statusCode >= 400) {
      throw WgerHttpException(response.body);
    }

    // Process the response
    return json.decode(response.body) as Map<String, dynamic>;
  }

  /// POSTs a new object
  Future<Map<String, dynamic>> add(Map<String, dynamic> data, http.Client client) async {
    if (client == null) {
      client = http.Client();
    }

    final response = await client.post(
      url,
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
  Future<Response> deleteRequest(int id, http.Client client) async {
    final response = await client.delete(
      '$url$id/',
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
