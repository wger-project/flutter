// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercise_filters_riverpod.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ExerciseFiltersNotifier)
final exerciseFiltersProvider = ExerciseFiltersNotifierProvider._();

final class ExerciseFiltersNotifierProvider
    extends $AsyncNotifierProvider<ExerciseFiltersNotifier, ExerciseFilters> {
  ExerciseFiltersNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'exerciseFiltersProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$exerciseFiltersNotifierHash();

  @$internal
  @override
  ExerciseFiltersNotifier create() => ExerciseFiltersNotifier();
}

String _$exerciseFiltersNotifierHash() => r'1cedea351eff449d71596de9d95218ca4587e3d4';

abstract class _$ExerciseFiltersNotifier extends $AsyncNotifier<ExerciseFilters> {
  FutureOr<ExerciseFilters> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<ExerciseFilters>, ExerciseFilters>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<ExerciseFilters>, ExerciseFilters>,
              AsyncValue<ExerciseFilters>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
