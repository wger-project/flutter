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
import 'package:provider/provider.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/models/workouts/day_data.dart';
import 'package:wger/models/workouts/routine.dart';
import 'package:wger/providers/routines.dart';
import 'package:wger/screens/form_screen.dart';
import 'package:wger/screens/gym_mode.dart';
import 'package:wger/screens/routine_screen.dart';
import 'package:wger/theme/theme.dart';
import 'package:wger/widgets/routines/forms/routine.dart';

bool _isSameDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

class DashboardRoutineWidget extends StatefulWidget {
  const DashboardRoutineWidget();

  @override
  State<DashboardRoutineWidget> createState() => _DashboardRoutineWidgetState();
}

class _DashboardRoutineWidgetState extends State<DashboardRoutineWidget> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final routine = context.watch<RoutinesProvider>().currentRoutine;
    final hasContent = routine != null;

    final now = DateTime.now();
    final allDays = hasContent
        ? routine.dayDataCurrentIteration.where((d) => d.day != null).toList()
        : [];
    final todayIndex = allDays.indexWhere((d) => _isSameDay(d.date, now));
    final todayData = todayIndex >= 0 ? allDays[todayIndex] : null;
    final otherDays = allDays.where((d) => !_isSameDay(d.date, now)).toList();

    return Padding(
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
            children: [
              // Header - navigates to routine details
              InkWell(
                onTap: hasContent
                    ? () {
                        Navigator.of(context).pushNamed(
                          RoutineScreen.routeName,
                          arguments: routine.id,
                        );
                      }
                    : null,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              hasContent
                                  ? routine.name
                                  : AppLocalizations.of(context).labelWorkoutPlan,
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (hasContent) ...[
                              const SizedBox(height: 4),
                              Builder(
                                builder: (context) {
                                  final isDarkMode =
                                      Theme.of(context).brightness == Brightness.dark;
                                  final startDate = MaterialLocalizations.of(
                                    context,
                                  ).formatCompactDate(routine.start);
                                  final endDate = MaterialLocalizations.of(
                                    context,
                                  ).formatCompactDate(routine.end);
                                  return Text(
                                    '$startDate - $endDate',
                                    style: TextStyle(
                                      color: isDarkMode
                                          ? Colors.grey.shade400
                                          : Colors.grey.shade600,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  );
                                },
                              ),
                            ],
                          ],
                        ),
                      ),
                      if (hasContent)
                        Icon(
                          Icons.chevron_right,
                          color: Colors.grey.shade400,
                          size: 28,
                        ),
                    ],
                  ),
                ),
              ),

              // Content
              if (hasContent)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Column(
                    children: [
                      // Today's workout (always visible) - show rest day card if no workout scheduled
                      _TodayCard(dayData: todayData),

                      // Expandable section for other days
                      if (otherDays.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        // Expand/collapse button
                        Builder(
                          builder: (context) {
                            final isDarkMode = Theme.of(context).brightness == Brightness.dark;
                            return Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () => setState(() => _isExpanded = !_isExpanded),
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: isDarkMode
                                          ? Colors.grey.shade700
                                          : Colors.grey.shade200,
                                      width: 1,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        _isExpanded
                                            ? AppLocalizations.of(context).showLess
                                            : '${AppLocalizations.of(context).showAll} (${otherDays.length})',
                                        style: TextStyle(
                                          color: isDarkMode
                                              ? Colors.grey.shade300
                                              : Colors.grey.shade700,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      AnimatedRotation(
                                        turns: _isExpanded ? 0.5 : 0,
                                        duration: const Duration(milliseconds: 200),
                                        child: Icon(
                                          Icons.keyboard_arrow_down,
                                          color: isDarkMode
                                              ? Colors.grey.shade400
                                              : Colors.grey.shade600,
                                          size: 18,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),

                        // Animated expandable list
                        AnimatedCrossFade(
                          firstChild: const SizedBox.shrink(),
                          secondChild: Column(
                            children: [
                              const SizedBox(height: 8),
                              for (int i = 0; i < otherDays.length; i++) ...[
                                _CompactDayRow(dayData: otherDays[i]),
                                if (i < otherDays.length - 1)
                                  Divider(height: 1, color: Colors.grey.shade200),
                              ],
                            ],
                          ),
                          crossFadeState: _isExpanded
                              ? CrossFadeState.showSecond
                              : CrossFadeState.showFirst,
                          duration: const Duration(milliseconds: 200),
                        ),
                      ],
                    ],
                  ),
                )
              else
                // Empty state - inviting the user to create their first routine
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      // 3D training plan icon
                      Image.asset(
                        'assets/icons/training-plan.png',
                        width: 120,
                        height: 120,
                      ),
                      const SizedBox(height: 20),
                      // Inviting title
                      Text(
                        AppLocalizations.of(context).noRoutines,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey.shade300
                              : Colors.grey.shade800,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      // Subtitle
                      Text(
                        AppLocalizations.of(context).noRoutinesSubtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey.shade400
                              : Colors.grey.shade600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      // Modern button to create routine
                      Material(
                        color: wgerAccentColor,
                        borderRadius: BorderRadius.circular(12),
                        child: InkWell(
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              FormScreen.routeName,
                              arguments: FormScreenArguments(
                                AppLocalizations.of(context).newRoutine,
                                hasListView: true,
                                RoutineForm(Routine.empty()),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.add_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  AppLocalizations.of(context).newRoutine,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Featured card for today's workout - more prominent styling
class _TodayCard extends StatelessWidget {
  final DayData? dayData;

  const _TodayCard({required this.dayData});

  @override
  Widget build(BuildContext context) {
    // If no workout scheduled for today, treat as rest/off day
    final isRestDay = dayData == null || dayData!.day == null || dayData!.day!.isRest;
    final exerciseCount = dayData?.slots.fold(0, (sum, slot) => sum + slot.setConfigs.length) ?? 0;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: isRestDay
          ? (isDarkMode ? Colors.grey.shade900 : Colors.grey.shade50)
          : wgerAccentColor.withValues(alpha: isDarkMode ? 0.15 : 0.06),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: isRestDay || dayData == null
            ? null
            : () {
                Navigator.of(context).pushNamed(
                  GymModeScreen.routeName,
                  arguments: GymModeArguments(
                    dayData!.day!.routineId,
                    dayData!.day!.id!,
                    dayData!.iteration,
                  ),
                );
              },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isRestDay
                  ? (isDarkMode ? Colors.grey.shade600 : Colors.grey.shade200)
                  : wgerAccentColor.withValues(alpha: isDarkMode ? 0.4 : 0.2),
              width: 1.5,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Icon using PNG assets - use rest icon for rest/no workout days
              Image.asset(
                isRestDay ? 'assets/icons/rest.png' : 'assets/icons/dumbbell.png',
                width: 40,
                height: 40,
              ),
              const SizedBox(width: 16),

              // Text content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Today badge and exercise count
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                            color: isRestDay
                                ? (isDarkMode ? Colors.grey.shade700 : Colors.grey.shade400)
                                : wgerAccentColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            AppLocalizations.of(context).today.toUpperCase(),
                            style: TextStyle(
                              color: isRestDay && isDarkMode ? Colors.grey.shade200 : Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        if (!isRestDay) ...[
                          const SizedBox(width: 8),
                          Text(
                            '$exerciseCount ${AppLocalizations.of(context).exercises}',
                            style: TextStyle(
                              color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Workout name or rest day message
                    Text(
                      dayData == null
                          ? AppLocalizations.of(context).noWorkoutScheduled
                          : (isRestDay
                                ? AppLocalizations.of(context).restDay
                                : dayData!.day!.nameWithType),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: isDarkMode
                            ? (isRestDay ? Colors.grey.shade200 : Colors.white)
                            : (isRestDay ? Colors.grey.shade700 : Colors.black87),
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Arrow for workout days
              if (!isRestDay) ...[
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: wgerAccentColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Compact row for non-today days in the expanded list
class _CompactDayRow extends StatelessWidget {
  final DayData dayData;

  const _CompactDayRow({required this.dayData});

  @override
  Widget build(BuildContext context) {
    final isRestDay = dayData.day == null || dayData.day!.isRest;
    final exerciseCount = dayData.slots.fold(0, (sum, slot) => sum + slot.setConfigs.length);
    final now = DateTime.now();
    final isPast = dayData.date.isBefore(now) && !_isSameDay(dayData.date, now);
    final isFuture = dayData.date.isAfter(now);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Check if this workout has been completed
    final routine = context.watch<RoutinesProvider>().currentRoutine;
    final hasSession =
        routine?.sessions.any((session) {
          return session.session.dayId == dayData.day?.id &&
              _isSameDay(session.session.date, dayData.date);
        }) ??
        false;

    // Determine indicator color based on status
    Color indicatorColor;
    if (isRestDay) {
      indicatorColor = isDarkMode ? Colors.grey.shade600 : Colors.grey.shade300;
    } else if (hasSession) {
      indicatorColor = Colors.green.shade600;
    } else if (isFuture) {
      indicatorColor = isDarkMode ? Colors.grey.shade600 : Colors.grey.shade400;
    } else {
      indicatorColor = Colors.red.shade400;
    }

    return InkWell(
      onTap: isRestDay
          ? null
          : () {
              Navigator.of(context).pushNamed(
                GymModeScreen.routeName,
                arguments: GymModeArguments(
                  dayData.day!.routineId,
                  dayData.day!.id!,
                  dayData.iteration,
                ),
              );
            },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            // Day indicator (colored dot matching status)
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: indicatorColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),

            // Day info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isRestDay ? AppLocalizations.of(context).restDay : dayData.day!.nameWithType,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      color: isDarkMode
                          ? (isRestDay ? Colors.grey.shade400 : Colors.white)
                          : (isRestDay ? Colors.grey.shade500 : Colors.black87),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (!isRestDay)
                    Text(
                      '$exerciseCount ${AppLocalizations.of(context).exercises}',
                      style: TextStyle(
                        color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade500,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),

            // Status label for workout days
            if (!isRestDay) ...[
              if (hasSession)
                // Completed - green label
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isDarkMode
                        ? Colors.green.shade900.withValues(alpha: 0.3)
                        : Colors.green.shade50,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    AppLocalizations.of(context).workoutCompleted,
                    style: TextStyle(
                      color: isDarkMode ? Colors.green.shade300 : Colors.green.shade600,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
              else if (isFuture)
                // Future workout - gray label
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    AppLocalizations.of(context).workoutUpcoming,
                    style: TextStyle(
                      color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
              else if (isPast)
                // Missed workout - red label
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isDarkMode
                        ? Colors.red.shade900.withValues(alpha: 0.3)
                        : Colors.red.shade50,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    AppLocalizations.of(context).workoutMissed,
                    style: TextStyle(
                      color: isDarkMode ? Colors.red.shade300 : Colors.red.shade600,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
