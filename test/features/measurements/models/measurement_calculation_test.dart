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

import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wger/features/measurements/models/measurement_calculation.dart';
import 'package:wger/features/measurements/models/measurement_category.dart';
import 'package:wger/l10n/generated/app_localizations.dart';

void main() {
  group('the table', () {
    test('holds exactly the calculations the server registers', () {
      // Mirrors wger/measurements/dynamic/types.py: a slug this release does
      // not know is rendered read-only, one the server dropped is offered in
      // the form and refused on save
      expect(calculationTypes.map((t) => t.slug), ['BMI', 'WHTR', 'ONE_REP_MAX', 'ONE_RM_TOTAL']);
    });

    test('bounds the numbers the way the server does', () {
      final total = calculationTypeOf('ONE_RM_TOTAL')!;
      final exercises = total.params.whereType<ExercisesParam>().single;
      final byKey = {for (final p in total.params.whereType<IntParam>()) p.key: p};

      expect((exercises.minItems, exercises.maxItems), (2, 5));
      expect((byKey['max_reps']!.min, byKey['max_reps']!.max), (1, 10));
      expect((byKey['window_days']!.min, byKey['window_days']!.max), (7, 120));
    });
  });

  group('calculationTypeOf', () {
    test('resolves a known slug', () {
      expect(calculationTypeOf('WHTR')?.params.single, isA<CategoryParam>());
    });

    test('returns null for a slug from a newer server', () {
      expect(calculationTypeOf('FFMI'), isNull);
    });
  });

  group('isKnownCalculation', () {
    test('accepts a hand-kept category', () {
      expect(isKnownCalculation(noDynamicType), isTrue);
    });

    test('accepts a calculation this release renders', () {
      expect(isKnownCalculation('BMI'), isTrue);
    });

    test('refuses one it does not, so its parameters are left alone', () {
      expect(isKnownCalculation('NAVY_BODY_FAT'), isFalse);
    });
  });

  group('the labels', () {
    testWidgets('name a calculation this release does not know by its slug', (tester) async {
      // Rather than by whichever case the switch happens to end on: a type
      // added to the table without a string would otherwise show a wrong name
      late BuildContext ctx;
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) {
              ctx = context;
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      const unknown = CalculationType(slug: 'FFMI', unit: 'kg/m²', params: []);
      expect(unknown.localizedName(ctx), 'FFMI');
      expect(unknown.localizedDescription(ctx), isNull);
      expect(const ExerciseParam('exercise_id').localizedLabel(ctx), 'exercise_id');
      expect(calculationTypeOf('ONE_RM_TOTAL')!.localizedName(ctx), 'One-rep max total');
    });
  });

  group('defaultParams', () {
    test('is empty for a calculation without parameters', () {
      expect(defaultParams(calculationTypeOf('BMI')!), isEmpty);
    });

    test('writes the numbers out, so two clients store the same thing', () {
      // The server compares the parameters as stored, so an omitted value and
      // a typed default would read as two configurations
      expect(defaultParams(calculationTypeOf('ONE_RM_TOTAL')!), {
        'exercise_ids': <int>[],
        'max_reps': 5,
        'window_days': 30,
      });
    });

    test('leaves a reference unset rather than guessing one', () {
      expect(defaultParams(calculationTypeOf('WHTR')!), {'category_id': null});
    });
  });

  group('CategoryParam.accepts', () {
    final param = calculationTypeOf('WHTR')!.params.whereType<CategoryParam>().single;

    test('takes every length unit the server converts', () {
      // Mirrors LENGTH_UNITS in measurements/dynamic/types.py
      for (final unit in ['mm', 'cm', 'm', 'meters', 'in', 'inches', '"', '\u2033']) {
        expect(param.accepts(unit), isTrue, reason: unit);
      }
    });

    test('ignores case, padding and the dot of an abbreviation', () {
      expect(param.accepts(' CM '), isTrue);
      expect(param.accepts('cm.'), isTrue);
    });

    test('refuses a unit that is not a length', () {
      expect(param.accepts('kg'), isFalse);
      expect(param.accepts(''), isFalse);
    });
  });

  group('the big three', () {
    test('are the three uuids the server ships them under', () {
      expect(bigThreeUuids, hasLength(3));
      expect(bigThreeUuids.toSet(), hasLength(3));
    });
  });
}
