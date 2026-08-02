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
///
/// Unbounded, for the consumers that need the latest entry whatever its age
/// (the dashboard card, the nutrition widgets). A screen that shows a range
/// takes [bodyWeightCategorySince] instead.

@ProviderFor(bodyWeightCategory)
final bodyWeightCategoryProvider = BodyWeightCategoryProvider._();

/// The user's official body weight category, entries sorted newest-first.
///
/// The category is created by the server (registration / data migration) and
/// only arrives via sync; a `null` value means the initial sync has not
/// delivered it yet. Mutations go through [measurementProvider]'s notifier.
///
/// Unbounded, for the consumers that need the latest entry whatever its age
/// (the dashboard card, the nutrition widgets). A screen that shows a range
/// takes [bodyWeightCategorySince] instead.

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
  ///
  /// Unbounded, for the consumers that need the latest entry whatever its age
  /// (the dashboard card, the nutrition widgets). A screen that shows a range
  /// takes [bodyWeightCategorySince] instead.
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

/// The official body weight category with the entries from [since] on, null
/// covering the full history.
///
/// The bound is applied in the query rather than in the chart, so showing three
/// months does not read years of entries into memory.

@ProviderFor(bodyWeightCategorySince)
final bodyWeightCategorySinceProvider = BodyWeightCategorySinceFamily._();

/// The official body weight category with the entries from [since] on, null
/// covering the full history.
///
/// The bound is applied in the query rather than in the chart, so showing three
/// months does not read years of entries into memory.

final class BodyWeightCategorySinceProvider
    extends
        $FunctionalProvider<
          AsyncValue<MeasurementCategory?>,
          AsyncValue<MeasurementCategory?>,
          AsyncValue<MeasurementCategory?>
        >
    with $Provider<AsyncValue<MeasurementCategory?>> {
  /// The official body weight category with the entries from [since] on, null
  /// covering the full history.
  ///
  /// The bound is applied in the query rather than in the chart, so showing three
  /// months does not read years of entries into memory.
  BodyWeightCategorySinceProvider._({
    required BodyWeightCategorySinceFamily super.from,
    required DateTime? super.argument,
  }) : super(
         retry: null,
         name: r'bodyWeightCategorySinceProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$bodyWeightCategorySinceHash();

  @override
  String toString() {
    return r'bodyWeightCategorySinceProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<AsyncValue<MeasurementCategory?>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AsyncValue<MeasurementCategory?> create(Ref ref) {
    final argument = this.argument as DateTime?;
    return bodyWeightCategorySince(ref, argument);
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

  @override
  bool operator ==(Object other) {
    return other is BodyWeightCategorySinceProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$bodyWeightCategorySinceHash() => r'62082b42ba89c02f77257f54d8a7725aea00c836';

/// The official body weight category with the entries from [since] on, null
/// covering the full history.
///
/// The bound is applied in the query rather than in the chart, so showing three
/// months does not read years of entries into memory.

final class BodyWeightCategorySinceFamily extends $Family
    with $FunctionalFamilyOverride<AsyncValue<MeasurementCategory?>, DateTime?> {
  BodyWeightCategorySinceFamily._()
    : super(
        retry: null,
        name: r'bodyWeightCategorySinceProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The official body weight category with the entries from [since] on, null
  /// covering the full history.
  ///
  /// The bound is applied in the query rather than in the chart, so showing three
  /// months does not read years of entries into memory.

  BodyWeightCategorySinceProvider call(DateTime? since) =>
      BodyWeightCategorySinceProvider._(argument: since, from: this);

  @override
  String toString() => r'bodyWeightCategorySinceProvider';
}
