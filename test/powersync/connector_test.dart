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
import 'package:wger/powersync/connector.dart';

void main() {
  late DjangoConnector connector;

  setUp(() {
    connector = DjangoConnector(baseUrl: 'http://example.invalid');
  });

  group('genericTransform', () {
    test('injects the row id and copies all fields', () {
      final out = connector.genericTransform(
        'manager_workoutsession',
        {'notes': 'leg day', 'impression': 1},
        '42',
      );
      expect(out, {'id': '42', 'notes': 'leg day', 'impression': 1});
    });

    test('strips the `_id` suffix from foreign-key column names', () {
      final out = connector.genericTransform(
        'manager_workoutsession',
        {'routine_id': 7, 'notes': 'x'},
        '1',
      );
      expect(out['routine'], 7);
      expect(out.containsKey('routine_id'), isFalse);
    });

    test('handles null opData (delete events)', () {
      final out = connector.genericTransform('manager_routine', null, '99');
      expect(out, {'id': '99'});
    });

    group('date-only field trimming', () {
      test('strips the time component on `manager_routine.start`/`end`', () {
        final out = connector.genericTransform(
          'manager_routine',
          {
            'name': 'Push pull',
            'start': '2024-11-01T00:00:00.000Z',
            'end': '2024-12-01T00:00:00.000Z',
            'created': '2024-10-30T10:15:00.000Z',
          },
          '5',
        );
        // Date-only columns get trimmed so Django's DateField accepts them.
        expect(out['start'], '2024-11-01');
        expect(out['end'], '2024-12-01');
        // Other ISO timestamps (DateTimeField on Django) stay intact.
        expect(out['created'], '2024-10-30T10:15:00.000Z');
      });

      test('strips the time component on `manager_workoutsession.date`', () {
        final out = connector.genericTransform(
          'manager_workoutsession',
          {
            'date': '2024-11-01T00:00:00.000Z',
            'notes': 'felt great',
            'impression': '1',
          },
          '12',
        );
        expect(out['date'], '2024-11-01');
        expect(out['notes'], 'felt great');
      });

      test('strips the time component on `nutrition_nutritionplan.start`/`end`', () {
        final out = connector.genericTransform(
          'nutrition_nutritionplan',
          {
            'description': 'Cut',
            'start': '2024-11-01T00:00:00.000Z',
            'end': '2024-12-01T00:00:00.000Z',
            'creation_date': '2024-10-30T10:15:00.000Z',
          },
          '8',
        );
        expect(out['start'], '2024-11-01');
        expect(out['end'], '2024-12-01');
        expect(out['creation_date'], '2024-10-30T10:15:00.000Z');
      });

      test('does not touch DateTimeField columns even on registered tables', () {
        // `manager_workoutlog.date` is a DateTimeField on Django (not a
        // DateField), and `manager_workoutlog` isn't in the date-only
        // registry — the timestamp must round-trip unchanged.
        final out = connector.genericTransform(
          'manager_workoutlog',
          {'date': '2024-11-01T17:30:00.000Z'},
          '1',
        );
        expect(out['date'], '2024-11-01T17:30:00.000Z');
      });

      test('passes nulls through (open-ended end date)', () {
        final out = connector.genericTransform(
          'nutrition_nutritionplan',
          {'start': '2024-11-01T00:00:00.000Z', 'end': null},
          '8',
        );
        expect(out['start'], '2024-11-01');
        expect(out['end'], isNull);
      });
    });
  });
}
