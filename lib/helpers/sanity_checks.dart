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
}) async {
  try {
    final baseUri = Uri.parse(baseUrl);
    final expectedHost = baseUri.host;
    final expectedPort = baseUri.port;
    final expectedScheme = baseUri.scheme;

    final response = await http.get(
      Uri.parse('$baseUrl/api/v2/exercise/?limit=1'),
      headers: {
        'Authorization': 'Token $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      return const SanityCheckResult(
        isValid: false,
        message: 'Could not reach server endpoint',
      );
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final nextUrl = data['next'] as String?;

    if (nextUrl == null) {
      return const SanityCheckResult(isValid: true);
    }

    final nextUri = Uri.parse(nextUrl);

    if (nextUri.host != expectedHost) {
      return SanityCheckResult(
        isValid: false,
        message:
            'Server misconfiguration detected!\n\n'
            'You are connecting to: $expectedScheme://$expectedHost${expectedPort != 0 ? ":$expectedPort" : ""}\n'
            'But pagination links point to: ${nextUri.scheme}://${nextUri.host}${nextUri.hasPort ? ":${nextUri.port}" : ""}\n\n'
            'This usually means your reverse proxy is not configured correctly.',
        detectedUrl: nextUrl,
      );
    }

    if (nextUri.scheme != expectedScheme) {
      return SanityCheckResult(
        isValid: false,
        message:
            'Protocol mismatch detected!\n\n'
            'You are using: $expectedScheme\n'
            'But server returns: ${nextUri.scheme}',
        detectedUrl: nextUrl,
      );
    }

    return const SanityCheckResult(isValid: true);
  } catch (e) {
    return SanityCheckResult(
      isValid: false,
      message: 'Error checking server configuration: $e',
    );
  }
}

/// Result of a server sanity check
class SanityCheckResult {
  const SanityCheckResult({
    required this.isValid,
    this.message,
    this.detectedUrl,
  });

  final bool isValid;
  final String? message;
  final String? detectedUrl;
}
