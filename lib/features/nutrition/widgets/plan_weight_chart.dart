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
import 'package:wger/features/account/providers/user_profile_notifier.dart';
import 'package:wger/features/measurements/models/unit_conversion.dart';
import 'package:wger/features/measurements/providers/body_weight_provider.dart';
import 'package:wger/features/measurements/widgets/charts.dart';
import 'package:wger/features/measurements/widgets/helpers.dart';
import 'package:wger/features/nutrition/models/nutritional_plan.dart';
import 'package:wger/l10n/generated/app_localizations.dart';

/// Body weight during the plan's period: chart plus overall change.
///
/// Hidden while the weight data is not loaded and when fewer than two
/// readings fall into the period. All series are derived from the readings
/// inside the period only, so the trend starts from a real measurement
/// instead of an interpolated boundary point.
class PlanWeightChart extends ConsumerWidget {
  final NutritionalPlan _plan;

  const PlanWeightChart(this._plan);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final category = ref.watch(bodyWeightCategoryProvider).value;
    final profile = ref.watch(userProfileProvider).value;
    if (category == null || profile == null) {
      return const SizedBox.shrink();
    }

    // The end date is inclusive: readings on the plan's last day still count
    final endExclusive = _plan.endDate?.add(const Duration(days: 1));
    final entries = category.entries
        .where(
          (e) =>
              !e.date.isBefore(_plan.startDate) &&
              (endExclusive == null || e.date.isBefore(endExclusive)),
        )
        .toList();
    // A single reading has no development to show
    if (entries.length < 2) {
      return const SizedBox.shrink();
    }

    // Entries can be stored in mixed units (kg/lb); normalize everything
    // to the profile's display unit before charting or averaging
    final displayUnit = weightDisplayUnit(profile.isMetric);
    final points = chartEntriesFor(entries, targetUnit: displayUnit, categoryUnit: category.unit);
    final settings = category.chartSettings;
    final avg = movingAverage(points, days: settings.averageWindow);

    return Column(
      children: getOverviewWidgets(
        AppLocalizations.of(context).weight,
        points,
        avg,
        weightUnit(profile.isMetric, context),
        context,
        metricType: category.metricType,
        settings: settings,
      ),
    );
  }
}
