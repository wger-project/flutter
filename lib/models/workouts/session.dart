/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (C) 2020, 2025 wger Team
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

import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:wger/database/powersync/database.dart';
import 'package:wger/models/exercises/exercise.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:wger/helpers/json.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/models/workouts/log.dart';

const IMPRESSION_MAP = {1: 'bad', 2: 'neutral', 3: 'good'};

class WorkoutSession {
  final _logger = Logger('WorkoutSession');

  String? id;
  late int? routineId;
  int? dayId;
  late DateTime date;
  late int impression;
  late String? notes;
  late TimeOfDay? timeStart;
  late TimeOfDay? timeEnd;

  List<Log> logs = [];

  WorkoutSession({
    this.id,
    this.dayId,
    required this.routineId,
    this.impression = 2,
    this.notes = '',
    this.timeStart,
    this.timeEnd,
    this.logs = const [],
    DateTime? date,
  }) {
    this.date = date ?? DateTime.now();
  }

  WorkoutSessionTableCompanion toCompanion({bool includeId = false}) {
    return WorkoutSessionTableCompanion(
      id: includeId && id != null ? drift.Value(id!) : const drift.Value.absent(),
      routineId: routineId != null ? drift.Value(routineId) : const drift.Value.absent(),
      dayId: dayId != null ? drift.Value(dayId) : const drift.Value.absent(),
      date: drift.Value(date.toUtc()),
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
  Map<String, Object> get volume {
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

  String impressionAsString(BuildContext context) {
    if (impression == 1) {
      return AppLocalizations.of(context).impressionBad;
    } else if (impression == 2) {
      return AppLocalizations.of(context).impressionNeutral;
    } else if (impression == 3) {
      return AppLocalizations.of(context).impressionGood;
    }

    _logger.warning('Unknown impression value: $impression');
    return AppLocalizations.of(context).impressionGood;
  }
}
