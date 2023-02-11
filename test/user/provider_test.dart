/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (C) 2020, 2021 wger Team
 *
 * wger Workout Manager is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * wger Workout Manager is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:wger/providers/base_provider.dart';
import 'package:wger/providers/user.dart';

import '../fixtures/fixture_reader.dart';
import 'provider_test.mocks.dart';

@GenerateMocks([WgerBaseProvider])
void main() {
  late UserProvider userProvider;
  late MockWgerBaseProvider mockWgerBaseProvider;

  const String profileUrl = 'userprofile';
  final Map<String, dynamic> tUserProfileMap =
      jsonDecode(fixture('user/userprofile_response.json'));
  final Uri tProfileUri = Uri(
    scheme: 'http',
    host: 'localhost',
    path: 'api/v2/$profileUrl/',
  );
  final Uri tEmailVerifyUri = Uri(
    scheme: 'http',
    host: 'localhost',
    path: 'api/v2/$profileUrl/verify-email',
  );

  setUp(() {
    mockWgerBaseProvider = MockWgerBaseProvider();
    userProvider = UserProvider(mockWgerBaseProvider);

    when(mockWgerBaseProvider.makeUrl(any)).thenReturn(tProfileUri);
    when(mockWgerBaseProvider.makeUrl(any, objectMethod: 'verify-email'))
        .thenReturn(tEmailVerifyUri);
    when(mockWgerBaseProvider.fetch(any))
        .thenAnswer((realInvocation) => Future.value(tUserProfileMap));
  });

  group('house keeping', () {
    test('should clear the profile list with clear()', () async {
      // arrange
      await userProvider.fetchAndSetProfile();

      // assert
      expect(userProvider.profile, isNot(null));
      expect(userProvider.profile!.username, 'admin');

      // act
      userProvider.clear();

      // assert
      expect(userProvider.profile, null);
    });
  });

  group('profile', () {
    test('Loading the profile from the server works', () async {
      // arrange
      await userProvider.fetchAndSetProfile();

      // assert
      expect(userProvider.profile!.username, 'admin');
      expect(userProvider.profile!.emailVerified, true);
      expect(userProvider.profile!.email, 'me@example.com');
      expect(userProvider.profile!.isTrustworthy, true);
    });

    test('Sending the verify email works', () async {
      // arrange
      await userProvider.fetchAndSetProfile();
      await userProvider.verifyEmail();

      // assert
      verify(userProvider.baseProvider.fetch(tEmailVerifyUri));
    });
  });
}
