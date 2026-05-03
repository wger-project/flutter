// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercise_filters_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Holds the *UI-side* state for the exercises catalogue screen:
/// search term, selected categories/equipment, and the resulting
/// [filteredExercises] list.

@ProviderFor(ExerciseListFiltersNotifier)
final exerciseListFiltersProvider = ExerciseListFiltersNotifierProvider._();

/// Holds the *UI-side* state for the exercises catalogue screen:
/// search term, selected categories/equipment, and the resulting
/// [filteredExercises] list.
final class ExerciseListFiltersNotifierProvider
    extends $NotifierProvider<ExerciseListFiltersNotifier, ExerciseFilterState> {
  /// Holds the *UI-side* state for the exercises catalogue screen:
  /// search term, selected categories/equipment, and the resulting
  /// [filteredExercises] list.
  ExerciseListFiltersNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'exerciseListFiltersProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$exerciseListFiltersNotifierHash();

  @$internal
  @override
  ExerciseListFiltersNotifier create() => ExerciseListFiltersNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ExerciseFilterState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ExerciseFilterState>(value),
    );
  }
}

String _$exerciseListFiltersNotifierHash() => r'b6e2571249061a69b53712118615c388f2afefec';

/// Holds the *UI-side* state for the exercises catalogue screen:
/// search term, selected categories/equipment, and the resulting
/// [filteredExercises] list.

abstract class _$ExerciseListFiltersNotifier extends $Notifier<ExerciseFilterState> {
  ExerciseFilterState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<ExerciseFilterState, ExerciseFilterState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ExerciseFilterState, ExerciseFilterState>,
              ExerciseFilterState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
