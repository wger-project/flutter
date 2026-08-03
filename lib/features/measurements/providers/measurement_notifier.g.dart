// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'measurement_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// All categories with the entries from [since] on, null covering the full
/// history.
///
/// The bound is applied in the query rather than in the chart, so showing
/// three months does not read years of entries into memory. Kept apart from
/// [measurementProvider], which stays unbounded for the consumers that need
/// the latest entry regardless of its age (the dashboard card).

@ProviderFor(measurementCategoriesSince)
final measurementCategoriesSinceProvider = MeasurementCategoriesSinceFamily._();

/// All categories with the entries from [since] on, null covering the full
/// history.
///
/// The bound is applied in the query rather than in the chart, so showing
/// three months does not read years of entries into memory. Kept apart from
/// [measurementProvider], which stays unbounded for the consumers that need
/// the latest entry regardless of its age (the dashboard card).

final class MeasurementCategoriesSinceProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<MeasurementCategory>>,
          List<MeasurementCategory>,
          Stream<List<MeasurementCategory>>
        >
    with $FutureModifier<List<MeasurementCategory>>, $StreamProvider<List<MeasurementCategory>> {
  /// All categories with the entries from [since] on, null covering the full
  /// history.
  ///
  /// The bound is applied in the query rather than in the chart, so showing
  /// three months does not read years of entries into memory. Kept apart from
  /// [measurementProvider], which stays unbounded for the consumers that need
  /// the latest entry regardless of its age (the dashboard card).
  MeasurementCategoriesSinceProvider._({
    required MeasurementCategoriesSinceFamily super.from,
    required DateTime? super.argument,
  }) : super(
         retry: null,
         name: r'measurementCategoriesSinceProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$measurementCategoriesSinceHash();

  @override
  String toString() {
    return r'measurementCategoriesSinceProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<MeasurementCategory>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<MeasurementCategory>> create(Ref ref) {
    final argument = this.argument as DateTime?;
    return measurementCategoriesSince(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is MeasurementCategoriesSinceProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$measurementCategoriesSinceHash() => r'6c757af207fe294d5e5e3b638476fd17448a0417';

/// All categories with the entries from [since] on, null covering the full
/// history.
///
/// The bound is applied in the query rather than in the chart, so showing
/// three months does not read years of entries into memory. Kept apart from
/// [measurementProvider], which stays unbounded for the consumers that need
/// the latest entry regardless of its age (the dashboard card).

final class MeasurementCategoriesSinceFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<MeasurementCategory>>, DateTime?> {
  MeasurementCategoriesSinceFamily._()
    : super(
        retry: null,
        name: r'measurementCategoriesSinceProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// All categories with the entries from [since] on, null covering the full
  /// history.
  ///
  /// The bound is applied in the query rather than in the chart, so showing
  /// three months does not read years of entries into memory. Kept apart from
  /// [measurementProvider], which stays unbounded for the consumers that need
  /// the latest entry regardless of its age (the dashboard card).

  MeasurementCategoriesSinceProvider call(DateTime? since) =>
      MeasurementCategoriesSinceProvider._(argument: since, from: this);

  @override
  String toString() => r'measurementCategoriesSinceProvider';
}

/// One category with its children and the entries from [since] on, null while
/// it does not exist (or no longer does).

@ProviderFor(measurementCategorySince)
final measurementCategorySinceProvider = MeasurementCategorySinceFamily._();

/// One category with its children and the entries from [since] on, null while
/// it does not exist (or no longer does).

final class MeasurementCategorySinceProvider
    extends
        $FunctionalProvider<
          AsyncValue<MeasurementCategory?>,
          MeasurementCategory?,
          Stream<MeasurementCategory?>
        >
    with $FutureModifier<MeasurementCategory?>, $StreamProvider<MeasurementCategory?> {
  /// One category with its children and the entries from [since] on, null while
  /// it does not exist (or no longer does).
  MeasurementCategorySinceProvider._({
    required MeasurementCategorySinceFamily super.from,
    required (String, DateTime?) super.argument,
  }) : super(
         retry: null,
         name: r'measurementCategorySinceProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$measurementCategorySinceHash();

  @override
  String toString() {
    return r'measurementCategorySinceProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $StreamProviderElement<MeasurementCategory?> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<MeasurementCategory?> create(Ref ref) {
    final argument = this.argument as (String, DateTime?);
    return measurementCategorySince(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is MeasurementCategorySinceProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$measurementCategorySinceHash() => r'fa296a2babc8a16a9fd9177ca93682287efbd49e';

/// One category with its children and the entries from [since] on, null while
/// it does not exist (or no longer does).

final class MeasurementCategorySinceFamily extends $Family
    with $FunctionalFamilyOverride<Stream<MeasurementCategory?>, (String, DateTime?)> {
  MeasurementCategorySinceFamily._()
    : super(
        retry: null,
        name: r'measurementCategorySinceProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// One category with its children and the entries from [since] on, null while
  /// it does not exist (or no longer does).

  MeasurementCategorySinceProvider call(String id, DateTime? since) =>
      MeasurementCategorySinceProvider._(argument: (id, since), from: this);

  @override
  String toString() => r'measurementCategorySinceProvider';
}

@ProviderFor(MeasurementNotifier)
final measurementProvider = MeasurementNotifierProvider._();

final class MeasurementNotifierProvider
    extends $StreamNotifierProvider<MeasurementNotifier, List<MeasurementCategory>> {
  MeasurementNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'measurementProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$measurementNotifierHash();

  @$internal
  @override
  MeasurementNotifier create() => MeasurementNotifier();
}

String _$measurementNotifierHash() => r'c34dc2058c56e502cba8f1d84d867347dcc02f79';

abstract class _$MeasurementNotifier extends $StreamNotifier<List<MeasurementCategory>> {
  Stream<List<MeasurementCategory>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<MeasurementCategory>>, List<MeasurementCategory>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<MeasurementCategory>>, List<MeasurementCategory>>,
              AsyncValue<List<MeasurementCategory>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
