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
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:wger/helpers/json.dart';
import 'package:wger/models/workouts/session.dart';
import 'package:wger/providers/body_weight.dart';
import 'package:wger/providers/nutrition.dart';
import 'package:wger/providers/workout_plans.dart';
import 'package:wger/theme/theme.dart';

// Example holidays
//
// (perhaps we can do something with this, such as marking future training days?)
final Map<DateTime, List> _holidays = {
  DateTime(2021, 1, 1): ['New Year\'s Day'],
  DateTime(2021, 1, 6): ['Epiphany'],
  DateTime(2021, 2, 14): ['Valentine\'s Day'],
  DateTime(2021, 4, 21): ['Easter Sunday'],
  DateTime(2021, 4, 22): ['Easter Monday'],
};

/// Types of events
enum EventType {
  weight,
  session,
  caloriesDiary,
}

/// An event in the dashboard calendar
class Event {
  final EventType _type;
  final String _description;

  Event(this._type, this._description);

  get description {
    return _description;
  }

  get type {
    return _type;
  }
}

class DashboardCalendarWidget extends StatefulWidget {
  DashboardCalendarWidget();

  @override
  _DashboardCalendarWidgetState createState() => _DashboardCalendarWidgetState();
}

class _DashboardCalendarWidgetState extends State<DashboardCalendarWidget>
    with TickerProviderStateMixin {
  late Map<DateTime, List> _events;
  late List _selectedEvents;
  late AnimationController _animationController;
  late CalendarController _calendarController;

  @override
  void initState() {
    super.initState();
    final _selectedDay = DateTime.now();

    _events = {};

    _selectedEvents = _events[_selectedDay] ?? [];
    _calendarController = CalendarController();
    //_calendarController.setCalendarFormat(CalendarFormat.month);

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _animationController.forward();

    loadEvents();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _calendarController.dispose();
    super.dispose();
  }

  void loadEvents() async {
    // Process weight entries
    BodyWeight weightProvider = Provider.of<BodyWeight>(context, listen: false);
    for (var entry in weightProvider.items) {
      final date = DateTime(entry.date.year, entry.date.month, entry.date.day);
      if (!_events.containsKey(date)) {
        _events[date] = [];
      }

      // Add events to lists
      _events[date]!.add(Event(EventType.weight, '${entry.weight} kg'));
    }

    // Process workout sessions
    WorkoutPlans plans = Provider.of<WorkoutPlans>(context, listen: false);
    plans.fetchSessionData().then((entries) {
      for (var entry in entries['results']) {
        final session = WorkoutSession.fromJson(entry);
        final date = DateTime(session.date.year, session.date.month, session.date.day);
        if (!_events.containsKey(date)) {
          _events[date] = [];
        }

        var time = '';
        if (session.timeStart != null && session.timeEnd != null) {
          time = '(${timeToString(session.timeStart)} - ${timeToString(session.timeEnd)})';
        }

        // Add events to lists
        _events[date]!.add(Event(
          EventType.session,
          '${AppLocalizations.of(context)!.impression}: ${session.impressionAsString} $time',
        ));
      }
    });

    // Process nutritional plans
    Nutrition nutritionProvider = Provider.of<Nutrition>(context, listen: false);
    for (var plan in nutritionProvider.items) {
      for (var entry in plan.logEntriesValues.entries) {
        final date = DateTime(entry.key.year, entry.key.month, entry.key.day);
        if (!_events.containsKey(date)) {
          _events[date] = [];
        }

        // Add events to lists
        _events[date]!.add(Event(
          EventType.caloriesDiary,
          '${entry.value.energy.toStringAsFixed(0)} kcal',
        ));
      }
    }

    setState(() {
      _events;
    });
  }

  void _onDaySelected(DateTime day, List events, List holidays) {
    log('CALLBACK: _onDaySelected');
    setState(() {
      _selectedEvents = events;
    });
  }

  void _onVisibleDaysChanged(DateTime first, DateTime last, CalendarFormat format) {
    log('CALLBACK: _onVisibleDaysChanged');
  }

  void _onCalendarCreated(DateTime first, DateTime last, CalendarFormat format) {
    log('CALLBACK: _onCalendarCreated');
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          const SizedBox(height: 8.0),
          Text(
            AppLocalizations.of(context)!.calendar,
            style: Theme.of(context).textTheme.headline4,
          ),

          // Switch out 2 lines below to play with TableCalendar's settings
          //-----------------------
          _buildTableCalendar(),
          //_buildTableCalendarWithBuilders(),
          const SizedBox(height: 8.0),
          _buildButtons(),
          const SizedBox(height: 8.0),
          Expanded(child: _buildEventList()),
        ],
      ),
    );
  }

  // Simple TableCalendar configuration (using Styles)
  Widget _buildTableCalendar() {
    return TableCalendar(
      availableGestures: AvailableGestures.horizontalSwipe,
      availableCalendarFormats: {CalendarFormat.month: 'Month'},
      calendarController: _calendarController,
      events: _events,
      holidays: _holidays,
      startingDayOfWeek: StartingDayOfWeek.monday,
      calendarStyle: CalendarStyle(
        selectedColor: wgerSecondaryColor,
        todayColor: Colors.deepOrange[200],
        markersColor: Colors.brown[700],
        outsideDaysVisible: false,
      ),
      headerStyle: HeaderStyle(
        formatButtonTextStyle: TextStyle().copyWith(color: Colors.white, fontSize: 15.0),
        formatButtonDecoration: BoxDecoration(
          color: Colors.deepOrange[400],
          borderRadius: BorderRadius.circular(16.0),
        ),
      ),
      onDaySelected: _onDaySelected,
      onVisibleDaysChanged: _onVisibleDaysChanged,
      onCalendarCreated: _onCalendarCreated,
    );
  }

  // More advanced TableCalendar configuration (using Builders & Styles)
  Widget _buildTableCalendarWithBuilders() {
    return TableCalendar(
      locale: 'pl_PL',
      calendarController: _calendarController,
      events: _events,
      holidays: _holidays,
      initialCalendarFormat: CalendarFormat.month,
      formatAnimation: FormatAnimation.slide,
      startingDayOfWeek: StartingDayOfWeek.sunday,
      availableGestures: AvailableGestures.all,
      availableCalendarFormats: const {
        CalendarFormat.month: '',
        CalendarFormat.week: '',
      },
      calendarStyle: CalendarStyle(
        outsideDaysVisible: false,
        weekendStyle: TextStyle().copyWith(color: Colors.blue[800]),
        holidayStyle: TextStyle().copyWith(color: Colors.blue[800]),
      ),
      daysOfWeekStyle: DaysOfWeekStyle(
        weekendStyle: TextStyle().copyWith(color: Colors.blue[600]),
      ),
      headerStyle: HeaderStyle(
        centerHeaderTitle: true,
        formatButtonVisible: false,
      ),
      builders: CalendarBuilders(
        selectedDayBuilder: (context, date, _) {
          return FadeTransition(
            opacity: Tween(begin: 0.0, end: 1.0).animate(_animationController),
            child: Container(
              margin: const EdgeInsets.all(4.0),
              padding: const EdgeInsets.only(top: 5.0, left: 6.0),
              color: Colors.deepOrange[300],
              width: 100,
              height: 100,
              child: Text(
                '${date.day}',
                style: TextStyle().copyWith(fontSize: 16.0),
              ),
            ),
          );
        },
        todayDayBuilder: (context, date, _) {
          return Container(
            margin: const EdgeInsets.all(4.0),
            padding: const EdgeInsets.only(top: 5.0, left: 6.0),
            color: Colors.amber[400],
            width: 100,
            height: 100,
            child: Text(
              '${date.day}',
              style: TextStyle().copyWith(fontSize: 16.0),
            ),
          );
        },
        markersBuilder: (context, date, events, holidays) {
          final children = <Widget>[];

          if (events.isNotEmpty) {
            children.add(
              Positioned(
                right: 1,
                bottom: 1,
                child: _buildEventsMarker(date, events),
              ),
            );
          }

          if (holidays.isNotEmpty) {
            children.add(
              Positioned(
                right: -2,
                top: -2,
                child: _buildHolidaysMarker(),
              ),
            );
          }

          return children;
        },
      ),
      onDaySelected: (date, events, holidays) {
        _onDaySelected(date, events, holidays);
        _animationController.forward(from: 0.0);
      },
      onVisibleDaysChanged: _onVisibleDaysChanged,
      onCalendarCreated: _onCalendarCreated,
    );
  }

  Widget _buildEventsMarker(DateTime date, List events) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        color: _calendarController.isSelected(date)
            ? Colors.brown[500]
            : _calendarController.isToday(date)
                ? Colors.brown[300]
                : Colors.blue[400],
      ),
      width: 16.0,
      height: 16.0,
      child: Center(
        child: Text(
          '${events.length}',
          style: TextStyle().copyWith(
            color: Colors.white,
            fontSize: 12.0,
          ),
        ),
      ),
    );
  }

  Widget _buildHolidaysMarker() {
    return Icon(
      Icons.add_box,
      size: 20.0,
      color: Colors.blueGrey[800],
    );
  }

  Widget _buildButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        TextButton(
          child: Text(AppLocalizations.of(context)!.goToToday),
          onPressed: () async {
            final today = DateTime.now();
            _calendarController.setSelectedDay(
              DateTime(today.year, today.month, today.day),
              runCallback: true,
            );
          },
        ),
      ],
    );
  }

  Widget _buildEventList() {
    return ListView(
      children: _selectedEvents
          .map(
            (event) => Container(
              width: double.infinity,
              child: ListTile(
                title: Text((() {
                  switch (event.type) {
                    case EventType.caloriesDiary:
                      return AppLocalizations.of(context)!.nutritionalDiary;

                    case EventType.session:
                      return AppLocalizations.of(context)!.workoutSession;

                    case EventType.weight:
                      return AppLocalizations.of(context)!.weight;
                  }
                  return event.description.toString();
                })()),
                subtitle: Text(event.description.toString()),
                onTap: () => print('$event tapped!'),
              ),
            ),
          )
          .toList(),
    );
  }
}
