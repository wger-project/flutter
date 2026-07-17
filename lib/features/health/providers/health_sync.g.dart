// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'health_sync.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Imports body metrics from Apple Health / Health Connect into measurement
/// categories. Read-only: reads the platform (via [HealthRepository]), writes to
/// the local Drift DB, and lets PowerSync push the rows up. Re-imports are
/// deduplicated via each measurement's [MeasurementEntry.externalId] (the
/// platform record UUID).

@ProviderFor(HealthSyncNotifier)
final healthSyncProvider = HealthSyncNotifierProvider._();

/// Imports body metrics from Apple Health / Health Connect into measurement
/// categories. Read-only: reads the platform (via [HealthRepository]), writes to
/// the local Drift DB, and lets PowerSync push the rows up. Re-imports are
/// deduplicated via each measurement's [MeasurementEntry.externalId] (the
/// platform record UUID).
final class HealthSyncNotifierProvider
    extends $NotifierProvider<HealthSyncNotifier, HealthSyncState> {
  /// Imports body metrics from Apple Health / Health Connect into measurement
  /// categories. Read-only: reads the platform (via [HealthRepository]), writes to
  /// the local Drift DB, and lets PowerSync push the rows up. Re-imports are
  /// deduplicated via each measurement's [MeasurementEntry.externalId] (the
  /// platform record UUID).
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

String _$healthSyncNotifierHash() => r'9c7a678e7740bfa32db7638bd227d64da3bfef09';

/// Imports body metrics from Apple Health / Health Connect into measurement
/// categories. Read-only: reads the platform (via [HealthRepository]), writes to
/// the local Drift DB, and lets PowerSync push the rows up. Re-imports are
/// deduplicated via each measurement's [MeasurementEntry.externalId] (the
/// platform record UUID).

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
