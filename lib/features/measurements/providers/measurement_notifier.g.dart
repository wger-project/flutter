// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'measurement_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(MeasurementNotifier)
final measurementProvider = MeasurementNotifierProvider._();

final class MeasurementNotifierProvider
    extends $StreamNotifierProvider<MeasurementNotifier, List<MeasurementCategory>> {
  MeasurementNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'measurementProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$measurementNotifierHash();

  @$internal
  @override
  MeasurementNotifier create() => MeasurementNotifier();
}

String _$measurementNotifierHash() => r'd21ed9e3cba86b2395e6df78d51fceb523e7c4fb';

abstract class _$MeasurementNotifier extends $StreamNotifier<List<MeasurementCategory>> {
  Stream<List<MeasurementCategory>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<MeasurementCategory>>, List<MeasurementCategory>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<MeasurementCategory>>, List<MeasurementCategory>>,
              AsyncValue<List<MeasurementCategory>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
