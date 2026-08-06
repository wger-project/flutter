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
/// delivered it yet. Mutations go through `measurementProvider`'s notifier.
///
/// Unbounded, for the consumers that walk the entries themselves (the
/// dashboard card, the nutrition widgets). The body weight screen takes
/// [bodyWeightCategoryOnly], which reads none.

@ProviderFor(bodyWeightCategory)
final bodyWeightCategoryProvider = BodyWeightCategoryProvider._();

/// The user's official body weight category, entries sorted newest-first.
///
/// The category is created by the server (registration / data migration) and
/// only arrives via sync; a `null` value means the initial sync has not
/// delivered it yet. Mutations go through `measurementProvider`'s notifier.
///
/// Unbounded, for the consumers that walk the entries themselves (the
/// dashboard card, the nutrition widgets). The body weight screen takes
/// [bodyWeightCategoryOnly], which reads none.

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
  /// delivered it yet. Mutations go through `measurementProvider`'s notifier.
  ///
  /// Unbounded, for the consumers that walk the entries themselves (the
  /// dashboard card, the nutrition widgets). The body weight screen takes
  /// [bodyWeightCategoryOnly], which reads none.
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

String _$bodyWeightCategoryHash() => r'8f2f7da1d4d675e2357428666f2cd9c51d53fcc4';

/// The official body weight category without its entries, for the screen,
/// which reads its chart and its list through their own queries.

@ProviderFor(bodyWeightCategoryOnly)
final bodyWeightCategoryOnlyProvider = BodyWeightCategoryOnlyProvider._();

/// The official body weight category without its entries, for the screen,
/// which reads its chart and its list through their own queries.

final class BodyWeightCategoryOnlyProvider
    extends
        $FunctionalProvider<
          AsyncValue<MeasurementCategory?>,
          MeasurementCategory?,
          Stream<MeasurementCategory?>
        >
    with $FutureModifier<MeasurementCategory?>, $StreamProvider<MeasurementCategory?> {
  /// The official body weight category without its entries, for the screen,
  /// which reads its chart and its list through their own queries.
  BodyWeightCategoryOnlyProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'bodyWeightCategoryOnlyProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$bodyWeightCategoryOnlyHash();

  @$internal
  @override
  $StreamProviderElement<MeasurementCategory?> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<MeasurementCategory?> create(Ref ref) {
    return bodyWeightCategoryOnly(ref);
  }
}

String _$bodyWeightCategoryOnlyHash() => r'1c37663ac8e3c3df145cbc012f374720a2a7386c';

/// The official body weight category with the entries from [since] on, null
/// covering the full history.
///
/// The bound is applied in the query rather than in the chart, so showing three
/// months does not read years of entries into memory. So is the category
/// itself: reading every category and keeping one made a body fat or sleep
/// entry re-materialise the whole measurement history.

@ProviderFor(bodyWeightCategorySince)
final bodyWeightCategorySinceProvider = BodyWeightCategorySinceFamily._();

/// The official body weight category with the entries from [since] on, null
/// covering the full history.
///
/// The bound is applied in the query rather than in the chart, so showing three
/// months does not read years of entries into memory. So is the category
/// itself: reading every category and keeping one made a body fat or sleep
/// entry re-materialise the whole measurement history.

final class BodyWeightCategorySinceProvider
    extends
        $FunctionalProvider<
          AsyncValue<MeasurementCategory?>,
          MeasurementCategory?,
          Stream<MeasurementCategory?>
        >
    with $FutureModifier<MeasurementCategory?>, $StreamProvider<MeasurementCategory?> {
  /// The official body weight category with the entries from [since] on, null
  /// covering the full history.
  ///
  /// The bound is applied in the query rather than in the chart, so showing three
  /// months does not read years of entries into memory. So is the category
  /// itself: reading every category and keeping one made a body fat or sleep
  /// entry re-materialise the whole measurement history.
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
  $StreamProviderElement<MeasurementCategory?> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<MeasurementCategory?> create(Ref ref) {
    final argument = this.argument as DateTime?;
    return bodyWeightCategorySince(ref, argument);
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

String _$bodyWeightCategorySinceHash() => r'86893a68fab1ed9b4c8ac4a2ff7d31c64c8fa723';

/// The official body weight category with the entries from [since] on, null
/// covering the full history.
///
/// The bound is applied in the query rather than in the chart, so showing three
/// months does not read years of entries into memory. So is the category
/// itself: reading every category and keeping one made a body fat or sleep
/// entry re-materialise the whole measurement history.

final class BodyWeightCategorySinceFamily extends $Family
    with $FunctionalFamilyOverride<Stream<MeasurementCategory?>, DateTime?> {
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
  /// months does not read years of entries into memory. So is the category
  /// itself: reading every category and keeping one made a body fat or sleep
  /// entry re-materialise the whole measurement history.

  BodyWeightCategorySinceProvider call(DateTime? since) =>
      BodyWeightCategorySinceProvider._(argument: since, from: this);

  @override
  String toString() => r'bodyWeightCategorySinceProvider';
}
