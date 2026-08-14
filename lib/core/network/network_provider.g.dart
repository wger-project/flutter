// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'network_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Whether the device has a network adapter at all (wifi, mobile, ethernet...)
///
/// This is a platform fact and may therefore gate a connection attempt, unlike
/// the reachability probe behind [NetworkStatus], which is only an indication.
/// Starts out true so nothing waits for the first answer of the platform
/// channel; an adapterless device corrects it a moment later.

@ProviderFor(NetworkAdapterAvailable)
final networkAdapterAvailableProvider = NetworkAdapterAvailableProvider._();

/// Whether the device has a network adapter at all (wifi, mobile, ethernet...)
///
/// This is a platform fact and may therefore gate a connection attempt, unlike
/// the reachability probe behind [NetworkStatus], which is only an indication.
/// Starts out true so nothing waits for the first answer of the platform
/// channel; an adapterless device corrects it a moment later.
final class NetworkAdapterAvailableProvider
    extends $NotifierProvider<NetworkAdapterAvailable, bool> {
  /// Whether the device has a network adapter at all (wifi, mobile, ethernet...)
  ///
  /// This is a platform fact and may therefore gate a connection attempt, unlike
  /// the reachability probe behind [NetworkStatus], which is only an indication.
  /// Starts out true so nothing waits for the first answer of the platform
  /// channel; an adapterless device corrects it a moment later.
  NetworkAdapterAvailableProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'networkAdapterAvailableProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$networkAdapterAvailableHash();

  @$internal
  @override
  NetworkAdapterAvailable create() => NetworkAdapterAvailable();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$networkAdapterAvailableHash() => r'ba15e4720bf675523b1c5e697ba66e1a3c4e324e';

/// Whether the device has a network adapter at all (wifi, mobile, ethernet...)
///
/// This is a platform fact and may therefore gate a connection attempt, unlike
/// the reachability probe behind [NetworkStatus], which is only an indication.
/// Starts out true so nothing waits for the first answer of the platform
/// channel; an adapterless device corrects it a moment later.

abstract class _$NetworkAdapterAvailable extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element as $ClassProviderElement<AnyNotifier<bool, bool>, bool, Object?, Object?>;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(NetworkStatus)
final networkStatusProvider = NetworkStatusProvider._();

final class NetworkStatusProvider extends $NotifierProvider<NetworkStatus, bool> {
  NetworkStatusProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'networkStatusProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$networkStatusHash();

  @$internal
  @override
  NetworkStatus create() => NetworkStatus();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$networkStatusHash() => r'dd31308c1969f94d11a108de9e5d2e8c1b96027b';

abstract class _$NetworkStatus extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element as $ClassProviderElement<AnyNotifier<bool, bool>, bool, Object?, Object?>;
    return element.handleCreate(ref, build);
  }
}
