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

import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod;
import 'package:wger/core/formatting/formatting.dart';
import 'package:wger/core/widgets/async_value_widget.dart';
import 'package:wger/core/widgets/confirm_delete_dialog.dart';
import 'package:wger/core/widgets/text_prompt.dart';
import 'package:wger/features/account/providers/user_profile_notifier.dart';
import 'package:wger/features/measurements/charts/data.dart';
import 'package:wger/features/measurements/measurements.dart';
import 'package:wger/features/measurements/models/measurement_bucket.dart';
import 'package:wger/features/measurements/models/measurement_category.dart';
import 'package:wger/features/measurements/models/unit_conversion.dart';
import 'package:wger/features/measurements/providers/body_weight_provider.dart';
import 'package:wger/features/measurements/providers/measurement_notifier.dart';
import 'package:wger/features/nutrition/providers/nutrition_notifier.dart';
import 'package:wger/features/nutrition/screens/nutritional_plan_screen.dart';
import 'package:wger/l10n/generated/app_localizations.dart';

class NutritionalPlansList extends riverpod.ConsumerWidget {
  const NutritionalPlansList({super.key});

  /// Builds the weight change information for a nutritional plan period
  Widget _buildWeightChangeInfo(
    BuildContext context,
    riverpod.WidgetRef ref,
    DateTime startDate,
    DateTime? endDate,
  ) {
    final category = ref.watch(bodyWeightCategoryOnlyProvider).value;
    final profile = ref.watch(userProfileProvider).value;
    if (category == null || profile == null) {
      // Not yet loaded, skip the weight-change row entirely. The widget will
      // rebuild with the value once available.
      return const SizedBox.shrink();
    }

    // The whole history rather than the plan's period: the boundary values are
    // interpolated from the readings around it, which can lie outside. One
    // point per day, so several readings on one day count once.
    final buckets = ref
        .watch(
          measurementChartBucketsProvider(
            category.id!,
            null,
            null,
            MeasurementBucketLevel.day,
          ),
        )
        .value;
    if (buckets == null) {
      return const SizedBox.shrink();
    }

    // Normalize mixed-unit entries to the display unit before averaging
    final displayUnit = weightDisplayUnit(profile.isMetric);
    final entriesAll = chartEntriesForBuckets(
      buckets,
      targetUnit: displayUnit,
      categoryUnit: category.unit,
    );
    final average = movingAverage(
      entriesAll,
      days: category.chartSettings.averageWindow ?? ChartSettings.fallbackWindow,
    ).whereDateWithInterpolation(startDate, endDate);
    if (average.length < 2) {
      return const SizedBox.shrink();
    }

    // Calculate weight change
    final firstWeight = average.first;
    final lastWeight = average.last;
    final weightDifference = lastWeight.value - firstWeight.value;

    // Format the weight change text and determine color
    final String weightChangeText;
    final Color weightChangeColor;
    final unit = weightUnit(profile.isMetric, context);

    if (weightDifference > 0) {
      weightChangeText = '+${weightDifference.toStringAsFixed(1)} $unit';
      weightChangeColor = Colors.red;
    } else if (weightDifference < 0) {
      weightChangeText = '${weightDifference.toStringAsFixed(1)} $unit';
      weightChangeColor = Colors.green;
    } else {
      weightChangeText = '0 $unit';
      weightChangeColor = Colors.grey;
    }

    return Padding(
      padding: const EdgeInsets.only(top: 4.0),
      child: Row(
        children: [
          Text(
            '${AppLocalizations.of(context).weight} change: ',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          Text(
            weightChangeText,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: weightChangeColor,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, riverpod.WidgetRef ref) {
    final plansAsync = ref.watch(nutritionProvider);
    final notifier = ref.read(nutritionProvider.notifier);

    return AsyncValueWidget<NutritionState>(
      value: plansAsync,
      loggerName: 'NutritionalPlansList',
      data: (nutritionState) {
        final plans = nutritionState.plans;
        if (plans.isEmpty) {
          return const TextPrompt();
        }
        return ListView.builder(
          padding: const EdgeInsets.all(10.0),
          itemCount: plans.length,
          itemBuilder: (context, index) {
            final currentPlan = plans[index];
            return Card(
              child: ListTile(
                onTap: () {
                  Navigator.of(context).pushNamed(
                    NutritionalPlanScreen.routeName,
                    arguments: currentPlan.id,
                  );
                },
                title: Text(currentPlan.getLabel(context)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currentPlan.endDate != null
                          ? 'from ${localizedDate(context).format(currentPlan.startDate)} to ${localizedDate(context).format(currentPlan.endDate!)}'
                          : 'from ${localizedDate(context).format(currentPlan.startDate)} (open ended)',
                    ),
                    _buildWeightChangeInfo(
                      context,
                      ref,
                      currentPlan.startDate,
                      currentPlan.endDate,
                    ),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const VerticalDivider(),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      tooltip: AppLocalizations.of(context).delete,
                      onPressed: () => showConfirmDeleteDialog(
                        context,
                        itemName: currentPlan.description,
                        onConfirm: () => notifier.deletePlan(currentPlan.id!),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
