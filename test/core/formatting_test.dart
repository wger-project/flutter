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
import 'package:material_ui/material_ui.dart';
import 'package:wger/core/formatting/formatting.dart';
import 'package:wger/l10n/generated/app_localizations.dart';

void main() {
  group('hoursAndMinutes', () {
    test('splits the minutes into hours and minutes', () {
      expect(hoursAndMinutes(452, 'en'), '7:32');
    });

    test('pads the minutes so the values line up', () {
      expect(hoursAndMinutes(425, 'en'), '7:05');
    });

    test('keeps a duration below an hour in the same shape', () {
      expect(hoursAndMinutes(45, 'en'), '0:45');
    });

    test('rounds to whole minutes', () {
      expect(hoursAndMinutes(59.6, 'en'), '1:00');
    });

    test('keeps the sign of a negative change', () {
      expect(hoursAndMinutes(-95, 'en'), '-1:35');
    });

    test('takes the digits from the locale', () {
      expect(hoursAndMinutes(452, 'fa'), '۷:۳۲');
    });
  });

  group('valueAxis', () {
    test('leaves an ordinary spread to the chart', () {
      expect(valueAxis('kg', 80, 92), isNull);
    });

    test('reads a duration in hours', () {
      // The duration axis keeps deciding for its own unit
      expect(valueAxis('min', 0, 300)?.interval, durationAxis('min', 0, 300)?.interval);
    });

    test('gives a flat series room around it', () {
      // Every reading the same: fl_chart would divide a range of nothing into
      // steps below the value's own precision and never finish walking it
      final axis = valueAxis('kg', 111.18, 111.18)!;

      expect(axis.min, lessThan(111.18));
      expect(axis.max, greaterThan(111.18));
      expect(axis.interval, isNull);
    });

    test('counts a spread of rounding errors as flat', () {
      // What an average over identical values produces
      final axis = valueAxis('kg', 111.17999999999999, 111.18)!;

      expect(axis.max - axis.min, greaterThan(1));
    });

    test('keeps a small but real spread', () {
      // A ratio moves in the third decimal and still means something
      expect(valueAxis('', 0.470, 0.471), isNull);
    });

    test('has room to show even a flat zero', () {
      final axis = valueAxis('kg', 0, 0)!;

      expect(axis.min, lessThan(0));
      expect(axis.max, greaterThan(0));
    });
  });

  group('durationAxis', () {
    test('leaves the ticks to the chart for every other unit', () {
      expect(durationAxis('kg', 60, 100), isNull);
    });

    test('puts every tick on a whole hour', () {
      final axis = durationAxis('min', 0, 300)!;

      expect(axis.interval, 60);
      expect(axis.min, 0);
      expect(axis.max, 300);
    });

    test('widens the interval until the ticks are few enough', () {
      expect(durationAxis('min', 0, 540)!.interval, 120);
    });

    test('keeps the bounds from cutting the values they were derived from', () {
      expect(durationAxis('min', 0, 540)!.max, greaterThanOrEqualTo(540));
    });

    test('starts at the hour below the data instead of at zero', () {
      expect(durationAxis('min', 385, 460)!.min, 360);
    });
  });

  group('measurementUnit', () {
    test('reads a duration in hours', () {
      expect(measurementUnit('min'), 'h');
    });

    test('leaves every other unit alone', () {
      expect(measurementUnit('kg'), 'kg');
    });
  });

  group('relativeDate', () {
    final today = DateTime(2026, 8, 8, 14, 30);

    /// [relativeDate] for a date [daysAgo] days back, read in [locale].
    Future<String> phraseFor(WidgetTester tester, int daysAgo, {String locale = 'en'}) async {
      late String phrase;
      await tester.pumpWidget(
        MaterialApp(
          locale: Locale(locale),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) {
              phrase = relativeDate(
                context,
                DateTime(today.year, today.month, today.day - daysAgo, 6),
                now: today,
              );
              return const SizedBox();
            },
          ),
        ),
      );
      await tester.pumpAndSettle();
      return phrase;
    }

    testWidgets('names the days close by instead of counting them', (tester) async {
      expect(await phraseFor(tester, 0), 'today');
      expect(await phraseFor(tester, 1), 'yesterday');
      expect(await phraseFor(tester, 3), '3 days ago');
    });

    testWidgets('the unit grows with the distance', (tester) async {
      expect(await phraseFor(tester, 21), '3 weeks ago');
      expect(await phraseFor(tester, 60), '2 months ago');
      expect(await phraseFor(tester, 400), '1 year ago');
    });

    testWidgets('counts calendar days, so this morning still reads as yesterday', (tester) async {
      // The entry is 20 hours old but fell on yesterday's calendar day
      late String phrase;
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) {
              phrase = relativeDate(
                context,
                DateTime(2026, 8, 7, 18),
                now: DateTime(2026, 8, 8, 9),
              );
              return const SizedBox();
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(phrase, 'yesterday');
    });

    testWidgets('a date ahead of now reads as today rather than counting down', (tester) async {
      // Only reachable through clock skew between devices, and the plural
      // messages have no phrases for it: "-1 days ago" is what it used to say
      expect(await phraseFor(tester, -1), 'today');
      expect(await phraseFor(tester, -10), 'today');
      expect(await phraseFor(tester, -400), 'today');
    });

    testWidgets('speaks the locale it is read in', (tester) async {
      expect(await phraseFor(tester, 0, locale: 'de'), 'heute');
      expect(await phraseFor(tester, 21, locale: 'de'), 'vor 3 Wochen');
    });
  });
}
