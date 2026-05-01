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
import 'package:wger/providers/base_provider.dart';
import 'package:wger/providers/user_profile_repository.dart';

import '../../test_data/profile.dart';
import 'user_profile_repository_test.mocks.dart';

@GenerateMocks([WgerBaseProvider])
void main() {
  late MockWgerBaseProvider mockBase;
  late UserProfileRepository repo;

  setUp(() {
    mockBase = MockWgerBaseProvider();
    repo = UserProfileRepository(mockBase);
  });

  group('fetchProfile', () {
    test('parses the API response into a Profile', () async {
      final uri = Uri.https('localhost', 'api/v2/userprofile/');
      when(mockBase.makeUrl('userprofile')).thenReturn(uri);
      when(mockBase.fetch(uri)).thenAnswer((_) async => tProfile1.toJson());

      final profile = await repo.fetchProfile();

      expect(profile.username, tProfile1.username);
      expect(profile.email, tProfile1.email);
      expect(profile.emailVerified, tProfile1.emailVerified);
    });
  });

  group('saveProfile', () {
    test('POSTs the serialized profile to the userprofile endpoint', () async {
      final uri = Uri.https('localhost', 'api/v2/userprofile/');
      when(mockBase.makeUrl('userprofile')).thenReturn(uri);
      when(mockBase.post(any, uri)).thenAnswer((_) async => {});

      await repo.saveProfile(tProfile1);

      verify(mockBase.post(tProfile1.toJson(), uri)).called(1);
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
