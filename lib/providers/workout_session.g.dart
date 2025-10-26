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

part of 'workout_session.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(WorkoutSessionNotifier)
const workoutSessionProvider = WorkoutSessionNotifierProvider._();

final class WorkoutSessionNotifierProvider
    extends $StreamNotifierProvider<WorkoutSessionNotifier, List<WorkoutSession>> {
  const WorkoutSessionNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'workoutSessionProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$workoutSessionNotifierHash();

  @$internal
  @override
  WorkoutSessionNotifier create() => WorkoutSessionNotifier();
}

String _$workoutSessionNotifierHash() => r'2d2a67179eb60855d6985af73429e39db4f80886';

abstract class _$WorkoutSessionNotifier extends $StreamNotifier<List<WorkoutSession>> {
  Stream<List<WorkoutSession>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<List<WorkoutSession>>, List<WorkoutSession>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<WorkoutSession>>, List<WorkoutSession>>,
              AsyncValue<List<WorkoutSession>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
