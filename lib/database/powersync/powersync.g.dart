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

String _$powerSyncInstanceHash() => r'3cc3ce4ee4d65ab26f3709b7526822b0366f0eb6';
