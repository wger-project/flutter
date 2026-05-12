// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ingredient_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(IngredientNotifier)
final ingredientProvider = IngredientNotifierProvider._();

final class IngredientNotifierProvider
    extends $StreamNotifierProvider<IngredientNotifier, List<Ingredient>> {
  IngredientNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'ingredientProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$ingredientNotifierHash();

  @$internal
  @override
  IngredientNotifier create() => IngredientNotifier();
}

String _$ingredientNotifierHash() => r'd94756d249a15e604640f2e9a5c1802a7d4f9711';

abstract class _$IngredientNotifier extends $StreamNotifier<List<Ingredient>> {
  Stream<List<Ingredient>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<Ingredient>>, List<Ingredient>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Ingredient>>, List<Ingredient>>,
              AsyncValue<List<Ingredient>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
