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
import 'package:mockito/mockito.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:wger/core/shared_preferences.dart';
import 'package:wger/features/account/models/user_profile.dart';
import 'package:wger/features/account/providers/timezone_sync.dart';

import 'user_profile_notifier_test.mocks.dart';

const detected = 'Pacific/Auckland';

void main() {
  late MockUserProfileRepository mockRepo;

  TimezoneSync makeSync() => TimezoneSync(mockRepo, detect: () async => detected);

  void repoHasProfile(String? timeZone) {
    when(mockRepo.watchDrift()).thenAnswer(
      (_) => Stream.value(UserProfile(id: 1, weightUnitStr: 'kg', timeZone: timeZone)),
    );
  }

  setUp(() async {
    // PreferenceHelper.asyncPref is a singleton bound to the first platform
    // instance, so swapping the store is not enough: clear the key explicitly
    SharedPreferencesAsyncPlatform.instance = InMemorySharedPreferencesAsync.empty();
    await PreferenceHelper.asyncPref.remove(reportedTimezonePrefKey);
    mockRepo = MockUserProfileRepository();
    when(mockRepo.editLocalDrift(any)).thenAnswer((_) async {});
  });

  test('fills an empty profile field and remembers the report', () async {
    repoHasProfile('');

    await makeSync().reportIfNeeded();

    final written = verify(mockRepo.editLocalDrift(captureAny)).captured.single as UserProfile;
    expect(written.timeZone, detected);
    expect(await PreferenceHelper.asyncPref.getString(reportedTimezonePrefKey), detected);
  });

  test('a row synced before the column existed counts as empty', () async {
    repoHasProfile(null);

    await makeSync().reportIfNeeded();

    verify(mockRepo.editLocalDrift(any)).called(1);
  });

  test('an unchanged zone does not even read the profile', () async {
    await PreferenceHelper.asyncPref.setString(reportedTimezonePrefKey, detected);

    await makeSync().reportIfNeeded();

    verifyNever(mockRepo.watchDrift());
    verifyNever(mockRepo.editLocalDrift(any));
  });

  test('follows a device move when the profile still holds our old report', () async {
    await PreferenceHelper.asyncPref.setString(reportedTimezonePrefKey, 'America/Denver');
    repoHasProfile('America/Denver');

    await makeSync().reportIfNeeded();

    final written = verify(mockRepo.editLocalDrift(captureAny)).captured.single as UserProfile;
    expect(written.timeZone, detected);
  });

  test('leaves a zone alone that someone else set', () async {
    repoHasProfile('Europe/Berlin');

    await makeSync().reportIfNeeded();

    verifyNever(mockRepo.editLocalDrift(any));
    expect(await PreferenceHelper.asyncPref.getString(reportedTimezonePrefKey), null);
  });

  test('only remembers a zone the profile already matches', () async {
    repoHasProfile(detected);

    await makeSync().reportIfNeeded();

    verifyNever(mockRepo.editLocalDrift(any));
    expect(await PreferenceHelper.asyncPref.getString(reportedTimezonePrefKey), detected);
  });
}
