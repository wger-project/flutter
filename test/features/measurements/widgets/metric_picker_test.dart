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
import 'package:wger/core/form_screen.dart';
import 'package:wger/core/network/auth_credentials_storage.dart';
import 'package:wger/features/measurements/models/measurement_category.dart';
import 'package:wger/features/measurements/providers/measurement_repository.dart';
import 'package:wger/features/measurements/screens/measurement_entries_screen.dart';
import 'package:wger/features/measurements/widgets/forms.dart';
import 'package:wger/features/measurements/widgets/metric_picker.dart';
import 'package:wger/l10n/generated/app_localizations.dart';

import '../../../helpers/measurement_repository_stubs.dart';
import 'metric_picker_test.mocks.dart';

@GenerateMocks([MeasurementRepository, AuthCredentialsStorage])
void main() {
  late MockMeasurementRepository mockRepo;
  late MockAuthCredentialsStorage mockCredentials;

  setUp(() {
    mockRepo = MockMeasurementRepository();
    mockCredentials = MockAuthCredentialsStorage();
    when(mockCredentials.dbOwnerUserId()).thenAnswer((_) async => '2');
    when(mockRepo.watchAll()).thenAnswer((_) => Stream.value([]));
    stubMeasurementReads(mockRepo, []);
    when(mockRepo.addLocalDriftCategory(any)).thenAnswer((_) async {});
  });

  Widget wrap() {
    return ProviderScope(
      overrides: [
        measurementRepositoryProvider.overrideWithValue(mockRepo),
        authCredentialsStorageProvider.overrideWithValue(mockCredentials),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        routes: {
          FormScreen.routeName: (_) => const FormScreen(),
          MeasurementEntriesScreen.routeName: (_) => const MeasurementEntriesScreen(),
        },
        home: const Scaffold(body: MetricPickerSheet()),
      ),
    );
  }

  testWidgets('offers neither body weight nor the components', (tester) async {
    // Body weight is the server's category and a component comes with its
    // group, so neither is something to start here
    await tester.pumpWidget(wrap());
    await tester.pumpAndSettle();

    final context = tester.element(find.byType(MetricPickerSheet));
    for (final hidden in [
      MetricType.bodyWeight,
      MetricType.bloodPressureSystolic,
      MetricType.sleepDeep,
    ]) {
      expect(find.text(hidden.localized(context)), findsNothing);
    }
    expect(find.text(MetricType.bloodPressure.localized(context)), findsOneWidget);
  });

  testWidgets('a metric that already has a category cannot be picked again', (tester) async {
    stubMeasurementReads(mockRepo, [
      MeasurementCategory(
        id: 'hr',
        name: 'Heart rate',
        unit: 'bpm',
        metricType: MetricType.heartRate,
      ),
    ]);
    when(mockRepo.watchAll()).thenAnswer(
      (_) => Stream.value([
        MeasurementCategory(
          id: 'hr',
          name: 'Heart rate',
          unit: 'bpm',
          metricType: MetricType.heartRate,
        ),
      ]),
    );

    await tester.pumpWidget(wrap());
    await tester.pumpAndSettle();

    final context = tester.element(find.byType(MetricPickerSheet));
    final tile = tester.widget<ListTile>(
      find.ancestor(
        of: find.text(MetricType.heartRate.localized(context)),
        matching: find.byType(ListTile),
      ),
    );
    expect(tile.enabled, isFalse);

    await tester.tap(find.text(MetricType.heartRate.localized(context)));
    await tester.pumpAndSettle();
    verifyNever(mockRepo.addLocalDriftCategory(any));
  });

  testWidgets('picking a metric creates the category with the name and unit of its type', (
    tester,
  ) async {
    await tester.pumpWidget(wrap());
    await tester.pumpAndSettle();

    final context = tester.element(find.byType(MetricPickerSheet));
    await tester.tap(find.text(MetricType.restingHeartRate.localized(context)));
    await tester.pumpAndSettle();

    final added =
        verify(mockRepo.addLocalDriftCategory(captureAny)).captured.single as MeasurementCategory;
    expect(added.metricType, MetricType.restingHeartRate);
    expect(added.name, 'Resting heart rate');
    expect(added.unit, 'bpm');
    expect(added.id, deterministicCategoryId('2', MetricType.restingHeartRate));
  });

  testWidgets('the new category is opened right away', (tester) async {
    // The overview is long enough that a new card somewhere in it does not
    // read as "something happened"
    final id = deterministicCategoryId('2', MetricType.restingHeartRate);
    // Only the screen behind the tap knows the category, not the picker: it
    // is created by the tap, and a metric that already exists is disabled
    when(mockRepo.watchCategoryWithoutEntries(id)).thenAnswer(
      (_) => Stream.value(
        MeasurementCategory(
          id: id,
          name: 'Resting heart rate',
          unit: 'bpm',
          metricType: MetricType.restingHeartRate,
        ),
      ),
    );

    await tester.pumpWidget(wrap());
    await tester.pumpAndSettle();

    final context = tester.element(find.byType(MetricPickerSheet));
    await tester.tap(find.text(MetricType.restingHeartRate.localized(context)));
    await tester.pumpAndSettle();

    expect(find.byType(MeasurementEntriesScreen), findsOneWidget);
  });

  testWidgets('a custom measurement leads into the form', (tester) async {
    await tester.pumpWidget(wrap());
    await tester.pumpAndSettle();

    // Last of the list, below the fold on a test-sized screen
    final custom = find.text(
      AppLocalizations.of(tester.element(find.byType(MetricPickerSheet))).customMeasurement,
    );
    await tester.dragUntilVisible(custom, find.byType(ListView), const Offset(0, -100));
    await tester.tap(custom);
    await tester.pumpAndSettle();

    expect(find.byType(MeasurementCategoryForm), findsOneWidget);
    verifyNever(mockRepo.addLocalDriftCategory(any));
  });
}
