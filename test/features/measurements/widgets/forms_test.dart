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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:wger/core/widgets/decimal_input.dart';
import 'package:wger/features/measurements/models/measurement_category.dart';
import 'package:wger/features/measurements/models/measurement_entry.dart';
import 'package:wger/features/measurements/providers/measurement_repository.dart';
import 'package:wger/features/measurements/widgets/forms.dart';
import 'package:wger/l10n/generated/app_localizations.dart';

import '../../../../test_data/measurements.dart';
import '../../../helpers/measurement_repository_stubs.dart';
import 'forms_test.mocks.dart';

@GenerateMocks([MeasurementRepository])
void main() {
  late MockMeasurementRepository mockRepo;

  setUp(() {
    mockRepo = MockMeasurementRepository();
    stubMeasurementReads(mockRepo, []);
    when(mockRepo.addLocalDriftGroupEntries(any)).thenAnswer((_) async {});
  });

  Widget wrap(Widget child) {
    return ProviderScope(
      overrides: [
        measurementRepositoryProvider.overrideWithValue(mockRepo),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: SingleChildScrollView(child: child),
        ),
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
      expect(find.byType(DropdownButtonFormField<int>), findsOneWidget);
    });

    testWidgets('a summed type has no line to configure', (tester) async {
      // Its chart is one bar per day, which has neither a trend nor an
      // average, and no pick can turn it into a line
      final steps = getMeasurementCategories()[1].copyWith(metricType: MetricType.steps);
      stubMeasurementReads(mockRepo, [steps]);

      await tester.pumpWidget(wrap(MeasurementCategoryForm(steps)));
      await tester.pumpAndSettle();

      expect(find.byType(DropdownButtonFormField<TrendCharacter>), findsNothing);
      expect(find.byType(DropdownButtonFormField<int>), findsNothing);
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
            .widget<DropdownButtonFormField<int>>(
              find.byType(DropdownButtonFormField<int>),
            )
            .onChanged,
        isNull,
      );
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

  group('MeasurementEntryForm', () {
    testWidgets('editing keeps source and externalId of imported entries', (tester) async {
      final category = getMeasurementCategories()[0];
      stubMeasurementReads(mockRepo, [category]);
      when(mockRepo.updateLocalDrift(any)).thenAnswer((_) async {});

      final imported = MeasurementEntry(
        id: 'e-import',
        categoryId: category.id!,
        date: DateTime(2026, 1, 1),
        value: 30,
        notes: '',
        source: 'apple',
        externalId: 'platform-uuid',
        extraData: const {'unit': 'kg'},
      );

      await tester.pumpWidget(wrap(MeasurementEntryForm(category.id!, imported)));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      final saved =
          verify(mockRepo.updateLocalDrift(captureAny)).captured.single as MeasurementEntry;
      expect(saved.source, 'apple');
      expect(saved.externalId, 'platform-uuid');
      expect(saved.extraData, {'unit': 'kg'});
      expect(saved.value, 30);
    });

    testWidgets('editing pre-fills the notes and saves them changed', (tester) async {
      final category = getMeasurementCategories()[0];
      stubMeasurementReads(mockRepo, [category]);
      when(mockRepo.updateLocalDrift(any)).thenAnswer((_) async {});

      final entry = MeasurementEntry(
        id: 'e-1',
        categoryId: category.id!,
        date: DateTime(2026, 1, 1),
        value: 30,
        notes: 'Old notes',
      );

      await tester.pumpWidget(wrap(MeasurementEntryForm(category.id!, entry)));
      await tester.pumpAndSettle();
      expect(find.widgetWithText(TextFormField, 'Old notes'), findsOneWidget);

      await tester.enterText(find.widgetWithText(TextFormField, 'Old notes'), 'New notes');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      final saved =
          verify(mockRepo.updateLocalDrift(captureAny)).captured.single as MeasurementEntry;
      expect(saved.notes, 'New notes');
    });
  });

  group('GroupMeasurementEntryForm', () {
    testWidgets('renders one DecimalInputWidget per child component', (tester) async {
      await tester.pumpWidget(
        wrap(GroupMeasurementEntryForm(testMeasurementCategoryBloodPressure)),
      );
      await tester.pumpAndSettle();

      expect(find.byType(DecimalInputWidget), findsNWidgets(2));
    });

    testWidgets('empty value fields fail validation', (tester) async {
      await tester.pumpWidget(
        wrap(GroupMeasurementEntryForm(testMeasurementCategoryBloodPressure)),
      );
      await tester.pumpAndSettle();

      // Tap save without entering values
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // Form does not pop
      expect(find.byType(GroupMeasurementEntryForm), findsOneWidget);
      verifyNever(mockRepo.addLocalDriftGroupEntries(any));
    });

    testWidgets('valid submission adds one entry per component, sharing the date', (tester) async {
      await tester.pumpWidget(
        wrap(GroupMeasurementEntryForm(testMeasurementCategoryBloodPressure)),
      );
      await tester.pumpAndSettle();

      final fields = find.byType(TextFormField);
      // Fields: date, time, systolic value, diastolic value
      await tester.enterText(fields.at(2), '120');
      await tester.enterText(fields.at(3), '80');

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      final entries =
          verify(mockRepo.addLocalDriftGroupEntries(captureAny)).captured.single
              as List<MeasurementEntry>;
      expect(entries.map((e) => (e.categoryId, e.value)), [('sys', 120), ('dia', 80)]);
      expect(entries.first.date, entries.last.date);
    });
  });
}
