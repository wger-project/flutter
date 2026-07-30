// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'body_weight_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The user's official body weight category, entries sorted newest-first.
///
/// The category is created by the server (registration / data migration) and
/// only arrives via sync; a `null` value means the initial sync has not
/// delivered it yet. Mutations go through [measurementProvider]'s notifier.

@ProviderFor(bodyWeightCategory)
final bodyWeightCategoryProvider = BodyWeightCategoryProvider._();

/// The user's official body weight category, entries sorted newest-first.
///
/// The category is created by the server (registration / data migration) and
/// only arrives via sync; a `null` value means the initial sync has not
/// delivered it yet. Mutations go through [measurementProvider]'s notifier.

final class BodyWeightCategoryProvider
    extends
        $FunctionalProvider<
          AsyncValue<MeasurementCategory?>,
          AsyncValue<MeasurementCategory?>,
          AsyncValue<MeasurementCategory?>
        >
    with $Provider<AsyncValue<MeasurementCategory?>> {
  /// The user's official body weight category, entries sorted newest-first.
  ///
  /// The category is created by the server (registration / data migration) and
  /// only arrives via sync; a `null` value means the initial sync has not
  /// delivered it yet. Mutations go through [measurementProvider]'s notifier.
  BodyWeightCategoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'bodyWeightCategoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$bodyWeightCategoryHash();

  @$internal
  @override
  $ProviderElement<AsyncValue<MeasurementCategory?>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AsyncValue<MeasurementCategory?> create(Ref ref) {
    return bodyWeightCategory(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<MeasurementCategory?> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<MeasurementCategory?>>(
        value,
      ),
    );
  }
}

String _$bodyWeightCategoryHash() => r'c3dcd508fad547e2ea0b69a0ad403afafc2f81fc';
