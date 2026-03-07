/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (c) 2025 wger Team
 *
 * wger Workout Manager is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 */

import 'dart:convert';
import 'package:http/http.dart' as http;

/// Checks if the server's reverse proxy is configured correctly
/// by comparing pagination URLs with the base URL domain.
Future<SanityCheckResult> checkServerPaginationUrls({
  required String baseUrl,
  required String token,
  http.Client? client,
}) async {
  final httpClient = client ?? http.Client();

  try {
    final baseUri = Uri.parse(baseUrl);
    final expectedHost = baseUri.host;
    final expectedScheme = baseUri.scheme;

    final response = await httpClient.get(
      Uri.parse('$baseUrl/api/v2/exercise/?limit=1'),
      headers: {
        'Authorization': 'Token $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      return const SanityCheckResult(isValid: false);
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final nextUrl = data['next'] as String?;

    if (nextUrl == null) {
      return const SanityCheckResult(isValid: true);
    }

    final nextUri = Uri.parse(nextUrl);

    if (nextUri.host != expectedHost || nextUri.scheme != expectedScheme) {
      return const SanityCheckResult(isValid: false);
    }

    return const SanityCheckResult(isValid: true);
  } catch (e) {
    return const SanityCheckResult(isValid: false);
  }
}

/// Result of a server sanity check
class SanityCheckResult {
  const SanityCheckResult({
    required this.isValid,
  });

  final bool isValid;
}
