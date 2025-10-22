// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'body_weight_powersync.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(WeightEntryNotifier)
const weightEntryProvider = WeightEntryNotifierProvider._();

final class WeightEntryNotifierProvider
    extends $StreamNotifierProvider<WeightEntryNotifier, List<WeightEntry>> {
  const WeightEntryNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'weightEntryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$weightEntryNotifierHash();

  @$internal
  @override
  WeightEntryNotifier create() => WeightEntryNotifier();
}

String _$weightEntryNotifierHash() =>
    r'e1ebd97614bf12e7fd64c4613a13b082cb01eb33';

abstract class _$WeightEntryNotifier
    extends $StreamNotifier<List<WeightEntry>> {
  Stream<List<WeightEntry>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref as $Ref<AsyncValue<List<WeightEntry>>, List<WeightEntry>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<WeightEntry>>, List<WeightEntry>>,
              AsyncValue<List<WeightEntry>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
