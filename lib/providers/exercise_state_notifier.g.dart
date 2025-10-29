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

part of 'exercise_state_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(exerciseStateReady)
const exerciseStateReadyProvider = ExerciseStateReadyProvider._();

final class ExerciseStateReadyProvider
    extends $FunctionalProvider<AsyncValue<void>, void, FutureOr<void>>
    with $FutureModifier<void>, $FutureProvider<void> {
  const ExerciseStateReadyProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'exerciseStateReadyProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$exerciseStateReadyHash();

  @$internal
  @override
  $FutureProviderElement<void> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<void> create(Ref ref) {
    return exerciseStateReady(ref);
  }
}

String _$exerciseStateReadyHash() => r'a5b80b37b69bb14902a6d347124721b835bd7ab5';

@ProviderFor(ExerciseStateNotifier)
const exerciseStateProvider = ExerciseStateNotifierProvider._();

final class ExerciseStateNotifierProvider
    extends $NotifierProvider<ExerciseStateNotifier, ExerciseState> {
  const ExerciseStateNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'exerciseStateProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$exerciseStateNotifierHash();

  @$internal
  @override
  ExerciseStateNotifier create() => ExerciseStateNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ExerciseState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ExerciseState>(value),
    );
  }
}

String _$exerciseStateNotifierHash() => r'2afd58c1f64a23010125795263121a745d2b17c0';

abstract class _$ExerciseStateNotifier extends $Notifier<ExerciseState> {
  ExerciseState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<ExerciseState, ExerciseState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ExerciseState, ExerciseState>,
              ExerciseState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
