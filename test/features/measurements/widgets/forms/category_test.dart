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
import 'package:material_ui/material_ui.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:wger/features/account/models/user_profile.dart';
import 'package:wger/features/account/providers/user_profile_repository.dart';
import 'package:wger/features/exercises/providers/exercise_repository.dart';
import 'package:wger/features/exercises/providers/exercises_notifier.dart';
import 'package:wger/features/measurements/models/measurement_calculation.dart';
import 'package:wger/features/measurements/models/measurement_category.dart';
import 'package:wger/features/measurements/providers/measurement_repository.dart';
import 'package:wger/features/measurements/widgets/forms/category.dart';
import 'package:wger/l10n/generated/app_localizations.dart';

import '../../../../../test_data/exercises.dart';
import '../../../../../test_data/measurements.dart';
import '../../../../helpers/fake_auth_environment.dart';
import '../../../../helpers/measurement_repository_stubs.dart';
import 'category_test.mocks.dart';

@GenerateMocks([MeasurementRepository, ExerciseRepository, UserProfileRepository])
void main() {
  // The exercise search reads the stored filters, which need the async
  // preferences platform in place
  installFakeAuthEnvironment();

  late MockMeasurementRepository mockRepo;
  late MockExerciseRepository mockExerciseRepo;
  late MockUserProfileRepository mockProfileRepo;

  setUp(() {
    mockRepo = MockMeasurementRepository();
    stubMeasurementReads(mockRepo, []);
    mockExerciseRepo = MockExerciseRepository();
    when(mockExerciseRepo.watchAllDrift()).thenAnswer((_) => Stream.value(ExerciseState(const [])));
    mockProfileRepo = MockUserProfileRepository();
    when(
      mockProfileRepo.watchDrift(),
    ).thenAnswer((_) => Stream.value(UserProfile(id: 1, weightUnitStr: 'kg', height: 182)));
  });

  /// The form as the app shows it: the screen hands it the space and the form
  /// brings its own scrolling, see FormScreenArguments.hasListView
  Widget wrap(Widget child) {
    return ProviderScope(
      overrides: [
        measurementRepositoryProvider.overrideWithValue(mockRepo),
        exerciseRepositoryProvider.overrideWithValue(mockExerciseRepo),
        userProfileRepositoryProvider.overrideWithValue(mockProfileRepo),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: child),
      ),
    );
  }

  group('MeasurementCategoryForm validation', () {
    testWidgets('empty name fails validation', (tester) async {
      await tester.pumpWidget(wrap(const MeasurementCategoryForm()));
      await tester.pumpAndSettle();

      // Tap save without entering any text
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // Check for validation errors.
      final error = find.byWidgetPredicate((widget) {
        if (widget is TextField) {
          return widget.decoration?.errorText != null;
        }
        return false;
      });
      expect(error, findsAtLeastNWidgets(1));
    });

    testWidgets('empty unit field fails validation', (tester) async {
      await tester.pumpWidget(wrap(const MeasurementCategoryForm()));
      await tester.pumpAndSettle();

      // Fill name but leave unit empty
      await tester.enterText(find.byType(TextFormField).first, 'Body fat');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // still on same screen
      expect(find.byType(MeasurementCategoryForm), findsOneWidget);
    });

    testWidgets('the metric type is not offered', (tester) async {
      // It is picked when the category is created and immutable from then on,
      // the server refuses a change
      await tester.pumpWidget(wrap(const MeasurementCategoryForm()));
      await tester.pumpAndSettle();

      expect(find.byType(DropdownButtonFormField<MetricType>), findsNothing);
    });

    testWidgets('a typed category has neither a name nor a unit field', (tester) async {
      final typed = getMeasurementCategories()[1].copyWith(metricType: MetricType.heartRate);

      await tester.pumpWidget(wrap(MeasurementCategoryForm(typed)));
      await tester.pumpAndSettle();

      // Both come from the metric type, which is also what is displayed
      expect(find.byType(TextFormField), findsNothing);
      expect(find.byType(DropdownButtonFormField<ChartType>), findsOneWidget);
    });

    testWidgets('a category with children gets no chart type picker', (tester) async {
      // Its chart follows from what its components are to each other, which is
      // what buildGroupChart decides; a pick would have no effect
      final parent = getMeasurementCategories()[1];
      final child = getMeasurementCategories()[0].copyWith(parentId: parent.id);
      stubMeasurementReads(mockRepo, [parent, child]);

      await tester.pumpWidget(wrap(MeasurementCategoryForm(parent)));
      await tester.pumpAndSettle();

      expect(find.byType(DropdownButtonFormField<ChartType>), findsNothing);
    });

    testWidgets('a leaf category gets the chart type picker', (tester) async {
      final category = getMeasurementCategories()[1];
      stubMeasurementReads(mockRepo, [category]);

      await tester.pumpWidget(wrap(MeasurementCategoryForm(category)));
      await tester.pumpAndSettle();

      expect(find.byType(DropdownButtonFormField<ChartType>), findsOneWidget);
    });

    testWidgets('a leaf category gets the line chart settings', (tester) async {
      final category = getMeasurementCategories()[1];
      stubMeasurementReads(mockRepo, [category]);

      await tester.pumpWidget(wrap(MeasurementCategoryForm(category)));
      await tester.pumpAndSettle();

      expect(find.byType(DropdownButtonFormField<TrendCharacter>), findsOneWidget);
      expect(find.byType(DropdownButtonFormField<Object>), findsOneWidget);
    });

    testWidgets('a summed type has no line to configure', (tester) async {
      // Its chart is one bar per day, which has neither a trend nor an
      // average, and no pick can turn it into a line
      final steps = getMeasurementCategories()[1].copyWith(metricType: MetricType.steps);
      stubMeasurementReads(mockRepo, [steps]);

      await tester.pumpWidget(wrap(MeasurementCategoryForm(steps)));
      await tester.pumpAndSettle();

      expect(find.byType(DropdownButtonFormField<TrendCharacter>), findsNothing);
      expect(find.byType(DropdownButtonFormField<Object>), findsNothing);
    });

    testWidgets('the line settings are disabled for a chart without a line', (tester) async {
      // Kept rather than hidden: switching the chart type back applies them
      // again, and a field that vanishes takes the reason with it
      final category = getMeasurementCategories()[1].copyWith(chartType: ChartType.delta);
      stubMeasurementReads(mockRepo, [category]);

      await tester.pumpWidget(wrap(MeasurementCategoryForm(category)));
      await tester.pumpAndSettle();

      expect(
        tester
            .widget<DropdownButtonFormField<TrendCharacter>>(
              find.byType(DropdownButtonFormField<TrendCharacter>),
            )
            .onChanged,
        isNull,
      );
      expect(
        tester
            .widget<DropdownButtonFormField<Object>>(
              find.byType(DropdownButtonFormField<Object>),
            )
            .onChanged,
        isNull,
      );
    });

    testWidgets('both lines of the chart can be turned off', (tester) async {
      final category = getMeasurementCategories()[1].copyWith(chartType: ChartType.auto);
      stubMeasurementReads(mockRepo, [category]);

      await tester.pumpWidget(wrap(MeasurementCategoryForm(category)));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(DropdownButtonFormField<TrendCharacter>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Off').last);
      await tester.pumpAndSettle();

      await tester.tap(find.byType(DropdownButtonFormField<Object>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Off').last);
      await tester.pumpAndSettle();

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      final saved =
          verify(mockRepo.updateLocalDriftCategory(captureAny)).captured.single
              as MeasurementCategory;
      expect(saved.chartConfig, {'trend': 'none', 'average_window': 'none'});
    });

    testWidgets('the line settings are enabled while the chart is a line', (tester) async {
      final category = getMeasurementCategories()[1].copyWith(chartType: ChartType.auto);
      stubMeasurementReads(mockRepo, [category]);

      await tester.pumpWidget(wrap(MeasurementCategoryForm(category)));
      await tester.pumpAndSettle();

      expect(
        tester
            .widget<DropdownButtonFormField<TrendCharacter>>(
              find.byType(DropdownButtonFormField<TrendCharacter>),
            )
            .onChanged,
        isNotNull,
      );
    });

    testWidgets('picking a trend keeps the settings of another client', (tester) async {
      final category = getMeasurementCategories()[1].copyWith(chartConfig: {'goal_line': 75});
      stubMeasurementReads(mockRepo, [category]);

      await tester.pumpWidget(wrap(MeasurementCategoryForm(category)));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(DropdownButtonFormField<TrendCharacter>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Reactive').last);
      await tester.pumpAndSettle();
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      final saved =
          verify(mockRepo.updateLocalDriftCategory(captureAny)).captured.single
              as MeasurementCategory;
      expect(saved.chartConfig, {'goal_line': 75, 'trend': 'reactive'});
    });

    testWidgets('editing existing category pre-fills name and unit', (tester) async {
      final existing = getMeasurementCategories()[1];

      await tester.pumpWidget(wrap(MeasurementCategoryForm(existing)));
      await tester.pumpAndSettle();

      expect(find.widgetWithText(TextFormField, 'Biceps'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'cm'), findsOneWidget);
    });
  });

  group('MeasurementCategoryForm calculations', () {
    /// Taps the "Calculated" half of the source switch
    Future<void> switchToCalculated(WidgetTester tester) async {
      await tester.tap(find.text('Calculated'));
      await tester.pumpAndSettle();
    }

    testWidgets('the form scrolls, so a calculation cannot push it off screen', (
      tester,
    ) async {
      // Picking one adds the type field, its description and a block of
      // parameters; on a phone that is more than the screen holds
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(wrap(const MeasurementCategoryForm()));
      await tester.pumpAndSettle();
      await switchToCalculated(tester);

      expect(tester.takeException(), isNull);
      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -300));
      await tester.pumpAndSettle();
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('a new free-form category is offered the switch', (tester) async {
      await tester.pumpWidget(wrap(const MeasurementCategoryForm()));
      await tester.pumpAndSettle();

      expect(find.byType(SegmentedButton<bool>), findsOneWidget);
      // Nothing about a calculation until one is asked for
      expect(find.byKey(const Key('calculation-type')), findsNothing);
    });

    testWidgets('a typed category is not offered the switch', (tester) async {
      // The server writes those itself and refuses the combination
      final typed = getMeasurementCategories()[1].copyWith(metricType: MetricType.heartRate);

      await tester.pumpWidget(wrap(MeasurementCategoryForm(typed)));
      await tester.pumpAndSettle();

      expect(find.byType(SegmentedButton<bool>), findsNothing);
    });

    testWidgets('switching reveals the type picker and its description', (tester) async {
      await tester.pumpWidget(wrap(const MeasurementCategoryForm()));
      await tester.pumpAndSettle();
      await switchToCalculated(tester);

      expect(find.byKey(const Key('calculation-type')), findsOneWidget);
      expect(
        find.text('From your body weight and the height in your profile'),
        findsOneWidget,
      );
    });

    testWidgets('a calculation without a description gets no paragraph', (tester) async {
      await tester.pumpWidget(wrap(const MeasurementCategoryForm()));
      await tester.pumpAndSettle();
      await switchToCalculated(tester);

      await tester.tap(find.byKey(const Key('calculation-type')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('One-rep max').last);
      await tester.pumpAndSettle();

      // The exercise picker right below says what it reads, so the sentence
      // that BMI needs would only repeat the category name here
      expect(find.byKey(const Key('calculation-type')), findsOneWidget);
      expect(find.textContaining('From your'), findsNothing);
    });

    testWidgets('the description names the source category once it is picked', (tester) async {
      // One sentence serves the form and the category itself, so the ratio
      // has to fill its placeholder here too
      final waist = MeasurementCategory(id: 'waist', name: 'Waist', unit: 'cm');
      stubMeasurementReads(mockRepo, [waist]);

      await tester.pumpWidget(wrap(const MeasurementCategoryForm()));
      await tester.pumpAndSettle();
      await switchToCalculated(tester);

      await tester.tap(find.byKey(const Key('calculation-type')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Waist to height ratio').last);
      await tester.pumpAndSettle();

      expect(find.text('From  and the height in your profile'), findsOneWidget);

      await tester.tap(find.byKey(const Key('calculation-param-category_id')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Waist (cm)').last);
      await tester.pumpAndSettle();

      expect(find.text('From Waist and the height in your profile'), findsOneWidget);
    });

    testWidgets('switching prefills name and unit from the calculation', (tester) async {
      await tester.pumpWidget(wrap(const MeasurementCategoryForm()));
      await tester.pumpAndSettle();
      await switchToCalculated(tester);

      expect(find.widgetWithText(TextFormField, 'BMI'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'kg/m²'), findsOneWidget);
    });

    testWidgets('a name the user wrote survives the prefill', (tester) async {
      await tester.pumpWidget(wrap(const MeasurementCategoryForm()));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).first, 'My index');
      await switchToCalculated(tester);

      expect(find.widgetWithText(TextFormField, 'My index'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'BMI'), findsNothing);
      // The unit was not touched either, so it still takes the prefill
      expect(find.widgetWithText(TextFormField, 'kg/m²'), findsOneWidget);
    });

    testWidgets('switching back to hand-kept clears the configuration', (tester) async {
      when(mockRepo.addLocalDriftCategory(any)).thenAnswer((_) async {});

      await tester.pumpWidget(wrap(const MeasurementCategoryForm()));
      await tester.pumpAndSettle();
      await switchToCalculated(tester);
      await tester.tap(find.text('Entered by hand'));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('calculation-type')), findsNothing);

      await tester.enterText(find.byType(TextFormField).at(1), 'cm');
      await tester.ensureVisible(find.byType(ElevatedButton));
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      final saved =
          verify(mockRepo.addLocalDriftCategory(captureAny)).captured.single as MeasurementCategory;
      expect(saved.dynamicType, noDynamicType);
      expect(saved.dynamicParams, isNull);
    });

    testWidgets('a calculation the user already has cannot be picked twice', (tester) async {
      // BMI computes the same series whatever else is configured, so a second
      // one would only sync the same values again
      final bmi = MeasurementCategory(id: 'bmi', name: 'BMI', unit: '', dynamicType: 'BMI');
      stubMeasurementReads(mockRepo, [bmi]);

      await tester.pumpWidget(wrap(const MeasurementCategoryForm()));
      await tester.pumpAndSettle();
      await switchToCalculated(tester);

      await tester.tap(find.byKey(const Key('calculation-type')));
      await tester.pumpAndSettle();

      final items = tester
          .widgetList<DropdownMenuItem<String>>(find.byType(DropdownMenuItem<String>))
          .toList();
      expect({for (final item in items) item.value: item.enabled}, containsPair('BMI', false));
      expect({for (final item in items) item.value: item.enabled}, containsPair('WHTR', true));
      expect(find.textContaining('Already tracked'), findsWidgets);
    });

    testWidgets('switching lands on a calculation that is still free', (tester) async {
      final bmi = MeasurementCategory(id: 'bmi', name: 'BMI', unit: '', dynamicType: 'BMI');
      stubMeasurementReads(mockRepo, [bmi]);

      await tester.pumpWidget(wrap(const MeasurementCategoryForm()));
      await tester.pumpAndSettle();
      await switchToCalculated(tester);

      // BMI is the first of the list but taken, so the form does not open on
      // a calculation that cannot be saved
      final picker = tester.widget<DropdownButtonFormField<String>>(
        find.byKey(const Key('calculation-type')),
      );
      expect(picker.initialValue, 'WHTR');
    });

    testWidgets('a second calculation with the same settings is refused', (tester) async {
      final waist = MeasurementCategory(id: 'waist', name: 'Waist', unit: 'cm');
      final ratio = MeasurementCategory(
        id: 'whtr',
        name: 'Waist to height',
        unit: '',
        dynamicType: 'WHTR',
        dynamicParams: const {'category_id': 'waist'},
      );
      stubMeasurementReads(mockRepo, [waist, ratio]);

      await tester.pumpWidget(wrap(const MeasurementCategoryForm()));
      await tester.pumpAndSettle();
      await switchToCalculated(tester);
      await tester.tap(find.byKey(const Key('calculation-type')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Waist to height ratio').last);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('calculation-param-category_id')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Waist (cm)').last);
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.byType(ElevatedButton));
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // Caught here rather than on the next push: a category built offline
      // reaches the server long after the form that made it is gone
      expect(
        find.text('You already have a Waist to height ratio category with these settings'),
        findsOneWidget,
      );
      verifyNever(mockRepo.addLocalDriftCategory(any));
    });

    testWidgets('the same calculation on another source is allowed', (tester) async {
      final waist = MeasurementCategory(id: 'waist', name: 'Waist', unit: 'cm');
      final hip = MeasurementCategory(id: 'hip', name: 'Hip', unit: 'cm');
      final ratio = MeasurementCategory(
        id: 'whtr',
        name: 'Waist to height',
        unit: '',
        dynamicType: 'WHTR',
        dynamicParams: const {'category_id': 'waist'},
      );
      stubMeasurementReads(mockRepo, [waist, hip, ratio]);
      when(mockRepo.addLocalDriftCategory(any)).thenAnswer((_) async {});

      await tester.pumpWidget(wrap(const MeasurementCategoryForm()));
      await tester.pumpAndSettle();
      await switchToCalculated(tester);
      await tester.tap(find.byKey(const Key('calculation-type')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Waist to height ratio').last);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('calculation-param-category_id')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Hip (cm)').last);
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.byType(ElevatedButton));
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      final saved =
          verify(mockRepo.addLocalDriftCategory(captureAny)).captured.single as MeasurementCategory;
      expect(saved.dynamicParams, {'category_id': 'hip'});
    });

    testWidgets('renaming an existing calculation is not a duplicate of itself', (tester) async {
      final bmi = MeasurementCategory(id: 'bmi', name: 'BMI', unit: '', dynamicType: 'BMI');
      stubMeasurementReads(mockRepo, [bmi]);
      when(mockRepo.updateLocalDriftCategory(any)).thenAnswer((_) async {});

      await tester.pumpWidget(wrap(MeasurementCategoryForm(bmi)));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).first, 'Body mass index');
      await tester.ensureVisible(find.byType(ElevatedButton));
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      final saved =
          verify(mockRepo.updateLocalDriftCategory(captureAny)).captured.single
              as MeasurementCategory;
      expect(saved.name, 'Body mass index');
    });

    testWidgets('an existing hand-kept category is not offered a calculation', (tester) async {
      // What a category computes is fixed on the first save, so the choice
      // belongs to the form that creates one
      final category = getMeasurementCategories()[1];
      stubMeasurementReads(
        mockRepo,
        [category],
        {
          category.id!: [getMeasurementEntries()[category.id]!.first],
        },
      );

      await tester.pumpWidget(wrap(MeasurementCategoryForm(category)));
      await tester.pumpAndSettle();

      expect(find.byType(SegmentedButton<bool>), findsNothing);
      expect(find.byKey(const Key('calculation-type')), findsNothing);
      // The name is still the user's to change, without anything looking wrong
      expect(find.widgetWithText(TextFormField, 'Biceps'), findsOneWidget);
    });

    testWidgets('an existing calculation is shown locked, not as a switch', (tester) async {
      final bmi = MeasurementCategory(id: 'bmi', name: 'BMI', unit: '', dynamicType: 'BMI');
      stubMeasurementReads(mockRepo, [bmi]);

      await tester.pumpWidget(wrap(MeasurementCategoryForm(bmi)));
      await tester.pumpAndSettle();

      expect(find.byType(SegmentedButton<bool>), findsNothing);
      final picker = tester.widget<DropdownButtonFormField<String>>(
        find.byKey(const Key('calculation-type')),
      );
      expect(picker.onChanged, isNull);
      expect(
        find.text('The calculation cannot be changed. Delete the category to stop calculating it.'),
        findsOneWidget,
      );
    });

    testWidgets('a calculation from a newer server is shown but not editable', (tester) async {
      final unknown = MeasurementCategory(
        id: 'ffmi',
        name: 'FFMI',
        unit: 'kg/m²',
        dynamicType: 'FFMI',
        dynamicParams: const {'category_id': 'fat', 'unknown_key': 3},
      );
      stubMeasurementReads(mockRepo, [unknown]);
      when(mockRepo.updateLocalDriftCategory(any)).thenAnswer((_) async {});

      await tester.pumpWidget(wrap(MeasurementCategoryForm(unknown)));
      await tester.pumpAndSettle();

      expect(
        find.textContaining('set up in a newer version of wger'),
        findsOneWidget,
      );
      expect(find.byType(SegmentedButton<bool>), findsNothing);
      expect(find.byKey(const Key('calculation-type')), findsNothing);

      // Everything else stays editable, and saving leaves the configuration
      // this release cannot render exactly as it was
      await tester.enterText(find.byType(TextFormField).first, 'Renamed');
      await tester.ensureVisible(find.byType(ElevatedButton));
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      final saved =
          verify(mockRepo.updateLocalDriftCategory(captureAny)).captured.single
              as MeasurementCategory;
      expect(saved.name, 'Renamed');
      expect(saved.dynamicType, 'FFMI');
      expect(saved.dynamicParams, {'category_id': 'fat', 'unknown_key': 3});
    });

    testWidgets('the height hint appears only for a profile without one', (tester) async {
      when(
        mockProfileRepo.watchDrift(),
      ).thenAnswer((_) => Stream.value(UserProfile(id: 1, weightUnitStr: 'kg')));

      await tester.pumpWidget(wrap(const MeasurementCategoryForm()));
      await tester.pumpAndSettle();
      await switchToCalculated(tester);

      expect(
        find.text('The height in your profile is missing, so no values can be computed yet.'),
        findsOneWidget,
      );
    });

    testWidgets('the height hint stays away while the profile has one', (tester) async {
      await tester.pumpWidget(wrap(const MeasurementCategoryForm()));
      await tester.pumpAndSettle();
      await switchToCalculated(tester);

      expect(
        find.text('The height in your profile is missing, so no values can be computed yet.'),
        findsNothing,
      );
    });

    testWidgets('a total starts at bench press, squat and deadlift', (tester) async {
      final bigThree = [
        for (final (index, uuid) in bigThreeUuids.indexed)
          testBenchPress.copyWith(id: 90 + index, uuid: uuid),
      ];
      when(
        mockExerciseRepo.watchAllDrift(),
      ).thenAnswer((_) => Stream.value(ExerciseState(bigThree)));
      when(mockRepo.addLocalDriftCategory(any)).thenAnswer((_) async {});

      await tester.pumpWidget(wrap(const MeasurementCategoryForm()));
      await tester.pumpAndSettle();
      await switchToCalculated(tester);

      await tester.tap(find.byKey(const Key('calculation-type')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('One-rep max total').last);
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.byType(ElevatedButton));
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      final saved =
          verify(mockRepo.addLocalDriftCategory(captureAny)).captured.single as MeasurementCategory;
      expect(saved.dynamicType, 'ONE_RM_TOTAL');
      expect(saved.dynamicParams, {
        'exercise_ids': [90, 91, 92],
        'max_reps': 5,
        'window_days': 30,
      });
      expect(saved.unit, 'kg');
    });

    testWidgets('switching the type does not carry a number over', (tester) async {
      // Both one-rep max types have a max_reps field, so the widget of the
      // first survived into the second and went on showing what was typed
      // there while the parameters had already been reset
      when(mockRepo.addLocalDriftCategory(any)).thenAnswer((_) async {});

      await tester.pumpWidget(wrap(const MeasurementCategoryForm()));
      await tester.pumpAndSettle();
      await switchToCalculated(tester);

      await tester.tap(find.byKey(const Key('calculation-type')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('One-rep max').last);
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('calculation-param-max_reps')), '3');
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('calculation-type')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('One-rep max total').last);
      await tester.pumpAndSettle();

      final shown = tester
          .widget<TextField>(
            find.descendant(
              of: find.byKey(const Key('calculation-param-max_reps')),
              matching: find.byType(TextField),
            ),
          )
          .controller!
          .text;
      expect(shown, '5');
    });

    testWidgets('a total starts empty where the exercises never synced', (tester) async {
      // The default mock knows no exercises at all
      await tester.pumpWidget(wrap(const MeasurementCategoryForm()));
      await tester.pumpAndSettle();
      await switchToCalculated(tester);

      await tester.tap(find.byKey(const Key('calculation-type')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('One-rep max total').last);
      await tester.pumpAndSettle();

      // Nothing was picked, so the form does not let the configuration through
      await tester.ensureVisible(find.byType(ElevatedButton));
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      verifyNever(mockRepo.addLocalDriftCategory(any));
    });

    testWidgets('an incomplete configuration is refused before it is pushed', (tester) async {
      final waist = MeasurementCategory(id: 'waist', name: 'Waist', unit: 'cm');
      stubMeasurementReads(mockRepo, [waist]);

      await tester.pumpWidget(wrap(const MeasurementCategoryForm()));
      await tester.pumpAndSettle();
      await switchToCalculated(tester);

      await tester.tap(find.byKey(const Key('calculation-type')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Waist to height ratio').last);
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.byType(ElevatedButton));
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      verifyNever(mockRepo.addLocalDriftCategory(any));
    });

    testWidgets('a ratio with nothing to read from cannot be saved', (tester) async {
      // The category is created locally and pushed later, so a configuration
      // the server can only refuse has to be stopped here or the refusal
      // arrives long after the form is gone
      when(mockRepo.addLocalDriftCategory(any)).thenAnswer((_) async {});

      await tester.pumpWidget(wrap(const MeasurementCategoryForm()));
      await tester.pumpAndSettle();
      await switchToCalculated(tester);

      await tester.tap(find.byKey(const Key('calculation-type')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Waist to height ratio').last);
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.byType(ElevatedButton));
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      verifyNever(mockRepo.addLocalDriftCategory(any));
    });

    testWidgets('a calculated category may be saved without a unit', (tester) async {
      final waist = MeasurementCategory(id: 'waist', name: 'Waist', unit: 'cm');
      stubMeasurementReads(mockRepo, [waist]);
      when(mockRepo.addLocalDriftCategory(any)).thenAnswer((_) async {});

      await tester.pumpWidget(wrap(const MeasurementCategoryForm()));
      await tester.pumpAndSettle();
      await switchToCalculated(tester);

      await tester.tap(find.byKey(const Key('calculation-type')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Waist to height ratio').last);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('calculation-param-category_id')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Waist (cm)').last);
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.byType(ElevatedButton));
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      final saved =
          verify(mockRepo.addLocalDriftCategory(captureAny)).captured.single as MeasurementCategory;
      // A ratio of two lengths carries no unit, and the server takes it empty
      expect(saved.unit, '');
      expect(saved.dynamicType, 'WHTR');
      expect(saved.dynamicParams, {'category_id': 'waist'});
    });
  });
}
