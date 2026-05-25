// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ingredient_filters_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(IngredientFiltersNotifier)
final ingredientFiltersProvider = IngredientFiltersNotifierProvider._();

final class IngredientFiltersNotifierProvider
    extends $AsyncNotifierProvider<IngredientFiltersNotifier, IngredientFilters> {
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

String _$ingredientFiltersNotifierHash() => r'4284bd60c449665303559572457beff3ebdef865';

abstract class _$IngredientFiltersNotifier extends $AsyncNotifier<IngredientFilters> {
  FutureOr<IngredientFilters> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<IngredientFilters>, IngredientFilters>;
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
