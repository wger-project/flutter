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

  group('email management via headless', () {
    final emailUri = Uri.https('localhost', '/allauth/app/v1/account/email');

    test('requestEmailChange POSTs the new address to account/email', () async {
      when(mockBase.makeHeadlessUrl('account/email')).thenReturn(emailUri);
      when(mockBase.post(any, emailUri)).thenAnswer((_) async => {});

      await repo.requestEmailChange('new@example.com');

      verify(mockBase.post({'email': 'new@example.com'}, emailUri)).called(1);
    });

    test('resendVerification PUTs the address to account/email', () async {
      when(mockBase.makeHeadlessUrl('account/email')).thenReturn(emailUri);
      when(mockBase.put(any, emailUri)).thenAnswer((_) async => {});

      await repo.resendVerification('old@example.com');

      verify(mockBase.put({'email': 'old@example.com'}, emailUri)).called(1);
    });
  });
}
