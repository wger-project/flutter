// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'network_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Raw connectivity state, the app's single [Connectivity] consumer; the
/// adapter gate and the reachability probes both derive from it. Starts out
/// with wifi so nothing waits for the first answer of the platform channel;
/// an adapterless device corrects it a moment later.

@ProviderFor(ConnectivityState)
final connectivityStateProvider = ConnectivityStateProvider._();

/// Raw connectivity state, the app's single [Connectivity] consumer; the
/// adapter gate and the reachability probes both derive from it. Starts out
/// with wifi so nothing waits for the first answer of the platform channel;
/// an adapterless device corrects it a moment later.
final class ConnectivityStateProvider
    extends $NotifierProvider<ConnectivityState, List<ConnectivityResult>> {
  /// Raw connectivity state, the app's single [Connectivity] consumer; the
  /// adapter gate and the reachability probes both derive from it. Starts out
  /// with wifi so nothing waits for the first answer of the platform channel;
  /// an adapterless device corrects it a moment later.
  ConnectivityStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'connectivityStateProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$connectivityStateHash();

  @$internal
  @override
  ConnectivityState create() => ConnectivityState();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<ConnectivityResult> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<ConnectivityResult>>(value),
    );
  }
}

String _$connectivityStateHash() => r'c912f76dd5900836dde7f1762b6498b58a07d67e';

/// Raw connectivity state, the app's single [Connectivity] consumer; the
/// adapter gate and the reachability probes both derive from it. Starts out
/// with wifi so nothing waits for the first answer of the platform channel;
/// an adapterless device corrects it a moment later.

abstract class _$ConnectivityState extends $Notifier<List<ConnectivityResult>> {
  List<ConnectivityResult> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<List<ConnectivityResult>, List<ConnectivityResult>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<ConnectivityResult>, List<ConnectivityResult>>,
              List<ConnectivityResult>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Whether the device has a network adapter at all (wifi, mobile, ethernet...)
///
/// This is a platform fact and may therefore gate a connection attempt, unlike
/// the reachability probe behind [NetworkStatus], which is only an indication.

@ProviderFor(networkAdapterAvailable)
final networkAdapterAvailableProvider = NetworkAdapterAvailableProvider._();

/// Whether the device has a network adapter at all (wifi, mobile, ethernet...)
///
/// This is a platform fact and may therefore gate a connection attempt, unlike
/// the reachability probe behind [NetworkStatus], which is only an indication.

final class NetworkAdapterAvailableProvider extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// Whether the device has a network adapter at all (wifi, mobile, ethernet...)
  ///
  /// This is a platform fact and may therefore gate a connection attempt, unlike
  /// the reachability probe behind [NetworkStatus], which is only an indication.
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
  $ProviderElement<bool> $createElement($ProviderPointer pointer) => $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return networkAdapterAvailable(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$networkAdapterAvailableHash() => r'173cf2e2eddced4b02f8138a03b9a24042a71b2d';

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

String _$networkStatusHash() => r'7151484435c9be02745f59fea595fa6d71d16c35';

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
