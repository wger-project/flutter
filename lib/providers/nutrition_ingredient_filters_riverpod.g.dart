// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nutrition_ingredient_filters_riverpod.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(IngredientFiltersNotifier)
final ingredientFiltersProvider = IngredientFiltersNotifierProvider._();

final class IngredientFiltersNotifierProvider
    extends
        $AsyncNotifierProvider<IngredientFiltersNotifier, IngredientFilters> {
  IngredientFiltersNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'ingredientFiltersProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$ingredientFiltersNotifierHash();

  @$internal
  @override
  IngredientFiltersNotifier create() => IngredientFiltersNotifier();
}

String _$ingredientFiltersNotifierHash() =>
    r'0d6cc41b8e45673367dc756d55a95b8ac4252d7d';

abstract class _$IngredientFiltersNotifier
    extends $AsyncNotifier<IngredientFilters> {
  FutureOr<IngredientFilters> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<IngredientFilters>, IngredientFilters>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<IngredientFilters>, IngredientFilters>,
              AsyncValue<IngredientFilters>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
