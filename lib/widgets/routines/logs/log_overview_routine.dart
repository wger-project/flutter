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

import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:wger/helpers/consts.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/models/workouts/routine.dart';
import 'package:wger/providers/trophies.dart';
import 'package:wger/theme/theme.dart';
import 'package:wger/widgets/routines/logs/day_logs_container.dart';

class WorkoutLogs extends ConsumerWidget {
  final Routine _routine;

  const WorkoutLogs(this._routine);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final languageCode = Localizations.localeOf(context).languageCode;
    final trophyNotifier = ref.read(trophyStateProvider.notifier);
    trophyNotifier.fetchUserTrophies(language: languageCode);

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      children: [
        Text(
          AppLocalizations.of(context).labelWorkoutLogs,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        SizedBox(
          width: double.infinity,
          child: WorkoutLogCalendar(_routine),
        ),
      ],
    );
  }
}

/// An event in the workout log calendar
class WorkoutLogEvent {
  final DateTime dateTime;

  const WorkoutLogEvent(this.dateTime);
}

class WorkoutLogCalendar extends StatefulWidget {
  final Routine _routine;

  const WorkoutLogCalendar(this._routine);

  @override
  _WorkoutLogCalendarState createState() => _WorkoutLogCalendarState();
}

class _WorkoutLogCalendarState extends State<WorkoutLogCalendar> {
  DateTime _focusedDay = clock.now();
  DateTime? _selectedDay;
  late final ValueNotifier<List<DateTime>> _selectedEvents;
  late Map<String, List<DateTime>> _events;

  @override
  void initState() {
    super.initState();

    _events = {};
    _selectedDay = _focusedDay;
    _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay!));
    loadEvents();
  }

  @override
  void dispose() {
    _selectedEvents.dispose();
    super.dispose();
  }

  void loadEvents() {
    for (final sessionApi in widget._routine.sessions) {
      _events[DateFormatLists.format(sessionApi.session.date)] = [
        sessionApi.session.date,
      ];
    }

    _selectedEvents.value = _getEventsForDay(_selectedDay!);
  }

  List<DateTime> _getEventsForDay(DateTime day) {
    return _events[DateFormatLists.format(day)] ?? [];
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
      });

      _selectedEvents.value = _getEventsForDay(selectedDay);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TableCalendar(
          locale: Localizations.localeOf(context).languageCode,
          firstDay: clock.now().subtract(const Duration(days: 1000)),
          lastDay: clock.now(),
          focusedDay: _focusedDay,
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          calendarFormat: CalendarFormat.month,
          startingDayOfWeek: StartingDayOfWeek.monday,
          calendarStyle: getWgerCalendarStyle(Theme.of(context)),
          eventLoader: _getEventsForDay,
          availableGestures: AvailableGestures.horizontalSwipe,
          availableCalendarFormats: const {CalendarFormat.month: ''},
          onDaySelected: _onDaySelected,
          onPageChanged: (focusedDay) {
            _focusedDay = focusedDay;
          },
        ),
        const SizedBox(height: 8.0),
        ExpansionTile(
          showTrailingIcon: false,
          dense: true,
          title: const Align(alignment: Alignment.centerLeft, child: Icon(Icons.info_outline)),
          children: [
            Text(
              AppLocalizations.of(context).logHelpEntries,
              textAlign: TextAlign.justify,
            ),
            Text(
              AppLocalizations.of(context).logHelpEntriesUnits,
              textAlign: TextAlign.justify,
            ),
          ],
        ),
        ValueListenableBuilder<List<DateTime>>(
          valueListenable: _selectedEvents,
          builder: (context, logEvents, _) {
            // At the moment there is only one "event" per day
            return logEvents.isNotEmpty
                ? DayLogWidget(logEvents.first, widget._routine)
                : Container();
          },
        ),
      ],
    );
  }
}
