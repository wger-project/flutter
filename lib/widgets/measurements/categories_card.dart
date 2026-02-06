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
import 'package:wger/models/measurements/measurement_category.dart';
import 'package:wger/theme/theme.dart';

import 'charts.dart';
import 'edit_modals.dart';
import 'entries_modal.dart';

class CategoriesCard extends StatelessWidget {
  final MeasurementCategory currentCategory;
  final ChartTimeRange? timeRange;
  final bool showCard;

  const CategoriesCard(this.currentCategory, {this.timeRange, this.showCard = true});

  DateTime? _getStartDate() {
    final now = DateTime.now();
    switch (timeRange) {
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
      case null:
        return now.subtract(const Duration(days: 30));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final allEntries = currentCategory.entries
        .map((e) => MeasurementChartEntry(e.value, e.date))
        .toList();
    final startDate = _getStartDate();
    // For "all" time range, use all entries; otherwise filter by date
    final filteredEntries = startDate != null
        ? allEntries
              .where((e) => e.date.isAfter(startDate) || e.date.isAtSameMomentAs(startDate))
              .toList()
        : allEntries;
    final avgDays = getAverageDaysForTimeRange(timeRange);
    final entriesAvg = movingAverage(filteredEntries, avgDays);

    final content = Column(
      children: [
        // Category name (tappable to view entries)
        GestureDetector(
          onTap: () => showEntriesModal(context, currentCategory),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  currentCategory.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isDarkMode ? Colors.grey.shade300 : Colors.grey.shade700,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.expand_more_rounded,
                  size: 20,
                  color: context.wgerLightGrey,
                ),
              ],
            ),
          ),
        ),
        // Chart - uses Expanded to fill available space in constrained contexts
        Expanded(
          child: MeasurementChartWidgetFl(
            filteredEntries,
            currentCategory.unit,
            avgs: entriesAvg,
            timeRange: timeRange,
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
                currentCategory.unit,
                isDarkMode,
              ),
            const Spacer(),
            // Add button
            Material(
              color: wgerAccentColor,
              borderRadius: BorderRadius.circular(10),
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () => showEditEntryModal(context, currentCategory, null),
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
    );

    // When used inside dashboard (showCard=false), just return content with padding
    if (!showCard) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: content,
      );
    }

    // When used in detail page (showCard=true), wrap in card container
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDarkMode ? Theme.of(context).cardColor : Colors.white,
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
        child: content,
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
            style: const TextStyle(
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
