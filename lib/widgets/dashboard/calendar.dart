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

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:wger/helpers/consts.dart';
import 'package:wger/helpers/json.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/providers/body_weight.dart';
import 'package:wger/providers/measurement.dart';
import 'package:wger/providers/nutrition.dart';
import 'package:wger/providers/routines.dart';
import 'package:wger/providers/user.dart';
import 'package:wger/theme/theme.dart';

/// Types of events
enum EventType { weight, measurement, session, caloriesDiary }

/// Color constants for event types - consistent across rings and modal
/// Modern complementary palette with distinct hues for easy differentiation
const Color eventColorSession = Color(0xFF22C55E); // Green - workouts
const Color eventColorNutrition = Color(0xFFF97316); // Orange - nutrition
const Color eventColorWeight = Color(0xFF3B82F6); // Blue - weight
const Color eventColorMeasurement = Color(0xFFEC4899); // Pink - measurements

/// Returns the color for an event type
Color getEventColor(EventType type) {
  switch (type) {
    case EventType.weight:
      return eventColorWeight;
    case EventType.measurement:
      return eventColorMeasurement;
    case EventType.session:
      return eventColorSession;
    case EventType.caloriesDiary:
      return eventColorNutrition;
  }
}

/// Returns the icon for an event type
IconData getEventIcon(EventType type) {
  switch (type) {
    case EventType.weight:
      return Icons.monitor_weight_outlined;
    case EventType.measurement:
      return Icons.straighten_outlined;
    case EventType.session:
      return Icons.fitness_center_outlined;
    case EventType.caloriesDiary:
      return Icons.restaurant_outlined;
  }
}

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

class DashboardCalendarWidget extends StatefulWidget {
  const DashboardCalendarWidget();

  @override
  _DashboardCalendarWidgetState createState() => _DashboardCalendarWidgetState();
}

