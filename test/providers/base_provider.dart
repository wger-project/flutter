/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (c)  2026 wger Team
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

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:wger/core/exceptions/http_exception.dart';
import 'package:wger/providers/base_provider.dart';

import '../utils.dart';
import 'base_provider.mocks.dart';

@GenerateMocks([Client])
void main() {
  final Uri testUri = Uri(scheme: 'https', host: 'localhost', path: 'api/v2/test/');

  test('Retry on SocketException then succeeds', () async {
    // Arrange
    final mockClient = MockClient();
    var callCount = 0;
    when(mockClient.get(testUri, headers: anyNamed('headers'))).thenAnswer((_) {
      if (callCount == 0) {
        callCount++;
        return Future.error(const SocketException('conn fail'));
      }
      return Future.value(Response('{"ok": true}', 200));
    });

    // Act
    final provider = WgerBaseProvider(testAuthProvider, mockClient);
    final result = await provider.fetch(testUri, initialDelay: const Duration(milliseconds: 1));

    // Assert
    expect(result, isA<Map>());
    expect(result['ok'], isTrue);
    verify(mockClient.get(testUri, headers: anyNamed('headers'))).called(2);
  });

  test('Retry on 5xx then succeeds', () async {
    // Arrange
    final mockClient = MockClient();
    var callCount = 0;
    when(mockClient.get(testUri, headers: anyNamed('headers'))).thenAnswer((_) {
      if (callCount == 0) {
        callCount++;
        return Future.value(Response('{"msg":"error"}', 502));
      }
      return Future.value(Response('{"ok": true}', 200));
    });

    // Act
    final provider = WgerBaseProvider(testAuthProvider, mockClient);
    final result = await provider.fetch(testUri, initialDelay: const Duration(milliseconds: 1));

    // Assert
    expect(result, isA<Map>());
    expect(result['ok'], isTrue);
    verify(mockClient.get(testUri, headers: anyNamed('headers'))).called(2);
  });

  test('Do not retry on 4xx client error', () async {
    // Arrange
    final mockClient = MockClient();
    when(
      mockClient.get(testUri, headers: anyNamed('headers')),
    ).thenAnswer((_) => Future.value(Response('{"error":"bad"}', 400)));

    // Act
    final provider = WgerBaseProvider(testAuthProvider, mockClient);

    // Assert
    await expectLater(
      provider.fetch(testUri, initialDelay: const Duration(milliseconds: 1)),
      throwsA(isA<WgerHttpException>()),
    );
    verify(mockClient.get(testUri, headers: anyNamed('headers'))).called(1);
  });

  test('Exceed max retries and rethrow after retries', () async {
    // Arrange
    final mockClient = MockClient();
    when(
      mockClient.get(testUri, headers: anyNamed('headers')),
    ).thenAnswer((_) => Future.error(ClientException('conn fail')));

    // Act
    final provider = WgerBaseProvider(testAuthProvider, mockClient);
    dynamic caught;
    try {
      await provider.fetch(testUri, initialDelay: const Duration(milliseconds: 1));
    } catch (e) {
      caught = e;
    }

    // Assert
    expect(caught, isA<ClientException>());
    // initial try + 3 retries = 4 calls
    verify(mockClient.get(testUri, headers: anyNamed('headers'))).called(4);
  });

  test('Request succeeds without retries', () async {
    // Arrange
    final mockClient = MockClient();
    when(
      mockClient.get(testUri, headers: anyNamed('headers')),
    ).thenAnswer((_) => Future.value(Response('{"ok": true}', 200)));

    // Act
    final provider = WgerBaseProvider(testAuthProvider, mockClient);
    final result = await provider.fetch(testUri);

    // Assert
    expect(result, isA<Map>());
    expect(result['ok'], isTrue);
    verify(mockClient.get(testUri, headers: anyNamed('headers'))).called(1);
  });
}
