/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (c) 2020 - 2026 wger Team
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
import 'package:provider/provider.dart';
import 'package:wger/helpers/measurements.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/providers/body_weight.dart';
import 'package:wger/providers/user.dart';
import 'package:wger/theme/theme.dart';
import 'package:wger/widgets/core/time_range_tab_bar.dart';
import 'package:wger/widgets/measurements/charts.dart';
import 'package:wger/widgets/weight/edit_modal.dart';
import 'package:wger/widgets/weight/entries_modal.dart';

class DashboardWeightWidget extends StatefulWidget {
  const DashboardWeightWidget();

  @override
  State<DashboardWeightWidget> createState() => _DashboardWeightWidgetState();
}

class _DashboardWeightWidgetState extends State<DashboardWeightWidget> {
  ChartTimeRange _selectedRange = ChartTimeRange.month;

  DateTime? _getStartDate() {
    final now = DateTime.now();
    switch (_selectedRange) {
      case ChartTimeRange.week:
        return now.subtract(const Duration(days: 7));
      case ChartTimeRange.month:
        return now.subtract(const Duration(days: 30));
      case ChartTimeRange.sixMonths:
        return now.subtract(const Duration(days: 182));
      case ChartTimeRange.year:
        return now.subtract(const Duration(days: 365));
      case ChartTimeRange.all:
        return null; // No start date filter for all-time
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.read<UserProvider>().profile;
    final weightProvider = context.read<BodyWeightProvider>();
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final allEntries = weightProvider.items
        .map((e) => MeasurementChartEntry(e.weight, e.date))
        .toList();
    final startDate = _getStartDate();
    // For "all" time range, use all entries; otherwise filter by date
    final filteredEntries = startDate != null ? allEntries.whereDate(startDate, null) : allEntries;
    final avgDays = getAverageDaysForTimeRange(_selectedRange);
    final entriesAvg = movingAverage(filteredEntries, avgDays);

    return Consumer<BodyWeightProvider>(
      builder: (context, _, __) => Padding(
        padding: const EdgeInsets.all(4.0),
        child: Material(
          elevation: 0,
          color: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.light
                  ? Colors.white
                  : Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                  spreadRadius: 0,
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header with entries button
                Padding(
                  padding: const EdgeInsets.only(left: 16, right: 8, top: 12, bottom: 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          AppLocalizations.of(context).weight,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (weightProvider.items.isNotEmpty)
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () => showWeightEntriesModal(context),
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: Icon(
                                Icons.more_vert,
                                color: context.wgerLightGrey,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                // Time range tabs
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TimeRangeTabBar(
                    selectedRange: _selectedRange,
                    onRangeChanged: (range) => setState(() => _selectedRange = range),
                  ),
                ),
                const SizedBox(height: 12),
                // Content
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Column(
                    children: [
                      if (weightProvider.items.isNotEmpty)
                        Column(
                          children: [
                            SizedBox(
                              height: 200,
                              child: MeasurementChartWidgetFl(
                                filteredEntries,
                                weightUnit(profile!.isMetric, context),
                                avgs: entriesAvg,
                                timeRange: _selectedRange,
                              ),
                            ),
                            const SizedBox(height: 12),
                            // Bottom row with trend indicator and add button
                            Row(
                              children: [
                                // Trend indicator
                                if (entriesAvg != null && entriesAvg.isNotEmpty)
                                  _buildTrendIndicator(
                                    context,
                                    entriesAvg.first,
                                    entriesAvg.last,
                                    weightUnit(profile.isMetric, context),
                                    isDarkMode,
                                  ),
                                const Spacer(),
                                // Add button
                                Material(
                                  color: wgerAccentColor,
                                  borderRadius: BorderRadius.circular(10),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(10),
                                    onTap: () => showEditWeightModal(
                                      context,
                                      weightProvider.getNewestEntry()?.copyWith(
                                        id: null,
                                        date: DateTime.now(),
                                      ),
                                    ),
                                    child: const Padding(
                                      padding: EdgeInsets.all(8),
                                      child: Icon(
                                        Icons.add_rounded,
                                        size: 20,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        )
                      else
                        SizedBox(
                          height: 150,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(AppLocalizations.of(context).noWeightEntries),
                              const SizedBox(height: 12),
                              Material(
                                color: wgerAccentColor,
                                borderRadius: BorderRadius.circular(10),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(10),
                                  onTap: () => showEditWeightModal(context, null),
                                  child: const Padding(
                                    padding: EdgeInsets.all(10),
                                    child: Icon(
                                      Icons.add_rounded,
                                      size: 24,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTrendIndicator(
    BuildContext context,
    MeasurementChartEntry first,
    MeasurementChartEntry last,
    String unit,
    bool isDarkMode,
  ) {
    final delta = last.value - first.value;
    final isPositive = delta > 0;
    final isNegative = delta < 0;

    // Vibrant accent color for trend indicator
    const Color trendColor = wgerAccentColor;
    final Color bgColor = wgerAccentColor.withValues(alpha: isDarkMode ? 0.2 : 0.1);

    final IconData trendIcon;
    if (isPositive) {
      trendIcon = Icons.trending_up_rounded;
    } else if (isNegative) {
      trendIcon = Icons.trending_down_rounded;
    } else {
      trendIcon = Icons.trending_flat_rounded;
    }

    final prefix = isPositive ? '+' : '';
    final valueText = '$prefix${delta.toStringAsFixed(1)} $unit';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            trendIcon,
            size: 16,
            color: trendColor,
          ),
          const SizedBox(width: 4),
          Text(
            valueText,
            style: TextStyle(
              color: trendColor,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
