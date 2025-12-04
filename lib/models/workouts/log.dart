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
import 'package:wger/database/powersync/database.dart';
import 'package:wger/helpers/consts.dart';
import 'package:wger/helpers/misc.dart';
import 'package:wger/models/exercises/exercise.dart';
import 'package:wger/models/workouts/repetition_unit.dart';
import 'package:wger/models/workouts/set_config_data.dart';
import 'package:wger/models/workouts/weight_unit.dart';

enum LogTargetStatus {
  lessThanTarget,
  atTarget,
  moreThanTarget,
  notSet,
}

class Log {
  String? id;

  late int exerciseId;
  late Exercise exerciseObj;

  late int routineId;
  late int? sessionId;
  int? iteration;
  int? slotEntryId;
  num? rir;
  num? rirTarget;

  num? repetitions;
  num? repetitionsTarget;
  late int? repetitionsUnitId;
  late RepetitionUnit? repetitionsUnitObj;

  late num? weight;
  num? weightTarget;
  late int? weightUnitId;
  late WeightUnit? weightUnitObj;

  late DateTime date;

  Log({
    this.id,
    required this.exerciseId,
    this.iteration,
    this.slotEntryId,
    required this.routineId,
    this.repetitions,
    this.repetitionsTarget,
    this.repetitionsUnitId = REP_UNIT_REPETITIONS_ID,
    required this.rir,
    this.rirTarget,
    this.weight,
    this.weightTarget,
    this.weightUnitId = WEIGHT_UNIT_KG,
    required this.date,
  });

  Log.fromSetConfigData(SetConfigData data, {int? routineId, this.iteration}) {
    date = DateTime.now();
    sessionId = null;

    slotEntryId = data.slotEntryId;
    exercise = data.exercise;

    if (data.weight != null) {
      weight = data.weight;
      weightTarget = data.weight;
    }
    if (data.weightUnit != null) {
      weightUnit = data.weightUnit;
    }

    if (data.repetitions != null) {
      repetitions = data.repetitions;
      repetitionsTarget = data.repetitions;
    }
    if (data.repetitionsUnit != null) {
      repetitionUnit = data.repetitionsUnit;
    }

    rir = data.rir;
    rirTarget = data.rir;

    if (routineId != null) {
      this.routineId = routineId;
    }
  }

  WorkoutLogTableCompanion toCompanion({bool includeId = false}) {
    return WorkoutLogTableCompanion(
      id: includeId && id != null ? drift.Value(id!) : const drift.Value.absent(),
      exerciseId: drift.Value(exerciseId),
      routineId: drift.Value(routineId),
      sessionId: sessionId != null ? drift.Value(sessionId) : const drift.Value.absent(),
      iteration: iteration != null ? drift.Value(iteration) : const drift.Value.absent(),
      slotEntryId: slotEntryId != null ? drift.Value(slotEntryId) : const drift.Value.absent(),
      rir: rir != null ? drift.Value(rir!.toDouble()) : const drift.Value.absent(),
      rirTarget: rirTarget != null
          ? drift.Value(rirTarget!.toDouble())
          : const drift.Value.absent(),
      repetitions: repetitions != null
          ? drift.Value(repetitions!.toDouble())
          : const drift.Value.absent(),
      repetitionsTarget: repetitionsTarget != null
          ? drift.Value(repetitionsTarget!.toDouble())
          : const drift.Value.absent(),
      repetitionsUnitId: repetitionsUnitId != null
          ? drift.Value(repetitionsUnitId)
          : const drift.Value.absent(),
      weight: weight != null ? drift.Value(weight!.toDouble()) : const drift.Value.absent(),
      weightTarget: weightTarget != null
          ? drift.Value(weightTarget!.toDouble())
          : const drift.Value.absent(),
      weightUnitId: weightUnitId != null ? drift.Value(weightUnitId) : const drift.Value.absent(),
      date: drift.Value(date.toUtc()),
    );
  }

