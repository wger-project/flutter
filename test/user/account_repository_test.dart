/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (c) 2026 wger Team
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

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:wger/providers/account_repository.dart';
import 'package:wger/providers/base_provider.dart';

import 'account_repository_test.mocks.dart';

@GenerateMocks([WgerBaseProvider])
void main() {
  late MockWgerBaseProvider mockBase;
  late AccountRepository repo;

  setUp(() {
    mockBase = MockWgerBaseProvider();
    repo = AccountRepository(mockBase);
  });

  group('fetchAccount', () {
    test('parses the API response into an Account', () async {
      final uri = Uri.https('localhost', 'api/v2/userprofile/');
      when(mockBase.makeUrl('userprofile')).thenReturn(uri);
      when(mockBase.fetch(uri)).thenAnswer(
        (_) async => {
          'username': 'admin',
          'email': 'me@example.com',
          'email_verified': true,
          'is_trustworthy': true,
        },
      );

      final account = await repo.fetchAccount();

      expect(account.username, 'admin');
      expect(account.email, 'me@example.com');
      expect(account.emailVerified, true);
      expect(account.isTrustworthy, true);
    });
  });

  group('verifyEmail', () {
    test('hits the verify-email subpath of userprofile', () async {
      final uri = Uri.https('localhost', 'api/v2/userprofile/verify-email/');
      when(
        mockBase.makeUrl('userprofile', objectMethod: 'verify-email'),
      ).thenReturn(uri);
      when(mockBase.fetch(uri)).thenAnswer((_) async => {});

      await repo.verifyEmail();

      verify(mockBase.fetch(uri)).called(1);
    });
  });
}
