// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nutrition_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(NutritionNotifier)
final nutritionProvider = NutritionNotifierProvider._();

final class NutritionNotifierProvider
    extends $AsyncNotifierProvider<NutritionNotifier, List<NutritionalPlan>> {
  NutritionNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'nutritionProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$nutritionNotifierHash();

  @$internal
  @override
  NutritionNotifier create() => NutritionNotifier();
}

String _$nutritionNotifierHash() => r'958bf02bc0aa8dc739be26a04b4efbb1004bfd72';

abstract class _$NutritionNotifier extends $AsyncNotifier<List<NutritionalPlan>> {
  FutureOr<List<NutritionalPlan>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<NutritionalPlan>>, List<NutritionalPlan>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<NutritionalPlan>>, List<NutritionalPlan>>,
              AsyncValue<List<NutritionalPlan>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
