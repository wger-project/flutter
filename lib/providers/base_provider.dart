/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (c) 2020 - 2026 wger Team
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

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'package:wger/core/exceptions/http_exception.dart';
import 'package:wger/providers/auth.dart';
import 'package:wger/providers/helpers.dart';

/// default timeout for GET requests
const DEFAULT_TIMEOUT = Duration(seconds: 15);

/// Base provider class.
///
/// Provides a couple of comfort functions so we avoid a bit of boilerplate.
class WgerBaseProvider {
  final _logger = Logger('WgerBaseProvider');

  AuthProvider auth;
  late http.Client client;

  WgerBaseProvider(this.auth, [http.Client? client]) {
    auth = auth;
    this.client = client ?? http.Client();
  }

  Map<String, String> getDefaultHeaders({bool includeAuth = false, String? language}) {
    final out = {
      HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
      HttpHeaders.userAgentHeader: auth.getAppNameHeader(),
    };

    if (includeAuth) {
      out[HttpHeaders.authorizationHeader] = 'Token ${auth.token}';
    }

    if (language != null) {
      out[HttpHeaders.acceptLanguageHeader] = language;
    }

    return out;
  }

  /// Helper function to make a URL.
  Uri makeUrl(String path, {int? id, String? objectMethod, Map<String, dynamic>? query}) {
    return makeUri(auth.serverUrl!, path, id, objectMethod, query);
  }

  /// Fetch and retrieve the overview list of objects, returns the JSON parsed response
  /// with a simple retry mechanism for transient errors.
  Future<dynamic> fetch(
    Uri uri, {
    int maxRetries = 3,
    Duration initialDelay = const Duration(milliseconds: 250),
    Duration timeout = DEFAULT_TIMEOUT,
    String? language,
  }) async {
    int attempt = 0;
    final random = math.Random();

    Future<void> wait(String reason) async {
      final backoff = (initialDelay.inMilliseconds * math.pow(2, attempt - 1)).toInt();
      final jitter = random.nextInt((backoff * 0.25).toInt() + 1); // up to 25% jitter
      final delay = backoff + jitter;
      _logger.info('Retrying fetch for $uri, attempt $attempt (${delay}ms), reason: $reason');

      await Future.delayed(Duration(milliseconds: delay));
    }

    while (true) {
      try {
        final response = await client
            .get(uri, headers: getDefaultHeaders(includeAuth: true, language: language))
            .timeout(timeout);

        if (response.statusCode >= 400) {
          // Retry on server errors (5xx); e.g. 502 might be transient
          if (response.statusCode >= 500 && attempt < maxRetries) {
            attempt++;
            await wait('status code ${response.statusCode}');
            continue;
          }
          throw WgerHttpException(response);
        }

        return json.decode(utf8.decode(response.bodyBytes)) as dynamic;
      } catch (e) {
        final isRetryable =
            e is SocketException || e is http.ClientException || e is TimeoutException;
        if (isRetryable && attempt < maxRetries) {
          attempt++;
          await wait(e.toString());
          continue;
        }

        rethrow;
      }
    }
  }

  /// Fetch and retrieve the overview list of objects, returns the JSON parsed response
  Future<List<dynamic>> fetchPaginated(
    Uri uri, {
    String? language,
    Duration timeout = DEFAULT_TIMEOUT,
  }) async {
    final out = [];
    var url = uri;
    var allPagesProcessed = false;

    while (!allPagesProcessed) {
      final data = await fetch(url, language: language, timeout: timeout);

      data['results'].forEach((e) => out.add(e));

      if (data['next'] == null) {
        allPagesProcessed = true;
      } else {
        url = Uri.parse(data['next']);
      }
    }

    return out;
  }

  /// POSTs a new object
  Future<Map<String, dynamic>> post(Map<String, dynamic> data, Uri uri) async {
    final response = await client.post(
      uri,
      headers: getDefaultHeaders(includeAuth: true),
      body: json.encode(data),
    );

    // Something wrong with our request
    if (response.statusCode >= 400) {
      throw WgerHttpException(response);
    }

    return json.decode(response.body);
  }

  /// PATCHEs an existing object
  Future<Map<String, dynamic>> patch(Map<String, dynamic> data, Uri uri) async {
    final response = await client.patch(
      uri,
      headers: getDefaultHeaders(includeAuth: true),
      body: json.encode(data),
    );

    // Something wrong with our request
    if (response.statusCode >= 400) {
      throw WgerHttpException(response);
    }

    return json.decode(response.body);
  }

  /// DELETEs an existing object
  Future<http.Response> deleteRequest(String url, int id) async {
    final deleteUrl = makeUrl(url, id: id);

    final response = await client.delete(
      deleteUrl,
      headers: getDefaultHeaders(includeAuth: true),
    );

    // Something wrong with our request
    if (response.statusCode >= 400) {
      throw WgerHttpException(response);
    }
    return response;
  }
}
