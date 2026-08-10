// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'powersync.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(powerSyncInstance)
final powerSyncInstanceProvider = PowerSyncInstanceProvider._();

final class PowerSyncInstanceProvider
    extends
        $FunctionalProvider<
          AsyncValue<PowerSyncDatabase>,
          PowerSyncDatabase,
          FutureOr<PowerSyncDatabase>
        >
    with $FutureModifier<PowerSyncDatabase>, $FutureProvider<PowerSyncDatabase> {
  PowerSyncInstanceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'powerSyncInstanceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$powerSyncInstanceHash();

  @$internal
  @override
  $FutureProviderElement<PowerSyncDatabase> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<PowerSyncDatabase> create(Ref ref) {
    return powerSyncInstance(ref);
  }
}

String _$powerSyncInstanceHash() => r'83bc0e7e421a0aa82c0ceb2d097367484c9dc87a';
