import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:mockito/mockito.dart';
import 'package:wger/providers/auth.dart';

import '../other/base_provider_test.mocks.dart';

void main() {
  late AuthProvider authProvider;
  late MockClient mockClient;

  final Uri tVersionUri = Uri(
    scheme: 'http',
    host: 'localhost',
    path: 'api/v2/min-app-version/',
  );

  setUp(() {
    mockClient = MockClient();
    authProvider = AuthProvider(mockClient);
    authProvider.serverUrl = 'http://localhost';
  });

  group('min application version check', () {
    test('app version higher than min version', () async {
      // arrange
      when(mockClient.get(tVersionUri)).thenAnswer((_) => Future(() => Response('"1.2.0"', 200)));
      final updateNeeded = await authProvider.applicationUpdateRequired('1.3.0');

      // assert
      expect(updateNeeded, false);
    });

    test('app version higher than min version - 1', () async {
      // arrange
      when(mockClient.get(tVersionUri)).thenAnswer((_) => Future(() => Response('"1.3"', 200)));
      final updateNeeded = await authProvider.applicationUpdateRequired('1.1');

      // assert
      expect(updateNeeded, true);
    });

    test('app version higher than min version - 2', () async {
      // arrange
      when(mockClient.get(tVersionUri)).thenAnswer((_) => Future(() => Response('"1.3.0"', 200)));
      final updateNeeded = await authProvider.applicationUpdateRequired('1.1');

      // assert
      expect(updateNeeded, true);
    });

    test('app version equal as min version', () async {
      // arrange
      when(mockClient.get(tVersionUri)).thenAnswer((_) => Future(() => Response('"1.3.0"', 200)));
      final updateNeeded = await authProvider.applicationUpdateRequired('1.3.0');

      // assert
      expect(updateNeeded, false);
    });
  });

  group('min server version check', () {
    test('server version greater than min — no update needed', () {
      authProvider.serverVersion = '2.5';
      expect(authProvider.serverUpdateRequired(), false);
    });

    test('server version equal to min — no update needed', () {
      authProvider.serverVersion = '2.4';
      expect(authProvider.serverUpdateRequired(), false);
    });

    test('server version less than min — update needed', () {
      authProvider.serverVersion = '2.3';
      expect(authProvider.serverUpdateRequired(), true);
    });

    test('server version with patch component less than min — update needed', () {
      authProvider.serverVersion = '2.3.9';
      expect(authProvider.serverUpdateRequired(), true);
    });

    test('server version with patch component greater than min — no update needed', () {
      authProvider.serverVersion = '2.4.1';
      expect(authProvider.serverUpdateRequired(), false);
    });

    test('null server version — returns false (lenient, no lockout)', () {
      authProvider.serverVersion = null;
      expect(authProvider.serverUpdateRequired(), false);
    });

    test('version override parameter is used instead of stored serverVersion', () {
      authProvider.serverVersion = '99.0'; // would normally not require update
      expect(authProvider.serverUpdateRequired('2.3'), true);
    });

    test('server version with pre-release suffix — still parsed correctly', () {
      authProvider.serverVersion = '2.5.0-beta';
      expect(authProvider.serverUpdateRequired(), false);
    });

    test('server version with Python alpha suffix (e.g. 2.5.0a2) — parsed correctly', () {
      authProvider.serverVersion = '2.5.0a2';
      expect(authProvider.serverUpdateRequired(), false); // 2.5.0 >= 2.4
    });

    test('server version with Python alpha suffix below min — blocked', () {
      authProvider.serverVersion = '2.3.0a2';
      expect(authProvider.serverUpdateRequired(), true); // 2.3.0 < 2.4
    });

    test('server version with build metadata suffix — still parsed correctly', () {
      authProvider.serverVersion = '2.3.0 (git-abc1234)';
      expect(authProvider.serverUpdateRequired(), true);
    });

    test('completely unparseable server version — returns false (lenient)', () {
      authProvider.serverVersion = 'unknown';
      expect(authProvider.serverUpdateRequired(), false);
    });
  });
}
