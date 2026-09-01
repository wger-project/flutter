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
import 'package:wger/features/measurements/providers/measurement_repository.dart';
import 'package:wger/features/measurements/widgets/measurement_fab.dart';
import 'package:wger/features/measurements/widgets/metric_picker.dart';
import 'package:wger/l10n/generated/app_localizations.dart';

import '../../../helpers/measurement_repository_stubs.dart';
import 'measurement_fab_test.mocks.dart';

Widget _wrap() {
  final mockRepo = MockMeasurementRepository();
  stubMeasurementReads(mockRepo, const [], const {});

  return ProviderScope(
    overrides: [measurementRepositoryProvider.overrideWithValue(mockRepo)],
    child: const MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(floatingActionButton: MeasurementsFab()),
    ),
  );
}

@GenerateMocks([MeasurementRepository])
void main() {
  group('MeasurementsFab', () {
    testWidgets('opens the metric picker sheet', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pumpAndSettle();

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      expect(find.byType(MetricPickerSheet), findsOneWidget);
    });

    testWidgets('says what it does: readings are logged on the tiles', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pumpAndSettle();

      expect(
        tester.widget<FloatingActionButton>(find.byType(FloatingActionButton)).tooltip,
        'Track something new',
      );
    });
  });
}
