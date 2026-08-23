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
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:logging/logging.dart';
import 'package:wger/core/shared_preferences.dart';
import 'package:wger/features/account/models/user_profile.dart';
import 'package:wger/features/account/providers/user_profile_repository.dart';

const reportedTimezonePrefKey = 'reportedTimezone';

final timezoneSyncProvider = Provider<TimezoneSync>((ref) {
  return TimezoneSync(ref.read(userProfileRepositoryProvider));
});

Future<String> _detectDeviceTimezone() async {
  return (await FlutterTimezone.getLocalTimezone()).identifier;
}

/// Reports the device's IANA timezone to the user's profile.
///
/// Only overwrites what this client reported itself: an empty profile field is
/// filled, a field still holding our last reported zone follows a device move,
/// and anything else (set manually on the web, or reported by another device)
/// is left alone.
///
/// The last reported zone is kept in the preferences so that the common case,
/// the zone is unchanged, does nothing at all.
class TimezoneSync {
  final _logger = Logger('TimezoneSync');
  final UserProfileRepository _repo;
  final Future<String> Function() _detect;

  TimezoneSync(this._repo, {Future<String> Function()? detect})
    : _detect = detect ?? _detectDeviceTimezone;

  Future<void> reportIfNeeded() async {
    try {
      final detected = await _detect();
      if (detected.isEmpty) {
        return;
      }

      final prefs = PreferenceHelper.asyncPref;
      final lastReported = await prefs.getString(reportedTimezonePrefKey);
      if (lastReported == detected) {
        return;
      }

      // The profile row only exists once the first sync came through
      final profile = await _repo
          .watchDrift()
          .firstWhere((p) => p != null)
          .timeout(const Duration(minutes: 2));

      final current = profile!.timeZone ?? '';
      if (current == detected) {
        await prefs.setString(reportedTimezonePrefKey, detected);
        return;
      }

      if (current.isEmpty || current == lastReported) {
        _logger.info('Reporting device timezone $detected to the profile');
        await _repo.editLocalDrift(
          UserProfile(
            id: profile.id,
            weightUnitStr: profile.weightUnitStr,
            height: profile.height,
            timeZone: detected,
          ),
        );
        await prefs.setString(reportedTimezonePrefKey, detected);
      }
    } on Exception catch (e) {
      // Not critical, the next app start tries again
      _logger.fine('Timezone report skipped: $e');
    }
  }
}
