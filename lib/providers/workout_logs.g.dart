/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (c) 2020,  wger Team
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

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_logs.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(WorkoutLogNotifier)
const workoutLogProvider = WorkoutLogNotifierProvider._();

final class WorkoutLogNotifierProvider
    extends $StreamNotifierProvider<WorkoutLogNotifier, List<Log>> {
  const WorkoutLogNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'workoutLogProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$workoutLogNotifierHash();

  @$internal
  @override
  WorkoutLogNotifier create() => WorkoutLogNotifier();
}

String _$workoutLogNotifierHash() => r'8ec76c8d9c72c6bc482952763d048c5df110bd6e';

abstract class _$WorkoutLogNotifier extends $StreamNotifier<List<Log>> {
  Stream<List<Log>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<List<Log>>, List<Log>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Log>>, List<Log>>,
              AsyncValue<List<Log>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
