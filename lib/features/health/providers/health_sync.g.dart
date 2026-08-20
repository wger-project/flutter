// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'health_sync.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Drives the health import: the user's preference, when a run happens, and
/// what the settings screen shows about it.
///
/// The import itself is [HealthImporter], which this only starts and reports
/// on. Everything about how readings become measurements lives there.

@ProviderFor(HealthSyncNotifier)
final healthSyncProvider = HealthSyncNotifierProvider._();

/// Drives the health import: the user's preference, when a run happens, and
/// what the settings screen shows about it.
///
/// The import itself is [HealthImporter], which this only starts and reports
/// on. Everything about how readings become measurements lives there.
final class HealthSyncNotifierProvider
    extends $NotifierProvider<HealthSyncNotifier, HealthSyncState> {
  /// Drives the health import: the user's preference, when a run happens, and
  /// what the settings screen shows about it.
  ///
  /// The import itself is [HealthImporter], which this only starts and reports
  /// on. Everything about how readings become measurements lives there.
  HealthSyncNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'healthSyncProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$healthSyncNotifierHash();

  @$internal
  @override
  HealthSyncNotifier create() => HealthSyncNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(HealthSyncState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<HealthSyncState>(value),
    );
  }
}

String _$healthSyncNotifierHash() => r'128cb8ce19d0ef3ad4388de415f7768e87c617b6';

/// Drives the health import: the user's preference, when a run happens, and
/// what the settings screen shows about it.
///
/// The import itself is [HealthImporter], which this only starts and reports
/// on. Everything about how readings become measurements lives there.

abstract class _$HealthSyncNotifier extends $Notifier<HealthSyncState> {
  HealthSyncState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<HealthSyncState, HealthSyncState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<HealthSyncState, HealthSyncState>,
              HealthSyncState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
