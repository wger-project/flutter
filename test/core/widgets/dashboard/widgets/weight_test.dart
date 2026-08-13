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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wger/core/widgets/dashboard/widgets/weight.dart';
import 'package:wger/core/widgets/error.dart';
import 'package:wger/features/account/models/user_profile.dart';
import 'package:wger/features/account/providers/user_profile_notifier.dart';
import 'package:wger/features/measurements/charts/data.dart';
import 'package:wger/features/measurements/models/measurement_bucket.dart';
import 'package:wger/features/measurements/providers/body_weight_provider.dart';
import 'package:wger/features/measurements/providers/measurement_notifier.dart';
import 'package:wger/l10n/generated/app_localizations.dart';

import '../../../../../test_data/body_weight.dart';

/// Feeds a fixed profile into the widget without the repository underneath.
class _StubUserProfileNotifier extends UserProfileNotifier {
  @override
  Stream<UserProfile?> build() => Stream.value(UserProfile(id: 1, weightUnitStr: 'kg'));
}

void main() {
  final category = getBodyWeightCategory();
  final level = chartBucketLevel(category.metricType, category.chartType);

  Widget renderWidget(Stream<List<MeasurementBucket>> buckets) {
    return ProviderScope(
      overrides: [
        userProfileProvider.overrideWith(_StubUserProfileNotifier.new),
        bodyWeightCategoryOnlyProvider.overrideWith((ref) => Stream.value(category)),
        // The dashboard card reads the full history, so the range has no cutoff
        measurementChartBucketsProvider(
          category.id!,
          null,
          null,
          level,
        ).overrideWith((ref) => buckets),
      ],
      child: const MaterialApp(
        locale: Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: SingleChildScrollView(child: DashboardWeightWidget()),
        ),
      ),
    );
  }

  testWidgets('shows the error instead of spinning forever', (tester) async {
    await tester.pumpWidget(renderWidget(Stream.error(Exception('no chart for you'))));
    await tester.pumpAndSettle();

    expect(find.byType(StreamErrorIndicator), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('shows a spinner while the points load', (tester) async {
    await tester.pumpWidget(renderWidget(const Stream.empty()));
    // No pumpAndSettle, the spinner animates forever
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.byType(StreamErrorIndicator), findsNothing);
  });
}
