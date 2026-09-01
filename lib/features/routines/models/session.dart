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
import 'package:drift/drift.dart' as drift;
import 'package:material_ui/material_ui.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:wger/core/date.dart';
import 'package:wger/database/powersync/database.dart';
import 'package:wger/features/exercises/models/exercise.dart';
import 'package:wger/features/routines/models/log.dart';
import 'package:wger/l10n/generated/app_localizations.dart';

part 'session.freezed.dart';

/// User's general impression of a workout session.
///
/// The wire values mirror Django's `WorkoutSession.IMPRESSION` choices
/// (`CharField` with `'1'`, `'2'`, `'3'`), so the same string round-trips
/// through PowerSync without any extra mapping on the connector.
enum WorkoutImpression {
  bad('1'),
  neutral('2'),
  good('3');

  final String wireValue;
  const WorkoutImpression(this.wireValue);

  /// Looks up an enum case by its Django wire value.
  static WorkoutImpression fromWire(String value) =>
      WorkoutImpression.values.firstWhere((e) => e.wireValue == value);
}

extension WorkoutImpressionL10n on WorkoutImpression {
  /// Localized human-readable label (e.g. "Good", "Neutral", "Bad").
  String localized(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return switch (this) {
      WorkoutImpression.bad => l10n.impressionBad,
      WorkoutImpression.neutral => l10n.impressionNeutral,
      WorkoutImpression.good => l10n.impressionGood,
    };
  }
}

/// How long after its start an ongoing session still picks up new logs
const sessionMaxDuration = Duration(hours: 5);

@freezed
class WorkoutSession with _$WorkoutSession {
  /// Inclusive upper bound for [notes]
  static const maxNotesChars = 1000;

  /// Client-generated UUID, is `null` only before the first persist
  @override
  final String? id;
  @override
  final int? routineId;
  @override
  final int? dayId;
  @override
  final WorkoutImpression impression;
  @override
  final String? notes;
  @override
  final DateTime datetimeStart;
  @override
  final DateTime? datetimeEnd;
  @override
  final List<Log> logs;

  WorkoutSession({
    this.id,
    this.dayId,
    required this.routineId,
    required this.datetimeStart,
    this.datetimeEnd,
    this.impression = WorkoutImpression.neutral,
    this.notes = '',
    this.logs = const [],
  });

  /// Builds the model from a database row.
  ///
  /// Rows that were replicated before 2.7 have no `datetime_start` in their
  /// stored JSON and read as NULL, for as long as that local database lives.
  /// They are rebuilt from the pre-2.7 date and time columns. Application code
  /// uses the default constructor.
  factory WorkoutSession.fromDb({
    String? id,
    int? routineId,
    int? dayId,
    String? notes,
    WorkoutImpression impression = WorkoutImpression.neutral,
    DateTime? datetimeStart,
    DateTime? datetimeEnd,
    DateTime? date,
    TimeOfDay? timeStart,
    TimeOfDay? timeEnd,
  }) {
    DateTime on(DateTime day, TimeOfDay? time) =>
        DateTime(day.year, day.month, day.day, time?.hour ?? 0, time?.minute ?? 0);

    final start = datetimeStart ?? (date == null ? clock.now() : on(date, timeStart));

    var end = datetimeEnd;
    if (end == null && date != null && timeEnd != null) {
      end = on(date, timeEnd);
      // An end before the start means the session ran past midnight
      if (end.isBefore(start)) {
        end = end.add(const Duration(days: 1));
      }
    }

    return WorkoutSession(
      id: id,
      routineId: routineId,
      dayId: dayId,
      notes: notes,
      impression: impression,
      datetimeStart: start,
      datetimeEnd: end,
    );
  }

  WorkoutSessionTableCompanion toCompanion() {
    return WorkoutSessionTableCompanion(
      id: id != null ? drift.Value(id!) : const drift.Value.absent(),
      routineId: drift.Value(routineId),
      dayId: drift.Value(dayId),
      notes: drift.Value(notes),
      impression: drift.Value(impression),
      // Explicit NULL, not absent: clearing the end has to clear the column too.
      // The pre-2.7 columns are never written again, only read by fromDb.
      datetimeStart: drift.Value(datetimeStart),
      datetimeEnd: drift.Value(datetimeEnd),
    );
  }

  /// The calendar day this session counts for, e.g. for the dashboard calendar
  ///
  /// A session that runs over midnight counts for the day it started on, cut
  /// in the owner's profile zone like the server's local_day (the zone comes
  /// from ownerTimeZoneProvider; the device zone stands in while it is null)
  DateTime localDayIn(String? zoneName) => dayIn(datetimeStart, zoneName);

  /// Duration between start and end, null while the session is still open
  Duration? get duration {
    final end = datetimeEnd;
    if (end == null) {
      return null;
    }

    return end.difference(datetimeStart);
  }

  /// Returns a localized string representation of the duration (e.g., "2h 30m").
  String durationTxt(BuildContext context) {
    final duration = this.duration;
    if (duration == null) {
      return '-/-';
    }
    return AppLocalizations.of(
      context,
    ).durationHoursMinutes(duration.inHours, duration.inMinutes.remainder(60));
  }

  /// Returns a formatted string: "2h 30m (09:00 AM - 11:30 AM)".
  String durationTxtWithStartEnd(BuildContext context) {
    final end = datetimeEnd;
    if (end == null) {
      return '-/-';
    }

    final localizations = MaterialLocalizations.of(context);
    final startTime = localizations.formatTimeOfDay(TimeOfDay.fromDateTime(datetimeStart));
    final endTime = localizations.formatTimeOfDay(TimeOfDay.fromDateTime(end));

    return '${durationTxt(context)} ($startTime - $endTime)';
  }

  /// Get total volume of the session for metric and imperial units
  /// (i.e. sets that have "repetitions" as units and weight in kg or lbs).
  /// Other combinations such as "seconds" are ignored.
  Map<String, num> get volume {
    final volumeMetric = logs.fold<double>(0, (sum, log) => sum + log.volume(metric: true));
    final volumeImperial = logs.fold<double>(0, (sum, log) => sum + log.volume(metric: false));

    return {'metric': volumeMetric, 'imperial': volumeImperial};
  }

  List<Exercise> get exercises {
    final Set<Exercise> exerciseSet = {};
    for (final log in logs) {
      exerciseSet.add(log.exerciseObj);
    }
    return exerciseSet.toList();
  }
}
