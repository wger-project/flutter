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
import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod;
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:wger/helpers/consts.dart';
import 'package:wger/helpers/date.dart';
import 'package:wger/helpers/json.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/models/body_weight/weight_entry.dart';
import 'package:wger/models/measurements/measurement_category.dart';
import 'package:wger/models/nutrition/nutritional_plan.dart';
import 'package:wger/models/workouts/session.dart';
import 'package:wger/providers/body_weight.dart';
import 'package:wger/providers/measurement_notifier.dart';
import 'package:wger/providers/nutrition_notifier.dart';
import 'package:wger/providers/routines.dart';
import 'package:wger/theme/theme.dart';
import 'package:wger/widgets/core/progress_indicator.dart';

/// Types of events
enum EventType { weight, measurement, session, caloriesDiary }

/// An event in the dashboard calendar
class Event {
  final EventType _type;
  final String _description;

  const Event(this._type, this._description);

  String get description {
    return _description;
  }

  EventType get type {
    return _type;
  }
}

class DashboardCalendarWidget extends riverpod.ConsumerStatefulWidget {
  const DashboardCalendarWidget();

  @override
  _DashboardCalendarWidgetState createState() => _DashboardCalendarWidgetState();
}

class _DashboardCalendarWidgetState extends riverpod.ConsumerState<DashboardCalendarWidget>
    with TickerProviderStateMixin {
  RangeSelectionMode _rangeSelectionMode = RangeSelectionMode.toggledOff;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  DateTime? _rangeStart;
  DateTime? _rangeEnd;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  /// Builds the date → events map from already-loaded provider data
  Map<String, List<Event>> _buildEvents({
    required BuildContext context,
    required List<WeightEntry> entries,
    required List<MeasurementCategory> categories,
    required List<WorkoutSession> sessions,
    required List<NutritionalPlan> plans,
  }) {
    final numberFormat = NumberFormat.decimalPattern(Localizations.localeOf(context).toString());
    final i18n = AppLocalizations.of(context);
    final events = <String, List<Event>>{};

    for (final entry in entries) {
      final date = DateFormatLists.format(entry.date);
      events.putIfAbsent(date, () => []);
      events[date]!.add(Event(EventType.weight, '${numberFormat.format(entry.weight)} kg'));
    }

    for (final category in categories) {
      for (final entry in category.entries) {
        final date = DateFormatLists.format(entry.date);
        events.putIfAbsent(date, () => []);
        events[date]!.add(
          Event(
            EventType.measurement,
            '${category.name}: ${numberFormat.format(entry.value)} ${category.unit}',
          ),
        );
      }
    }

    for (final session in sessions) {
      final date = DateFormatLists.format(session.date);
      events.putIfAbsent(date, () => []);
      var time = '';
      if (session.timeStart != null && session.timeEnd != null) {
        time = '(${timeToString(session.timeStart)} - ${timeToString(session.timeEnd)})';
      }
      events[date]!.add(
        Event(
          EventType.session,
          '${i18n.impression}: ${session.impressionAsString(context)} $time',
        ),
      );
    }

    for (final plan in plans) {
      for (final entry in plan.logEntriesValues.entries) {
        final date = DateFormatLists.format(entry.key);
        events.putIfAbsent(date, () => []);
        events[date]!.add(
          Event(EventType.caloriesDiary, i18n.kcalValue(entry.value.energy.toStringAsFixed(0))),
        );
      }
    }

    return events;
  }

  List<Event> _getEventsForDay(Map<String, List<Event>> events, DateTime day) {
    return events[DateFormatLists.format(day)] ?? [];
  }

  List<Event> _getEventsForRange(Map<String, List<Event>> events, DateTime start, DateTime end) {
    final days = daysInRange(start, end);
    return [for (final d in days) ..._getEventsForDay(events, d)];
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
        _rangeStart = null;
        _rangeEnd = null;
        _rangeSelectionMode = RangeSelectionMode.toggledOff;
      });
    }
  }

  void _onRangeSelected(DateTime? start, DateTime? end, DateTime focusedDay) {
    setState(() {
      _selectedDay = null;
      _focusedDay = focusedDay;
      _rangeStart = start;
      _rangeEnd = end;
      _rangeSelectionMode = RangeSelectionMode.toggledOn;
    });
  }

  Widget _shell(BuildContext context, Widget body) {
    return Card(
      child: Column(
        children: [
          ListTile(
            title: Text(
              AppLocalizations.of(context).calendar,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            leading: Icon(
              Icons.calendar_today,
              color: Theme.of(context).textTheme.headlineMedium!.color,
            ),
          ),
          body,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final entries = ref.watch(weightEntryProvider).value;
    final categories = ref.watch(measurementProvider).value;
    final routinesState = ref.watch(routinesRiverpodProvider).value;
    final plans = ref.watch(nutritionProvider).value;

    // Show a spinner until every source has produced at least one value. Same
    // pattern as the other dashboard widgets via [AsyncValueWidget].
    if (entries == null || categories == null || routinesState == null || plans == null) {
      return _shell(context, const BoxedProgressIndicator());
    }

    final events = _buildEvents(
      context: context,
      entries: entries,
      categories: categories,
      sessions: routinesState.sessions,
      plans: plans,
    );

    final selectedEvents = _selectedDay != null
        ? _getEventsForDay(events, _selectedDay!)
        : (_rangeStart != null && _rangeEnd != null)
        ? _getEventsForRange(events, _rangeStart!, _rangeEnd!)
        : const <Event>[];

    return _shell(
      context,
      Column(
        children: [
          TableCalendar<Event>(
            locale: Localizations.localeOf(context).languageCode,
            firstDay: DateTime.now().subtract(const Duration(days: 1000)),
            lastDay: DateTime.now().add(const Duration(days: 365)),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            rangeStartDay: _rangeStart,
            rangeEndDay: _rangeEnd,
            calendarFormat: CalendarFormat.month,
            availableGestures: AvailableGestures.horizontalSwipe,
            availableCalendarFormats: const {CalendarFormat.month: ''},
            rangeSelectionMode: _rangeSelectionMode,
            eventLoader: (day) => _getEventsForDay(events, day),
            startingDayOfWeek: StartingDayOfWeek.monday,
            calendarStyle: getWgerCalendarStyle(Theme.of(context)),
            onDaySelected: _onDaySelected,
            onRangeSelected: _onRangeSelected,
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
          ),
          const SizedBox(height: 8.0),
          Column(
            children: [
              ...selectedEvents.map(
                (event) => ListTile(
                  title: Text(
                    (() {
                      switch (event.type) {
                        case EventType.caloriesDiary:
                          return AppLocalizations.of(context).nutritionalDiary;
                        case EventType.session:
                          return AppLocalizations.of(context).workoutSession;
                        case EventType.weight:
                          return AppLocalizations.of(context).weight;
                        case EventType.measurement:
                          return AppLocalizations.of(context).measurement;
                      }
                    })(),
                  ),
                  subtitle: Text(event.description),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
