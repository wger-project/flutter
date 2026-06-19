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

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:wger/models/user/user_profile.dart';
import 'package:wger/providers/user_profile_notifier.dart';
import 'package:wger/providers/user_profile_repository.dart';

import 'user_profile_notifier_test.mocks.dart';

@GenerateMocks([UserProfileRepository])
void main() {
  late MockUserProfileRepository mockRepo;

  setUp(() {
    mockRepo = MockUserProfileRepository();
    // Default: empty stream that never emits. Tests that need a value seed it
    // through [containerWithProfile].
    when(mockRepo.watchDrift()).thenAnswer((_) => const Stream.empty());
    when(mockRepo.editLocalDrift(any)).thenAnswer((_) async {});
  });

  ProviderContainer makeContainer() => ProviderContainer.test(
    overrides: [userProfileRepositoryProvider.overrideWithValue(mockRepo)],
  );

  Future<ProviderContainer> containerWithProfile(UserProfile? profile) async {
    when(mockRepo.watchDrift()).thenAnswer((_) => Stream.value(profile));
    final container = makeContainer();
    container.listen(userProfileProvider, (_, _) {});
    await pumpEventQueue();
    return container;
  }

  test('build streams the profile from the repository', () async {
    final container = await containerWithProfile(
      UserProfile(id: 1, weightUnitStr: 'kg'),
    );

    final profile = container.read(userProfileProvider).requireValue;
    expect(profile!.weightUnitStr, 'kg');
    verify(mockRepo.watchDrift()).called(1);
  });

  test('build emits null until the profile has synced', () async {
    final container = await containerWithProfile(null);

    expect(container.read(userProfileProvider).requireValue, isNull);
  });

  test('updateProfile forwards to the repository', () async {
    final container = makeContainer();
    final profile = UserProfile(id: 1, weightUnitStr: 'lb');

    await container.read(userProfileProvider.notifier).updateProfile(profile);

    verify(mockRepo.editLocalDrift(profile)).called(1);
  });
}
