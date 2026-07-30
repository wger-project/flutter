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

String _$exerciseFiltersNotifierHash() => r'cf29351e05aabc8ef131eff2a4fdb076827714fe';

abstract class _$ExerciseFiltersNotifier extends $AsyncNotifier<ExerciseFilters> {
  FutureOr<ExerciseFilters> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<ExerciseFilters>, ExerciseFilters>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<ExerciseFilters>, ExerciseFilters>,
              AsyncValue<ExerciseFilters>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
