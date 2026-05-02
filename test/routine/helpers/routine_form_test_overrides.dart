/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (c) 2026 - 2026 wger Team
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

import 'package:flutter_riverpod/misc.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:wger/models/exercises/exercise.dart';
import 'package:wger/models/workouts/repetition_unit.dart';
import 'package:wger/models/workouts/session.dart';
import 'package:wger/models/workouts/weight_unit.dart';
import 'package:wger/providers/exercise_repository.dart';
import 'package:wger/providers/exercises_notifier.dart';
import 'package:wger/providers/routines_notifier.dart';
import 'package:wger/providers/workout_session_repository.dart';

import 'routine_form_test_overrides.mocks.dart';

export 'routine_form_test_overrides.mocks.dart'
    show MockExerciseRepository, MockWorkoutSessionRepository;

@GenerateMocks([ExerciseRepository, WorkoutSessionRepository])
/// Repository overrides for the two reference-data notifiers that
/// `RoutinesRiverpod.fetchAndSetRoutineFull` `awaitFirstValue`s on:
/// `exercisesProvider` and `workoutSessionProvider`. Both notifiers read
/// their underlying Drift table on build, which hangs in widget tests
/// without this stub.
///
/// When [exercise] / [session] are passed in by the caller they are used
/// as-is — the caller owns the stubbing. Only the locally-created fallback
/// mocks get a default empty-stream stub here.
List<Override> exerciseAndSessionRepoOverrides({
  MockExerciseRepository? exercise,
  MockWorkoutSessionRepository? session,
}) {
  final exerciseRepo = exercise ?? _emptyExerciseRepoMock();
  final sessionRepo = session ?? _emptySessionRepoMock();
  return [
    exerciseRepositoryProvider.overrideWithValue(exerciseRepo),
    workoutSessionRepositoryProvider.overrideWithValue(sessionRepo),
  ];
}

MockExerciseRepository _emptyExerciseRepoMock() {
  final mock = MockExerciseRepository();
  when(
    mock.watchAllDrift(),
  ).thenAnswer((_) => Stream.value(const ExerciseState(<Exercise>[])));
  return mock;
}

MockWorkoutSessionRepository _emptySessionRepoMock() {
  final mock = MockWorkoutSessionRepository();
  when(mock.watchAllDrift()).thenAnswer((_) => Stream.value(const <WorkoutSession>[]));
  return mock;
}

/// All four provider overrides needed for `RoutinesRiverpod.fetchAndSetRoutineFull`.
/// Use this in widget tests that don't override the reference-data streams
/// themselves; otherwise mix in [exerciseAndSessionRepoOverrides] alone.
///
/// [repetitionUnits] / [weightUnits] default to empty lists — sufficient for
/// most form widget tests where the units only need to satisfy the
/// `awaitFirstValue` step. Pass real fixtures when the test exercises
/// hydration logic that looks units up by id.
List<Override> routineFormAmbientOverrides({
  MockExerciseRepository? exercise,
  MockWorkoutSessionRepository? session,
  List<RepetitionUnit> repetitionUnits = const [],
  List<WeightUnit> weightUnits = const [],
}) => [
  ...exerciseAndSessionRepoOverrides(exercise: exercise, session: session),
  routineRepetitionUnitProvider.overrideWith(
    (ref) => Stream<List<RepetitionUnit>>.value(repetitionUnits),
  ),
  routineWeightUnitProvider.overrideWith(
    (ref) => Stream<List<WeightUnit>>.value(weightUnits),
  ),
];
