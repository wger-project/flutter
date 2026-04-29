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

@ProviderFor(ExerciseFiltersNotifier)
final exerciseFiltersProvider = ExerciseFiltersNotifierProvider._();

/// Holds the *UI-side* state for the exercises catalogue screen:
/// search term, selected categories/equipment, and the resulting
/// [filteredExercises] list.
final class ExerciseFiltersNotifierProvider
    extends $NotifierProvider<ExerciseFiltersNotifier, ExerciseFilterState> {
  /// Holds the *UI-side* state for the exercises catalogue screen:
  /// search term, selected categories/equipment, and the resulting
  /// [filteredExercises] list.
  ExerciseFiltersNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'exerciseFiltersProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$exerciseFiltersNotifierHash();

  @$internal
  @override
  ExerciseFiltersNotifier create() => ExerciseFiltersNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ExerciseFilterState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ExerciseFilterState>(value),
    );
  }
}

String _$exerciseFiltersNotifierHash() => r'5fed07a5c73dee7669b32a41f16a8c6439ebad63';

/// Holds the *UI-side* state for the exercises catalogue screen:
/// search term, selected categories/equipment, and the resulting
/// [filteredExercises] list.

abstract class _$ExerciseFiltersNotifier extends $Notifier<ExerciseFilterState> {
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
