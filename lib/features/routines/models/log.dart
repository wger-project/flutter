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

import 'package:drift/drift.dart' as drift;
import 'package:material_ui/material_ui.dart';
import 'package:wger/core/consts.dart';
import 'package:wger/core/i18n.dart';
import 'package:wger/core/misc.dart';
import 'package:wger/database/powersync/database.dart';
import 'package:wger/features/exercises/models/exercise.dart';
import 'package:wger/features/routines/models/repetition_unit.dart';
import 'package:wger/features/routines/models/set_config_data.dart';
import 'package:wger/features/routines/models/weight_unit.dart';

class Log {
  /// Max value the backend stores for weight / repetitions
  /// (in the backend: DecimalField max_digits=6, decimal_places=2)
  static const MAX_VALUE = 9999.99;

  /// Client-generated UUID, is `null` only before the first persist
  String? id;

  late int exerciseId;

  Exercise? _exerciseObj;

  /// The exercise this log belongs to, throws if it was never hydrated
  ///
  /// Logs read from the database only carry [exerciseId], joining the whole
  /// exercise with its translations, images and muscles would be wasteful for
  /// a value most callers don't need. Use [exerciseObjOrNull] for those.
  Exercise get exerciseObj {
    if (_exerciseObj == null) {
      throw StateError('Log $id has no hydrated exercise (exercise ID $exerciseId)');
    }
    return _exerciseObj!;
  }

  set exerciseObj(Exercise value) => _exerciseObj = value;

  /// Like [exerciseObj] but returns null instead of throwing
  Exercise? get exerciseObjOrNull => _exerciseObj;

  int? routineId;
  String? sessionId;
  int? iteration;
  int? slotEntryId;
  num? rir;
  num? rirTarget;

  num? repetitions;
  num? repetitionsTarget;
  int? repetitionsUnitId;
  RepetitionUnit? repetitionsUnitObj;

  num? weight;
  num? weightTarget;
  int? weightUnitId;
  WeightUnit? weightUnitObj;

  late DateTime date;

  Log({
    this.id,
    required this.exerciseId,
    this.iteration,
    this.slotEntryId,
    this.routineId,
    this.sessionId,
    this.repetitions,
    this.repetitionsTarget,
    this.repetitionsUnitId = REP_UNIT_REPETITIONS_ID,
    this.repetitionsUnitObj,
    this.rir,
    this.rirTarget,
    this.weight,
    this.weightTarget,
    this.weightUnitId = WEIGHT_UNIT_KG,
    this.weightUnitObj,
    DateTime? date,
  }) : date = date ?? DateTime.now();

  Log.fromSetConfigData(SetConfigData setConfig, {this.routineId, this.iteration}) {
    date = DateTime.now();
    sessionId = null;

    slotEntryId = setConfig.slotEntryId;
    exercise = setConfig.exercise;

    weight = setConfig.weight;
    weightTarget = setConfig.weight;
    // Fall back to the resolved unit object (set during routine hydration from
    // the user's metric preference) when the config carries no explicit unit.
    weightUnitId = setConfig.weightUnitId ?? setConfig.weightUnit?.id ?? WEIGHT_UNIT_KG;
    weightUnitObj = setConfig.weightUnit;

    repetitions = setConfig.repetitions;
    repetitionsTarget = setConfig.repetitions;
    repetitionsUnitId = setConfig.repetitionsUnitId ?? REP_UNIT_REPETITIONS_ID;
    repetitionsUnitObj = setConfig.repetitionsUnit;

    rir = setConfig.rir;
    rirTarget = setConfig.rir;
  }

  Log copyWith({
    String? id,
    int? exerciseId,
    int? routineId,
    String? sessionId,
    int? iteration,
    int? slotEntryId,
    num? rir,
    num? rirTarget,
    num? repetitions,
    num? repetitionsTarget,
    int? repetitionsUnitId,
    RepetitionUnit? repetitionsUnitObj,
    num? weight,
    num? weightTarget,
    int? weightUnitId,
    WeightUnit? weightUnitObj,
    DateTime? date,
  }) {
    final out = Log(
      id: id ?? this.id,
      exerciseId: exerciseId ?? this.exerciseId,
      iteration: iteration ?? this.iteration,
      slotEntryId: slotEntryId ?? this.slotEntryId,
      routineId: routineId ?? this.routineId,
      sessionId: sessionId ?? this.sessionId,
      repetitions: repetitions ?? this.repetitions,
      repetitionsTarget: repetitionsTarget ?? this.repetitionsTarget,
      repetitionsUnitId: repetitionsUnitId ?? this.repetitionsUnitId,
      repetitionsUnitObj: repetitionsUnitObj ?? this.repetitionsUnitObj,
      rir: rir ?? this.rir,
      rirTarget: rirTarget ?? this.rirTarget,
      weight: weight ?? this.weight,
      weightTarget: weightTarget ?? this.weightTarget,
      weightUnitId: weightUnitId ?? this.weightUnitId,
      weightUnitObj: weightUnitObj ?? this.weightUnitObj,
      date: date ?? this.date,
    );

    if (repetitionsUnitObj != null) {
      out.repetitionsUnitObj = repetitionsUnitObj;
      out.repetitionsUnitId = repetitionsUnitObj.id;
    }

    if (weightUnitObj != null) {
      out.weightUnitObj = weightUnitObj;
      out.weightUnitId = weightUnitObj.id;
    }

    // Logs read from the database have no exercise, so only copy an existing one
    if (_exerciseObj != null) {
      out.exerciseObj = _exerciseObj!;
    }

    return out;
  }

  WorkoutLogTableCompanion toCompanion() {
    return WorkoutLogTableCompanion(
      id: id != null ? drift.Value(id!) : const drift.Value.absent(),
      exerciseId: drift.Value(exerciseId),
      routineId: drift.Value(routineId),
      // Explicit NULL, not absent: clearing a value (e.g. the RiR or the
      // weight in the log edit dialog) has to clear the column too
      sessionId: drift.Value(sessionId),
      iteration: drift.Value(iteration),
      slotEntryId: drift.Value(slotEntryId),
      rir: drift.Value(rir?.toDouble()),
      rirTarget: drift.Value(rirTarget?.toDouble()),
      repetitions: drift.Value(repetitions?.toDouble()),
      repetitionsTarget: drift.Value(repetitionsTarget?.toDouble()),
      repetitionsUnitId: drift.Value(repetitionsUnitId),
      weight: drift.Value(weight?.toDouble()),
      weightTarget: drift.Value(weightTarget?.toDouble()),
      weightUnitId: drift.Value(weightUnitId),
      date: drift.Value(date),
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
