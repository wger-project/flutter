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

import 'package:flutter_test/flutter_test.dart';
import 'package:wger/features/routines/models/session.dart';
import 'package:wger/features/routines/validators.dart';
import 'package:wger/l10n/generated/app_localizations_en.dart';

void main() {
  final i18n = AppLocalizationsEn();
  final start = DateTime(2026, 5, 4, 18, 0);

  String? validate(DateTime? end) =>
      validateWorkoutSessionTimes(datetimeStart: start, datetimeEnd: end, i18n: i18n);

  group('validateWorkoutLogCrossField', () {
    test('a log needs a repetition count or a weight', () {
      expect(
        validateWorkoutLogCrossField(repetitions: null, weight: null, i18n: i18n),
        i18n.weightOrRepsRequired,
      );
    });

    test('either one on its own is enough', () {
      expect(validateWorkoutLogCrossField(repetitions: 8, weight: null, i18n: i18n), isNull);
      expect(validateWorkoutLogCrossField(repetitions: null, weight: 60, i18n: i18n), isNull);
      expect(validateWorkoutLogCrossField(repetitions: 8, weight: 60, i18n: i18n), isNull);
    });
  });

  group('validateWorkoutSessionTimes', () {
    test('a session that is still running has nothing to compare', () {
      expect(validate(null), isNull);
    });

    test('an end after the start passes', () {
      expect(validate(start.add(const Duration(hours: 1))), isNull);
    });

    test('an end before the start is refused', () {
      expect(validate(start.subtract(const Duration(minutes: 30))), i18n.timeStartAhead);
    });

    test('a session running past midnight ends on the next day, not before its start', () {
      // 18:00 to 00:30 is six and a half hours on the following day
      expect(validate(DateTime(2026, 5, 5, 0, 30)), i18n.sessionTooLong(5));
      expect(validate(DateTime(2026, 5, 4, 23, 0)), isNull);
    });

    test('the longest allowed session is exactly the maximum', () {
      // The bound the server enforces as WGER_MAX_SESSION_LENGTH_HOURS
      expect(validate(start.add(sessionMaxDuration)), isNull);
    });

    test('a minute over the maximum is refused', () {
      expect(
        validate(start.add(sessionMaxDuration + const Duration(minutes: 1))),
        i18n.sessionTooLong(sessionMaxDuration.inHours),
      );
    });

    test('the message names the hours the server allows', () {
      expect(validate(start.add(const Duration(hours: 9))), contains('5'));
    });
  });
}
