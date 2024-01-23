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

  final testMetadata = {'wger.check_min_app_version': 'true'};

  setUp(() {
    mockClient = MockClient();
    authProvider = AuthProvider(mockClient, false);
    authProvider.serverUrl = 'http://localhost';
  });

  group('min application version check', () {
    test('app version higher than min version', () async {
      // arrange
      when(mockClient.get(tVersionUri)).thenAnswer((_) => Future(() => Response('"1.2.0"', 200)));
      final updateNeeded = await authProvider.applicationUpdateRequired('1.3.0', testMetadata);

      // assert
      expect(updateNeeded, false);
    });

    test('app version higher than min version', () async {
      // arrange
      when(mockClient.get(tVersionUri)).thenAnswer((_) => Future(() => Response('"1.3"', 200)));
      final updateNeeded = await authProvider.applicationUpdateRequired('1.1', testMetadata);

      // assert
      expect(updateNeeded, true);
    });

    test('app version higher than min version', () async {
      // arrange
      when(mockClient.get(tVersionUri)).thenAnswer((_) => Future(() => Response('"1.3.0"', 200)));
      final updateNeeded = await authProvider.applicationUpdateRequired('1.1', testMetadata);

      // assert
      expect(updateNeeded, true);
    });

    test('app version equal as min version', () async {
      // arrange
      when(mockClient.get(tVersionUri)).thenAnswer((_) => Future(() => Response('"1.3.0"', 200)));
      final updateNeeded = await authProvider.applicationUpdateRequired('1.3.0', testMetadata);

      // assert
      expect(updateNeeded, false);
    });
  });
}
