// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ingredient_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(IngredientNotifier)
final ingredientProvider = IngredientNotifierProvider._();

final class IngredientNotifierProvider extends $AsyncNotifierProvider<IngredientNotifier, void> {
  IngredientNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'ingredientProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$ingredientNotifierHash();

  @$internal
  @override
  IngredientNotifier create() => IngredientNotifier();
}

String _$ingredientNotifierHash() => r'40e9fa3376a25289b04a86f9303e20de77cab1d8';

abstract class _$IngredientNotifier extends $AsyncNotifier<void> {
  FutureOr<void> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, void>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
