// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'body_weight_powersync.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(WeightEntryNotifier)
const weightEntryProvider = WeightEntryNotifierFamily._();

final class WeightEntryNotifierProvider
    extends $StreamNotifierProvider<WeightEntryNotifier, List<WeightEntry>> {
  const WeightEntryNotifierProvider._({
    required WeightEntryNotifierFamily super.from,
    required BodyWeightRepository? super.argument,
  }) : super(
         retry: null,
         name: r'weightEntryProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$weightEntryNotifierHash();

  @override
  String toString() {
    return r'weightEntryProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  WeightEntryNotifier create() => WeightEntryNotifier();

  @override
  bool operator ==(Object other) {
    return other is WeightEntryNotifierProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$weightEntryNotifierHash() => r'f3cd810779dadab1d8bd4aa4301a4e54ef37388a';

final class WeightEntryNotifierFamily extends $Family
    with
        $ClassFamilyOverride<
          WeightEntryNotifier,
          AsyncValue<List<WeightEntry>>,
          List<WeightEntry>,
          Stream<List<WeightEntry>>,
          BodyWeightRepository?
        > {
  const WeightEntryNotifierFamily._()
    : super(
        retry: null,
        name: r'weightEntryProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  WeightEntryNotifierProvider call([BodyWeightRepository? repository]) =>
      WeightEntryNotifierProvider._(argument: repository, from: this);

  @override
  String toString() => r'weightEntryProvider';
}

abstract class _$WeightEntryNotifier extends $StreamNotifier<List<WeightEntry>> {
  late final _$args = ref.$arg as BodyWeightRepository?;
  BodyWeightRepository? get repository => _$args;

  Stream<List<WeightEntry>> build([BodyWeightRepository? repository]);
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(_$args);
    final ref = this.ref as $Ref<AsyncValue<List<WeightEntry>>, List<WeightEntry>>;
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