class _DashboardCalendarWidgetState extends State<DashboardCalendarWidget>
    with TickerProviderStateMixin {
  late Map<String, List<Event>> _events;
  DateTime _focusedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    _events = <String, List<Event>>{};
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadEvents();
    });
  }

  /// Loads and organizes all events from various providers into the calendar.
  void loadEvents() async {
    final numberFormat = NumberFormat.decimalPattern(Localizations.localeOf(context).toString());
    final i18n = AppLocalizations.of(context);

    // Process weight entries
    final weightProvider = context.read<BodyWeightProvider>();
    for (final entry in weightProvider.items) {
      final date = DateFormatLists.format(entry.date);

      if (!_events.containsKey(date)) {
        _events[date] = [];
      }

      _events[date]?.add(Event(EventType.weight, '${numberFormat.format(entry.weight)} kg'));
    }

    // Process measurements
    final measurementProvider = context.read<MeasurementProvider>();
    for (final category in measurementProvider.categories) {
      for (final entry in category.entries) {
        final date = DateFormatLists.format(entry.date);

        if (!_events.containsKey(date)) {
          _events[date] = [];
        }

        _events[date]?.add(
          Event(
            EventType.measurement,
            '${category.name}: ${numberFormat.format(entry.value)} ${category.unit}',
          ),
        );
      }
    }

    // Process workout sessions
    final routinesProvider = context.read<RoutinesProvider>();
    final sessions = await routinesProvider.fetchSessionData();
    if (!mounted) {
      return;
    }
    for (final session in sessions) {
      final date = DateFormatLists.format(session.date);
      if (!_events.containsKey(date)) {
        _events[date] = [];
      }
      final time = '(${timeToString(session.timeStart)} - ${timeToString(session.timeEnd)})';

      _events[date]?.add(
        Event(
          EventType.session,
          '${i18n.impression}: ${session.impressionAsString(context)} $time',
        ),
      );
    }

    // Process nutritional plans
    final NutritionPlansProvider nutritionProvider = Provider.of<NutritionPlansProvider>(
      context,
      listen: false,
    );
    for (final plan in nutritionProvider.items) {
      for (final entry in plan.logEntriesValues.entries) {
        final date = DateFormatLists.format(entry.key);
        if (!_events.containsKey(date)) {
          _events[date] = [];
        }

        _events[date]?.add(
          Event(EventType.caloriesDiary, i18n.kcalValue(entry.value.energy.toStringAsFixed(0))),
        );
      }
    }

    // Trigger rebuild to show loaded events
    if (mounted) {
      setState(() {});
    }
  }

  List<Event> _getEventsForDay(DateTime day) {
    return _events[DateFormatLists.format(day)] ?? [];
  }

  /// Get unique event types for a day (for ring display)
  Set<EventType> _getEventTypesForDay(DateTime day) {
    final events = _getEventsForDay(day);
    return events.map((e) => e.type).toSet();
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _focusedDay = focusedDay;
    });

    final events = _getEventsForDay(selectedDay);
    if (events.isNotEmpty) {
      _showEventsModal(context, selectedDay, events);
    }
  }

  void _showEventsModal(BuildContext context, DateTime day, List<Event> events) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final dateFormat = DateFormat.yMMMMd(Localizations.localeOf(context).toString());

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.6,
        ),
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF1C1C1E) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header with date
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  dateFormat.format(day),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Divider(
              height: 1,
              color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
            ),
            // Event list
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: events.length,
                separatorBuilder: (context, index) => Divider(
                  height: 1,
                  indent: 68,
                  color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
                ),
                itemBuilder: (context, index) {
                  final event = events[index];
                  return _EventModalItem(event: event);
                },
              ),
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Material(
        elevation: 0,
        color: Colors.transparent,
        child: Container(
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
          child: Column(
            children: [
              // Modern header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    AppLocalizations.of(context).calendar,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              // Calendar with custom day builder
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
                child: TableCalendar<Event>(
                  locale: Localizations.localeOf(context).languageCode,
                  firstDay: DateTime.now().subtract(const Duration(days: 1000)),
                  lastDay: DateTime.now().add(const Duration(days: 365)),
                  focusedDay: _focusedDay,
                  calendarFormat: CalendarFormat.month,
                  availableGestures: AvailableGestures.horizontalSwipe,
                  availableCalendarFormats: const {CalendarFormat.month: ''},
                  startingDayOfWeek: context.watch<UserProvider>().firstDayOfWeek,
                  headerStyle: HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                    titleTextStyle: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                    leftChevronIcon: Icon(
                      Icons.chevron_left,
                      color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
                    ),
                    rightChevronIcon: Icon(
                      Icons.chevron_right,
                      color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
                    ),
                  ),
                  daysOfWeekStyle: DaysOfWeekStyle(
                    weekdayStyle: TextStyle(
                      color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                    weekendStyle: TextStyle(
                      color: wgerSecondaryColor.withValues(alpha: 0.8),
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                  calendarStyle: const CalendarStyle(
                    outsideDaysVisible: false,
                    cellMargin: EdgeInsets.all(4),
                    // Hide default markers - we use custom rings
                    markersMaxCount: 0,
                  ),
                  calendarBuilders: CalendarBuilders(
                    defaultBuilder: (context, day, focusedDay) {
                      return _buildDayCell(context, day, isToday: false);
                    },
                    todayBuilder: (context, day, focusedDay) {
                      return _buildDayCell(context, day, isToday: true);
                    },
                    outsideBuilder: (context, day, focusedDay) {
                      return const SizedBox.shrink();
                    },
                  ),
                  onDaySelected: _onDaySelected,
                  onPageChanged: (focusedDay) {
                    _focusedDay = focusedDay;
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds a day cell with activity rings
  Widget _buildDayCell(BuildContext context, DateTime day, {required bool isToday}) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final eventTypes = _getEventTypesForDay(day);

    return GestureDetector(
      onTap: () => _onDaySelected(day, day),
      child: Container(
        margin: const EdgeInsets.all(2),
        child: CustomPaint(
          painter: _ActivityRingsPainter(
            eventTypes: eventTypes,
            isToday: isToday,
            isDarkMode: isDarkMode,
          ),
          child: Center(
            child: Container(
              width: 22,
              height: 22,
              decoration: isToday
                  ? BoxDecoration(
                      color: isDarkMode ? const Color(0xFF374151) : Colors.grey.shade300,
                      shape: BoxShape.circle,
                    )
                  : null,
              child: Center(
                child: Text(
                  '${day.day}',
                  style: TextStyle(
                    color: isToday
                        ? (isDarkMode ? Colors.white : Colors.black87)
                        : (isDarkMode ? Colors.grey.shade300 : Colors.grey.shade700),
                    fontWeight: isToday ? FontWeight.w600 : FontWeight.normal,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Custom painter for activity rings around day cells
class _ActivityRingsPainter extends CustomPainter {
  final Set<EventType> eventTypes;
  final bool isToday;
  final bool isDarkMode;

  // Ring order from outside to inside: session, nutrition, weight, measurement
  static const List<EventType> ringOrder = [
    EventType.session,
    EventType.caloriesDiary,
    EventType.weight,
    EventType.measurement,
  ];

  _ActivityRingsPainter({
    required this.eventTypes,
    required this.isToday,
    required this.isDarkMode,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (eventTypes.isEmpty) {
      return;
    }

    final center = Offset(size.width / 2, size.height / 2);
    final baseRadius = min(size.width, size.height) / 2;

    // Draw rings at fixed positions based on their index in ringOrder
    // Each type always has the same radius regardless of which other types are present
    for (int i = 0; i < ringOrder.length; i++) {
      final type = ringOrder[i];

      // Only draw if this event type is present
      if (!eventTypes.contains(type)) {
        continue;
      }

      final color = getEventColor(type);

      // Fixed radius for each ring position (outermost to innermost)
      final ringRadius = baseRadius - 1 - (i * 3.0);
      const strokeWidth = 2.0;

      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      // Draw full circle ring
      canvas.drawCircle(center, ringRadius, paint);
    }
  }

  @override
  bool shouldRepaint(_ActivityRingsPainter oldDelegate) {
    return oldDelegate.eventTypes != eventTypes ||
        oldDelegate.isToday != isToday ||
        oldDelegate.isDarkMode != isDarkMode;
  }
}

/// Event item displayed in the modal
class _EventModalItem extends StatelessWidget {
  final Event event;

  const _EventModalItem({required this.event});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final eventColor = getEventColor(event.type);
    final eventIcon = getEventIcon(event.type);

    String eventTitle;
    switch (event.type) {
      case EventType.caloriesDiary:
        eventTitle = AppLocalizations.of(context).nutritionalDiary;
        break;
      case EventType.session:
        eventTitle = AppLocalizations.of(context).workoutSession;
        break;
      case EventType.weight:
        eventTitle = AppLocalizations.of(context).weight;
        break;
      case EventType.measurement:
        eventTitle = AppLocalizations.of(context).measurement;
        break;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          // Colored icon container
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: eventColor.withValues(alpha: isDarkMode ? 0.2 : 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              eventIcon,
              color: eventColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          // Event info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  eventTitle,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  event.description,
                  style: TextStyle(
                    color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
                    fontSize: 13,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          // Color indicator dot
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: eventColor,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}
