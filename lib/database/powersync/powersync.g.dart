// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'powersync.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(powerSyncInstance)
const powerSyncInstanceProvider = PowerSyncInstanceProvider._();

final class PowerSyncInstanceProvider
    extends
        $FunctionalProvider<
          AsyncValue<PowerSyncDatabase>,
          PowerSyncDatabase,
          FutureOr<PowerSyncDatabase>
        >
    with $FutureModifier<PowerSyncDatabase>, $FutureProvider<PowerSyncDatabase> {
  const PowerSyncInstanceProvider._()
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

String _$powerSyncInstanceHash() => r'2327baf23a05ca82fd26376256fe824ea07e5740';

@ProviderFor(didCompleteSync)
const didCompleteSyncProvider = DidCompleteSyncFamily._();

final class DidCompleteSyncProvider extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  const DidCompleteSyncProvider._({
    required DidCompleteSyncFamily super.from,
    required StreamPriority? super.argument,
  }) : super(
         retry: null,
         name: r'didCompleteSyncProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$didCompleteSyncHash();

  @override
  String toString() {
    return r'didCompleteSyncProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) => $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    final argument = this.argument as StreamPriority?;
    return didCompleteSync(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is DidCompleteSyncProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$didCompleteSyncHash() => r'1b954d75f05194156411ecc9860788ba9b13c2c8';

final class DidCompleteSyncFamily extends $Family
    with $FunctionalFamilyOverride<bool, StreamPriority?> {
  const DidCompleteSyncFamily._()
    : super(
        retry: null,
        name: r'didCompleteSyncProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  DidCompleteSyncProvider call([StreamPriority? priority]) =>
      DidCompleteSyncProvider._(argument: priority, from: this);

  @override
  String toString() => r'didCompleteSyncProvider';
}
