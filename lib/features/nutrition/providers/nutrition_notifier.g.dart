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
    extends $StreamNotifierProvider<NutritionNotifier, NutritionState> {
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

String _$nutritionNotifierHash() => r'ecc463d68d5eae2df4c5e73e43e5cf214f6e1c8a';

abstract class _$NutritionNotifier extends $StreamNotifier<NutritionState> {
  Stream<NutritionState> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<NutritionState>, NutritionState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<NutritionState>, NutritionState>,
              AsyncValue<NutritionState>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
