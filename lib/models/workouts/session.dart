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
import 'package:flutter/material.dart';
import 'package:wger/database/powersync/database.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/models/exercises/exercise.dart';
import 'package:wger/models/workouts/log.dart';

/// User's general impression of a workout session.
///
/// The wire values mirror Django's `WorkoutSession.IMPRESSION` choices
/// (`CharField` with `'1'`, `'2'`, `'3'`), so the same string round-trips
/// through PowerSync without any extra mapping on the connector.
enum WorkoutImpression {
  bad('1'),
  neutral('2'),
  good('3')
  ;

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

class WorkoutSession {
  /// `null` only for instances built in-memory before the first persist;
  /// Drift fills it in via the table's `clientDefault` UUID.
  String? id;
  late int? routineId;
  int? dayId;
  DateTime date;
  WorkoutImpression impression;
  late String? notes;
  late TimeOfDay? timeStart;
  late TimeOfDay? timeEnd;

  List<Log> logs = [];

  WorkoutSession({
    this.id,
    this.dayId,
    required this.routineId,
    this.impression = WorkoutImpression.neutral,
    this.notes = '',
    this.timeStart,
    this.timeEnd,
    this.logs = const [],
    DateTime? date,
  }) : date = date ?? clock.now();

  WorkoutSessionTableCompanion toCompanion() {
    return WorkoutSessionTableCompanion(
      id: id != null ? drift.Value(id!) : const drift.Value.absent(),
      routineId: routineId != null ? drift.Value(routineId) : const drift.Value.absent(),
      dayId: dayId != null ? drift.Value(dayId) : const drift.Value.absent(),
      // Server-side `date` is a `DateField` (no time, no TZ). We  send here the
      // calendar day the user picked, packaged as midnight-UTC so it round-trips
      // through PowerSync's ISO8601 wire format and lands on the right day on
      // the server.
      date: drift.Value(DateTime.utc(date.year, date.month, date.day)),
      notes: drift.Value(notes),
      impression: drift.Value(impression),
      timeStart: timeStart != null ? drift.Value(timeStart) : const drift.Value.absent(),
      timeEnd: timeEnd != null ? drift.Value(timeEnd) : const drift.Value.absent(),
    );
  }

  Duration? get duration {
    if (timeStart == null || timeEnd == null) {
      return null;
    }
    final now = DateTime.now();
    final startDate = DateTime(now.year, now.month, now.day, timeStart!.hour, timeStart!.minute);
    final endDate = DateTime(now.year, now.month, now.day, timeEnd!.hour, timeEnd!.minute);
    return endDate.difference(startDate);
  }

  String durationTxt(BuildContext context) {
    final duration = this.duration;
    if (duration == null) {
      return '-/-';
    }
    return AppLocalizations.of(
      context,
    ).durationHoursMinutes(duration.inHours, duration.inMinutes.remainder(60));
  }

  String durationTxtWithStartEnd(BuildContext context) {
    final duration = this.duration;
    if (duration == null) {
      return '-/-';
    }

    final startTime = MaterialLocalizations.of(context).formatTimeOfDay(timeStart!);
    final endTime = MaterialLocalizations.of(context).formatTimeOfDay(timeEnd!);

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