  set exercise(Exercise exercise) {
    exerciseObj = exercise;
    exerciseId = exercise.id;
  }

  set weightUnit(WeightUnit? weightUnit) {
    weightUnitObj = weightUnit;
    weightUnitId = weightUnit?.id;
  }

  set repetitionUnit(RepetitionUnit? repetitionUnit) {
    repetitionsUnitObj = repetitionUnit;
    repetitionsUnitId = repetitionUnit?.id;
  }

  /// Returns the text representation for a single setting, removes new lines
  String repTextNoNl(BuildContext context) {
    return repText(context).replaceAll('\n', '');
  }

  /// Returns the text representation for a single setting
  String repText(BuildContext context) {
    final List<String> out = [];

    if (repetitions != null) {
      out.add(formatNum(repetitions!).toString());

      // The default repetition unit is 'reps', which we don't show unless there
      // is no weight defined so that we don't just output something like "8" but
      // rather "8 repetitions". If there is weight we want to output "8 x 50kg",
      // since the repetitions are implied. If other units are used, we always
      // print them
      if (repetitionsUnitObj != null && repetitionsUnitObj!.id != REP_UNIT_REPETITIONS_ID ||
          weight == 0 ||
          weight == null) {
        out.add(getServerStringTranslation(repetitionsUnitObj!.name, context));
      }
    }

    if (weight != null && weight != 0) {
      out.add('×');
      out.add(formatNum(weight!).toString());
      out.add(weightUnitObj!.name);
    }

    if (rir != null) {
      out.add('\n($rir RiR)');
    }

    return out.join(' ');
  }

  /// Calculates the volume for this log entry
  num volume({bool metric = true}) {
    final unitId = metric ? WEIGHT_UNIT_KG : WEIGHT_UNIT_LB;

    if (weight != null &&
        weightUnitId == unitId &&
        repetitions != null &&
        repetitionsUnitId == REP_UNIT_REPETITIONS_ID) {
      return weight! * repetitions!;
    }
    return 0;
  }

  LogTargetStatus get targetStatus {
    if (weightTarget == null && repetitionsTarget == null && rirTarget == null) {
      return LogTargetStatus.notSet;
    }

    final weightOk = weightTarget == null || (weight != null && weight! >= weightTarget!);
    final repsOk =
        repetitionsTarget == null || (repetitions != null && repetitions! >= repetitionsTarget!);
    final rirOk = rirTarget == null || (rir != null && rir! <= rirTarget!);

    if (weightOk && repsOk && rirOk) {
      return LogTargetStatus.atTarget;
    }

    final weightMore = weightTarget != null && weight != null && weight! > weightTarget!;
    final repsMore =
        repetitionsTarget != null && repetitions != null && repetitions! > repetitionsTarget!;
    final rirLess = rirTarget != null && rir != null && rir! < rirTarget!;

    if (weightMore || repsMore || rirLess) {
      return LogTargetStatus.moreThanTarget;
    }

    return LogTargetStatus.lessThanTarget;
  }

  /// Override the equals operator
  ///
  /// Two logs are considered equal if their content is equal. This is used e.g.
  /// in lists where we want to have unique values
  @override
  //ignore: avoid_equals_and_hash_code_on_mutable_classes
  bool operator ==(o) {
    return o is Log &&
        exerciseId == o.exerciseId &&
        weight == o.weight &&
        weightUnitId == o.weightUnitId &&
        repetitions == o.repetitions &&
        repetitionsUnitId == o.repetitionsUnitId &&
        rir == o.rir;
  }

  @override
  //ignore: avoid_equals_and_hash_code_on_mutable_classes
  int get hashCode =>
      Object.hash(exerciseId, weight, weightUnitId, repetitions, repetitionsUnitId, rir);

  @override
  String toString() {
    return 'Log(id: $id, ex: $exerciseId, weightU: $weightUnitId, w: $weight, repU: $repetitionsUnitId, rep: $repetitions, rir: $rir)';
  }
}
