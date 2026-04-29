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

String _$nutritionNotifierHash() => r'cddf4167586ddc55c031d097be7af02e7e1dec33';

abstract class _$NutritionNotifier extends $StreamNotifier<NutritionState> {
  Stream<NutritionState> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<NutritionState>, NutritionState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<NutritionState>, NutritionState>,
              AsyncValue<NutritionState>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
