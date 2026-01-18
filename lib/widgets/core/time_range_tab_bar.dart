/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (C) 2020, 2021 wger Team
 *
 * wger Workout Manager is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * wger Workout Manager is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import 'package:flutter/material.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/widgets/measurements/charts.dart';

/// A reusable time range tab bar for selecting chart time ranges.
///
/// Displays tabs for Week, Month, 6 Months, and Year with consistent styling.
class TimeRangeTabBar extends StatelessWidget {
  final ChartTimeRange selectedRange;
  final ValueChanged<ChartTimeRange> onRangeChanged;

  const TimeRangeTabBar({
    super.key,
    required this.selectedRange,
    required this.onRangeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        _TimeRangeTab(
          range: ChartTimeRange.week,
          label: AppLocalizations.of(context).week,
          isSelected: selectedRange == ChartTimeRange.week,
          isDarkMode: isDarkMode,
          onTap: () => onRangeChanged(ChartTimeRange.week),
        ),
        const SizedBox(width: 8),
        _TimeRangeTab(
          range: ChartTimeRange.month,
          label: AppLocalizations.of(context).month,
          isSelected: selectedRange == ChartTimeRange.month,
          isDarkMode: isDarkMode,
          onTap: () => onRangeChanged(ChartTimeRange.month),
        ),
        const SizedBox(width: 8),
        _TimeRangeTab(
          range: ChartTimeRange.sixMonths,
          label: AppLocalizations.of(context).sixMonths,
          isSelected: selectedRange == ChartTimeRange.sixMonths,
          isDarkMode: isDarkMode,
          onTap: () => onRangeChanged(ChartTimeRange.sixMonths),
        ),
        const SizedBox(width: 8),
        _TimeRangeTab(
          range: ChartTimeRange.year,
          label: AppLocalizations.of(context).year,
          isSelected: selectedRange == ChartTimeRange.year,
          isDarkMode: isDarkMode,
          onTap: () => onRangeChanged(ChartTimeRange.year),
        ),
        const SizedBox(width: 8),
        _TimeRangeTab(
          range: ChartTimeRange.all,
          label: AppLocalizations.of(context).all,
          isSelected: selectedRange == ChartTimeRange.all,
          isDarkMode: isDarkMode,
          onTap: () => onRangeChanged(ChartTimeRange.all),
        ),
      ],
    );
  }
}

class _TimeRangeTab extends StatelessWidget {
  final ChartTimeRange range;
  final String label;
  final bool isSelected;
  final bool isDarkMode;
  final VoidCallback onTap;

  const _TimeRangeTab({
    required this.range,
    required this.label,
    required this.isSelected,
    required this.isDarkMode,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDarkMode
                      ? Colors.white.withValues(alpha: 0.15)
                      : Colors.black.withValues(alpha: 0.08))
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected
                  ? (isDarkMode ? Colors.white : Colors.black87)
                  : (isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600),
            ),
          ),
        ),
      ),
    );
  }
}
