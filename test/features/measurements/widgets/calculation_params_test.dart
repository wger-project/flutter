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
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:wger/core/network/network_provider.dart';
import 'package:wger/features/exercises/models/exercise.dart';
import 'package:wger/features/exercises/providers/exercise_repository.dart';
import 'package:wger/features/exercises/providers/exercises_notifier.dart';
import 'package:wger/features/measurements/models/measurement_calculation.dart';
import 'package:wger/features/measurements/models/measurement_category.dart';
import 'package:wger/features/measurements/providers/measurement_repository.dart';
import 'package:wger/features/measurements/widgets/calculation_params.dart';
import 'package:wger/l10n/generated/app_localizations.dart';

import '../../../../test_data/exercises.dart';
import '../../../helpers/fake_auth_environment.dart';
import '../../../helpers/measurement_repository_stubs.dart';
import 'calculation_params_test.mocks.dart';

@GenerateMocks([MeasurementRepository, ExerciseRepository])
void main() {
  // The exercise search reads the stored filters, which need the async
  // preferences platform in place
  installFakeAuthEnvironment();

  final waist = MeasurementCategory(id: 'waist', name: 'Waist', unit: 'cm');
  final weight = MeasurementCategory(id: 'weight', name: 'Weight', unit: 'kg');
  final bmi = MeasurementCategory(id: 'bmi', name: 'BMI', unit: '', dynamicType: 'BMI');

  late Map<String, dynamic> saved;

  setUp(() => saved = {});

  /// Renders the parameter block of [slug] over [categories] and [exercises],
  /// keeping what it writes back in [saved].
  Future<GlobalKey<FormState>> pump(
    WidgetTester tester,
    String slug, {
    List<MeasurementCategory> categories = const [],
    List<Exercise> exercises = const [],
    Map<String, dynamic> params = const {},
    String? categoryId,
  }) async {
    final measurementRepo = MockMeasurementRepository();
    stubMeasurementReads(measurementRepo, categories);
    final exerciseRepo = MockExerciseRepository();
    when(exerciseRepo.watchAllDrift()).thenAnswer((_) => Stream.value(ExerciseState(exercises)));

    saved = {...params};
    final formKey = GlobalKey<FormState>();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          measurementRepositoryProvider.overrideWithValue(measurementRepo),
          exerciseRepositoryProvider.overrideWithValue(exerciseRepo),
          // The search then reads the local catalogue instead of the API
          networkStatusProvider.overrideWithValue(false),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: Form(
              key: formKey,
              child: StatefulBuilder(
                builder: (context, setState) => SingleChildScrollView(
                  child: CalculationParamsBlock(
                    type: calculationTypeOf(slug)!,
                    params: saved,
                    categoryId: categoryId,
                    onChanged: (next) => setState(() => saved = next),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return formKey;
  }

  group('the category picker', () {
    testWidgets('shows what it cannot read instead of hiding it', (tester) async {
      await pump(
        tester,
        'WHTR',
        categories: [waist, weight, bmi],
      );

      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();

      // The unit next to a category is what the user has to change, so one
      // measured in kg is offered and disabled rather than left out
      expect(find.text('Waist (cm)'), findsWidgets);
      expect(find.text('Weight (kg)'), findsWidgets);
      final items = tester
          .widgetList<DropdownMenuItem<String>>(find.byType(DropdownMenuItem<String>))
          .toList();
      expect(
        {for (final item in items) item.value: item.enabled},
        containsPair('waist', true),
      );
      expect(
        {for (final item in items) item.value: item.enabled},
        containsPair('weight', false),
      );
      // A calculated category cannot feed another one at all
      expect(find.textContaining('BMI'), findsNothing);
    });

    testWidgets('leaves out the category being edited, which cannot feed itself', (tester) async {
      await pump(
        tester,
        'WHTR',
        categories: [waist],
        categoryId: 'waist',
      );

      expect(find.byType(DropdownButtonFormField<String>), findsNothing);
      expect(find.text('You have no other category to read from yet.'), findsOneWidget);
    });

    testWidgets('writes the picked category back', (tester) async {
      await pump(tester, 'WHTR', categories: [waist]);

      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Waist (cm)').last);
      await tester.pumpAndSettle();

      expect(saved['category_id'], 'waist');
    });

    testWidgets('an unset source fails validation', (tester) async {
      final formKey = await pump(tester, 'WHTR', categories: [waist]);

      expect(formKey.currentState!.validate(), isFalse);
    });
  });

  group('the exercise picker', () {
    // Local rather than the shared fixture: the ids are what the parameters
    // store, and the big-three uuid is what the prefill looks for
    final bench = testBenchPress.copyWith(id: 73, uuid: bigThreeUuids.first);
    final squat = testSquats.copyWith(id: 74, uuid: bigThreeUuids[1]);

    testWidgets('shows the stored ids as exercise names', (tester) async {
      await pump(
        tester,
        'ONE_REP_MAX',
        exercises: [bench],
        params: {'exercise_id': 73, 'max_reps': 5},
      );

      expect(find.text('Bench press'), findsOneWidget);
    });

    testWidgets('falls back to the id while the catalogue has not synced', (tester) async {
      await pump(
        tester,
        'ONE_REP_MAX',
        params: {'exercise_id': 73, 'max_reps': 5},
      );

      expect(find.text('#73'), findsOneWidget);
    });

    testWidgets('removing a chip clears the parameter', (tester) async {
      await pump(
        tester,
        'ONE_REP_MAX',
        exercises: [bench],
        params: {'exercise_id': 73, 'max_reps': 5},
      );

      await tester.tap(
        find.descendant(of: find.byType(InputChip), matching: find.byType(Icon)),
      );
      await tester.pumpAndSettle();

      expect(saved['exercise_id'], isNull);
    });

    testWidgets('picking an exercise twice does not count it twice', (tester) async {
      // The chips and the parameters come from one place, the form value from
      // another; a pick the parameters refuse must not reach the value either
      final formKey = await pump(
        tester,
        'ONE_RM_TOTAL',
        exercises: [bench, squat],
        params: {
          'exercise_ids': [73, 74],
          'max_reps': 5,
          'window_days': 30,
        },
      );

      for (var attempt = 0; attempt < 2; attempt++) {
        await tester.enterText(find.byKey(const Key('field-typeahead')), 'Bench');
        await tester.pump(const Duration(milliseconds: 600));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('exercise-73')));
        await tester.pumpAndSettle();
      }

      // What the form validates against and what gets stored are two objects,
      // so the invariant is that they say the same thing
      final field = tester.state<FormFieldState<List<int>>>(
        find.byType(FormField<List<int>>),
      );
      expect(field.value, [73, 74]);
      expect(saved['exercise_ids'], [73, 74]);
      expect(find.byType(InputChip), findsNWidgets(2));
      expect(formKey.currentState!.validate(), isTrue);
    });

    testWidgets('a total below its minimum fails validation', (tester) async {
      final formKey = await pump(
        tester,
        'ONE_RM_TOTAL',
        exercises: [bench],
        params: {
          'exercise_ids': [73],
          'max_reps': 5,
          'window_days': 30,
        },
      );

      expect(formKey.currentState!.validate(), isFalse);
    });

    testWidgets('a total within its bounds passes', (tester) async {
      final formKey = await pump(
        tester,
        'ONE_RM_TOTAL',
        exercises: [bench, squat],
        params: {
          'exercise_ids': [73, 74],
          'max_reps': 5,
          'window_days': 30,
        },
      );

      expect(formKey.currentState!.validate(), isTrue);
    });
  });

  group('the numbers', () {
    testWidgets('start at the server default, which is also the hint', (tester) async {
      await pump(tester, 'ONE_RM_TOTAL', params: defaultParams(calculationTypeOf('ONE_RM_TOTAL')!));

      // Written out rather than left absent: the server compares the stored
      // parameters, so an omitted value is a different configuration to it
      expect(saved['max_reps'], 5);
      expect(saved['window_days'], 30);
      // The text the fields actually hold, not the hint behind it, which
      // carries the same number
      final texts = tester
          .widgetList<EditableText>(find.byType(EditableText))
          .map((field) => field.controller.text);
      expect(texts, containsAll(['5', '30']));
      // The hint is what an emptied field falls back to showing
      final hints = tester
          .widgetList<TextField>(find.byType(TextField))
          .map((field) => field.decoration?.hintText);
      expect(hints, containsAll(['5', '30']));
    });

    testWidgets('an empty field passes and drops the parameter', (tester) async {
      final formKey = await pump(
        tester,
        'ONE_REP_MAX',
        params: {'exercise_id': 73, 'max_reps': 8},
      );

      await tester.enterText(find.byKey(const Key('calculation-param-max_reps')), '');
      await tester.pumpAndSettle();

      expect(saved.containsKey('max_reps'), isFalse);
      expect(formKey.currentState!.validate(), isTrue);
    });

    testWidgets('refuse a value the server would refuse', (tester) async {
      final formKey = await pump(
        tester,
        'ONE_REP_MAX',
        params: {'exercise_id': 73, 'max_reps': 5},
      );

      await tester.enterText(find.byKey(const Key('calculation-param-max_reps')), '11');
      await tester.pumpAndSettle();

      expect(formKey.currentState!.validate(), isFalse);
      expect(saved['max_reps'], 11);
    });

    testWidgets('take a value inside the bounds', (tester) async {
      await pump(
        tester,
        'ONE_REP_MAX',
        params: {'exercise_id': 73, 'max_reps': 5},
      );

      await tester.enterText(find.byKey(const Key('calculation-param-max_reps')), '3');
      await tester.pumpAndSettle();

      expect(saved['max_reps'], 3);
    });
  });
}
