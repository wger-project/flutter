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
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:wger/core/form_screen.dart';
import 'package:wger/core/network/auth_credentials_storage.dart';
import 'package:wger/features/measurements/models/measurement_category.dart';
import 'package:wger/features/measurements/providers/measurement_repository.dart';
import 'package:wger/features/measurements/screens/measurement_entries_screen.dart';
import 'package:wger/features/measurements/widgets/forms/category.dart';
import 'package:wger/features/measurements/widgets/metric_picker.dart';
import 'package:wger/l10n/generated/app_localizations.dart';

import '../../../helpers/measurement_repository_stubs.dart';
import 'metric_picker_test.mocks.dart';

@GenerateMocks([MeasurementRepository, AuthCredentialsStorage])
void main() {
  late MockMeasurementRepository mockRepo;
  late MockAuthCredentialsStorage mockCredentials;

  setUp(() {
    // The entries screen a new category opens reads the shared chart range
    SharedPreferencesAsyncPlatform.instance = InMemorySharedPreferencesAsync.empty();
    mockRepo = MockMeasurementRepository();
    mockCredentials = MockAuthCredentialsStorage();
    when(mockCredentials.dbOwnerUserId()).thenAnswer((_) async => '2');
    stubMeasurementReads(mockRepo, []);
    when(mockRepo.addLocalDriftCategory(any)).thenAnswer((_) async {});
    when(mockRepo.addLocalDriftCategoryGroup(any)).thenAnswer((_) async {});
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

  /// Brings the tile named [label] into view; where it sits follows from the
  /// alphabetical order, so no test may assume it is on the first screen
  Future<void> scrollTo(WidgetTester tester, String label) async {
    await tester.dragUntilVisible(
      find.text(label),
      find.byType(ListView),
      const Offset(0, -100),
    );
    await tester.ensureVisible(find.text(label));
    await tester.pumpAndSettle();
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
    verifyNever(mockRepo.addLocalDriftCategoryGroup(any));
  });

  testWidgets('picking a metric creates the category with the name and unit of its type', (
    tester,
  ) async {
    await tester.pumpWidget(wrap());
    await tester.pumpAndSettle();

    final context = tester.element(find.byType(MetricPickerSheet));
    await scrollTo(tester, MetricType.restingHeartRate.localized(context));
    await tester.tap(find.text(MetricType.restingHeartRate.localized(context)));
    await tester.pumpAndSettle();

    final added =
        (verify(mockRepo.addLocalDriftCategoryGroup(captureAny)).captured.single
                as List<MeasurementCategory>)
            .single;
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
    await scrollTo(tester, MetricType.restingHeartRate.localized(context));
    await tester.tap(find.text(MetricType.restingHeartRate.localized(context)));
    await tester.pumpAndSettle();

    expect(find.byType(MeasurementEntriesScreen), findsOneWidget);
  });

  testWidgets('a custom measurement leads into the form', (tester) async {
    await tester.pumpWidget(wrap());
    await tester.pumpAndSettle();

    await tester.tap(
      find.text(
        AppLocalizations.of(tester.element(find.byType(MetricPickerSheet))).customMeasurement,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(MeasurementCategoryForm), findsOneWidget);
    verifyNever(mockRepo.addLocalDriftCategoryGroup(any));
  });

  testWidgets('the own measurement leads, the known ones follow in order', (tester) async {
    await tester.pumpWidget(wrap());
    await tester.pumpAndSettle();

    final i18n = AppLocalizations.of(tester.element(find.byType(MetricPickerSheet)));
    final titles = tester
        .widgetList<ListTile>(find.byType(ListTile))
        .map((tile) => (tile.title! as Text).data!)
        .toList();

    expect(titles.first, i18n.customMeasurement);
    // Alphabetical by the translated name, not by the order they are declared
    final known = titles.skip(1).toList();
    expect(known, [...known]..sort());
    expect(known, isNotEmpty);
  });
}
