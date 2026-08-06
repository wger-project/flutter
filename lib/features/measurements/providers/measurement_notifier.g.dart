// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'measurement_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// All categories with their children, without their entries.
///
/// What the screens watch: everything they draw comes from the aggregated
/// queries and the paged lists below. Kept apart from [measurementProvider],
/// which stays unbounded for the consumers that read the entries themselves
/// (the health importer, the dashboard calendar).

@ProviderFor(measurementCategories)
final measurementCategoriesProvider = MeasurementCategoriesProvider._();

/// All categories with their children, without their entries.
///
/// What the screens watch: everything they draw comes from the aggregated
/// queries and the paged lists below. Kept apart from [measurementProvider],
/// which stays unbounded for the consumers that read the entries themselves
/// (the health importer, the dashboard calendar).

final class MeasurementCategoriesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<MeasurementCategory>>,
          List<MeasurementCategory>,
          Stream<List<MeasurementCategory>>
        >
    with $FutureModifier<List<MeasurementCategory>>, $StreamProvider<List<MeasurementCategory>> {
  /// All categories with their children, without their entries.
  ///
  /// What the screens watch: everything they draw comes from the aggregated
  /// queries and the paged lists below. Kept apart from [measurementProvider],
  /// which stays unbounded for the consumers that read the entries themselves
  /// (the health importer, the dashboard calendar).
  MeasurementCategoriesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'measurementCategoriesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$measurementCategoriesHash();

  @$internal
  @override
  $StreamProviderElement<List<MeasurementCategory>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<MeasurementCategory>> create(Ref ref) {
    return measurementCategories(ref);
  }
}

String _$measurementCategoriesHash() => r'0fbe4c5b49eed79ffe307763e0fec417a5899356';

/// One page of a category's entries, newest first.

@ProviderFor(measurementEntriesPage)
final measurementEntriesPageProvider = MeasurementEntriesPageFamily._();

/// One page of a category's entries, newest first.

final class MeasurementEntriesPageProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<MeasurementEntry>>,
          List<MeasurementEntry>,
          Stream<List<MeasurementEntry>>
        >
    with $FutureModifier<List<MeasurementEntry>>, $StreamProvider<List<MeasurementEntry>> {
  /// One page of a category's entries, newest first.
  MeasurementEntriesPageProvider._({
    required MeasurementEntriesPageFamily super.from,
    required (String, int) super.argument,
  }) : super(
         retry: null,
         name: r'measurementEntriesPageProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$measurementEntriesPageHash();

  @override
  String toString() {
    return r'measurementEntriesPageProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $StreamProviderElement<List<MeasurementEntry>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<MeasurementEntry>> create(Ref ref) {
    final argument = this.argument as (String, int);
    return measurementEntriesPage(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is MeasurementEntriesPageProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$measurementEntriesPageHash() => r'6c0e572a7fee33e5905441299d9ed23fcb5b83e2';

/// One page of a category's entries, newest first.

final class MeasurementEntriesPageFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<MeasurementEntry>>, (String, int)> {
  MeasurementEntriesPageFamily._()
    : super(
        retry: null,
        name: r'measurementEntriesPageProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// One page of a category's entries, newest first.

  MeasurementEntriesPageProvider call(String categoryId, int limit) =>
      MeasurementEntriesPageProvider._(
        argument: (categoryId, limit),
        from: this,
      );

  @override
  String toString() => r'measurementEntriesPageProvider';
}

/// One page of the entries of a group's components, newest first, out of which
/// the readings are paired.

@ProviderFor(measurementGroupEntriesPage)
final measurementGroupEntriesPageProvider = MeasurementGroupEntriesPageFamily._();

/// One page of the entries of a group's components, newest first, out of which
/// the readings are paired.

final class MeasurementGroupEntriesPageProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<MeasurementEntry>>,
          List<MeasurementEntry>,
          Stream<List<MeasurementEntry>>
        >
    with $FutureModifier<List<MeasurementEntry>>, $StreamProvider<List<MeasurementEntry>> {
  /// One page of the entries of a group's components, newest first, out of which
  /// the readings are paired.
  MeasurementGroupEntriesPageProvider._({
    required MeasurementGroupEntriesPageFamily super.from,
    required (String, int) super.argument,
  }) : super(
         retry: null,
         name: r'measurementGroupEntriesPageProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$measurementGroupEntriesPageHash();

  @override
  String toString() {
    return r'measurementGroupEntriesPageProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $StreamProviderElement<List<MeasurementEntry>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<MeasurementEntry>> create(Ref ref) {
    final argument = this.argument as (String, int);
    return measurementGroupEntriesPage(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is MeasurementGroupEntriesPageProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$measurementGroupEntriesPageHash() => r'd88344f85d8353a89bc662788974a6e43c92c1ac';

/// One page of the entries of a group's components, newest first, out of which
/// the readings are paired.

final class MeasurementGroupEntriesPageFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<MeasurementEntry>>, (String, int)> {
  MeasurementGroupEntriesPageFamily._()
    : super(
        retry: null,
        name: r'measurementGroupEntriesPageProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// One page of the entries of a group's components, newest first, out of which
  /// the readings are paired.

  MeasurementGroupEntriesPageProvider call(String parentId, int limit) =>
      MeasurementGroupEntriesPageProvider._(
        argument: (parentId, limit),
        from: this,
      );

  @override
  String toString() => r'measurementGroupEntriesPageProvider';
}

/// The newest entry of every category, keyed by category id.
///
/// For the rows that show a last known value next to a chart of a shorter
/// range: widening the chart's range to reach the value would materialise
/// every entry in between.

@ProviderFor(latestMeasurementEntries)
final latestMeasurementEntriesProvider = LatestMeasurementEntriesProvider._();

/// The newest entry of every category, keyed by category id.
///
/// For the rows that show a last known value next to a chart of a shorter
/// range: widening the chart's range to reach the value would materialise
/// every entry in between.

final class LatestMeasurementEntriesProvider
    extends
        $FunctionalProvider<
          AsyncValue<Map<String, MeasurementEntry>>,
          Map<String, MeasurementEntry>,
          Stream<Map<String, MeasurementEntry>>
        >
    with
        $FutureModifier<Map<String, MeasurementEntry>>,
        $StreamProvider<Map<String, MeasurementEntry>> {
  /// The newest entry of every category, keyed by category id.
  ///
  /// For the rows that show a last known value next to a chart of a shorter
  /// range: widening the chart's range to reach the value would materialise
  /// every entry in between.
  LatestMeasurementEntriesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'latestMeasurementEntriesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$latestMeasurementEntriesHash();

  @$internal
  @override
  $StreamProviderElement<Map<String, MeasurementEntry>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<Map<String, MeasurementEntry>> create(Ref ref) {
    return latestMeasurementEntries(ref);
  }
}

String _$latestMeasurementEntriesHash() => r'87b87ef6ca747e9f47855692f9e687b85f81e99b';

/// The chart points of one category, condensed by SQLite.
///
/// Kept apart from the category streams, which hand over the entries
/// themselves. [level] is what the chart in question needs, see
/// `chartBucketLevel`.

@ProviderFor(measurementChartBuckets)
final measurementChartBucketsProvider = MeasurementChartBucketsFamily._();

/// The chart points of one category, condensed by SQLite.
///
/// Kept apart from the category streams, which hand over the entries
/// themselves. [level] is what the chart in question needs, see
/// `chartBucketLevel`.

final class MeasurementChartBucketsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<MeasurementBucket>>,
          List<MeasurementBucket>,
          Stream<List<MeasurementBucket>>
        >
    with $FutureModifier<List<MeasurementBucket>>, $StreamProvider<List<MeasurementBucket>> {
  /// The chart points of one category, condensed by SQLite.
  ///
  /// Kept apart from the category streams, which hand over the entries
  /// themselves. [level] is what the chart in question needs, see
  /// `chartBucketLevel`.
  MeasurementChartBucketsProvider._({
    required MeasurementChartBucketsFamily super.from,
    required (String, DateTime?, MeasurementBucketLevel) super.argument,
  }) : super(
         retry: null,
         name: r'measurementChartBucketsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$measurementChartBucketsHash();

  @override
  String toString() {
    return r'measurementChartBucketsProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $StreamProviderElement<List<MeasurementBucket>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<MeasurementBucket>> create(Ref ref) {
    final argument = this.argument as (String, DateTime?, MeasurementBucketLevel);
    return measurementChartBuckets(ref, argument.$1, argument.$2, argument.$3);
  }

  @override
  bool operator ==(Object other) {
    return other is MeasurementChartBucketsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$measurementChartBucketsHash() => r'90698be9ec4f287fc4764549bc6cbcb5b7933262';

/// The chart points of one category, condensed by SQLite.
///
/// Kept apart from the category streams, which hand over the entries
/// themselves. [level] is what the chart in question needs, see
/// `chartBucketLevel`.

final class MeasurementChartBucketsFamily extends $Family
    with
        $FunctionalFamilyOverride<
          Stream<List<MeasurementBucket>>,
          (String, DateTime?, MeasurementBucketLevel)
        > {
  MeasurementChartBucketsFamily._()
    : super(
        retry: null,
        name: r'measurementChartBucketsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The chart points of one category, condensed by SQLite.
  ///
  /// Kept apart from the category streams, which hand over the entries
  /// themselves. [level] is what the chart in question needs, see
  /// `chartBucketLevel`.

  MeasurementChartBucketsProvider call(
    String categoryId,
    DateTime? since,
    MeasurementBucketLevel level,
  ) => MeasurementChartBucketsProvider._(
    argument: (categoryId, since, level),
    from: this,
  );

  @override
  String toString() => r'measurementChartBucketsProvider';
}

/// The chart points of a group's components, keyed by component id.
///
/// One query for the whole group, and one calendar unit: a component condensed
/// on its own would put the halves of a reading in different buckets.

@ProviderFor(measurementGroupBuckets)
final measurementGroupBucketsProvider = MeasurementGroupBucketsFamily._();

/// The chart points of a group's components, keyed by component id.
///
/// One query for the whole group, and one calendar unit: a component condensed
/// on its own would put the halves of a reading in different buckets.

final class MeasurementGroupBucketsProvider
    extends
        $FunctionalProvider<
          AsyncValue<Map<String, List<MeasurementBucket>>>,
          Map<String, List<MeasurementBucket>>,
          Stream<Map<String, List<MeasurementBucket>>>
        >
    with
        $FutureModifier<Map<String, List<MeasurementBucket>>>,
        $StreamProvider<Map<String, List<MeasurementBucket>>> {
  /// The chart points of a group's components, keyed by component id.
  ///
  /// One query for the whole group, and one calendar unit: a component condensed
  /// on its own would put the halves of a reading in different buckets.
  MeasurementGroupBucketsProvider._({
    required MeasurementGroupBucketsFamily super.from,
    required (String, DateTime?, MeasurementBucketLevel) super.argument,
  }) : super(
         retry: null,
         name: r'measurementGroupBucketsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$measurementGroupBucketsHash();

  @override
  String toString() {
    return r'measurementGroupBucketsProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $StreamProviderElement<Map<String, List<MeasurementBucket>>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<Map<String, List<MeasurementBucket>>> create(Ref ref) {
    final argument = this.argument as (String, DateTime?, MeasurementBucketLevel);
    return measurementGroupBuckets(ref, argument.$1, argument.$2, argument.$3);
  }

  @override
  bool operator ==(Object other) {
    return other is MeasurementGroupBucketsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$measurementGroupBucketsHash() => r'c266e55762bf15490b557a3dae3de909eee55ea0';

/// The chart points of a group's components, keyed by component id.
///
/// One query for the whole group, and one calendar unit: a component condensed
/// on its own would put the halves of a reading in different buckets.

final class MeasurementGroupBucketsFamily extends $Family
    with
        $FunctionalFamilyOverride<
          Stream<Map<String, List<MeasurementBucket>>>,
          (String, DateTime?, MeasurementBucketLevel)
        > {
  MeasurementGroupBucketsFamily._()
    : super(
        retry: null,
        name: r'measurementGroupBucketsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The chart points of a group's components, keyed by component id.
  ///
  /// One query for the whole group, and one calendar unit: a component condensed
  /// on its own would put the halves of a reading in different buckets.

  MeasurementGroupBucketsProvider call(
    String parentId,
    DateTime? since,
    MeasurementBucketLevel level,
  ) => MeasurementGroupBucketsProvider._(
    argument: (parentId, since, level),
    from: this,
  );

  @override
  String toString() => r'measurementGroupBucketsProvider';
}

/// How often each value of a category occurred, for the histogram.

@ProviderFor(measurementValueCounts)
final measurementValueCountsProvider = MeasurementValueCountsFamily._();

/// How often each value of a category occurred, for the histogram.

final class MeasurementValueCountsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<MeasurementValueCount>>,
          List<MeasurementValueCount>,
          Stream<List<MeasurementValueCount>>
        >
    with
        $FutureModifier<List<MeasurementValueCount>>,
        $StreamProvider<List<MeasurementValueCount>> {
  /// How often each value of a category occurred, for the histogram.
  MeasurementValueCountsProvider._({
    required MeasurementValueCountsFamily super.from,
    required (String, DateTime?, bool) super.argument,
  }) : super(
         retry: null,
         name: r'measurementValueCountsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$measurementValueCountsHash();

  @override
  String toString() {
    return r'measurementValueCountsProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $StreamProviderElement<List<MeasurementValueCount>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<MeasurementValueCount>> create(Ref ref) {
    final argument = this.argument as (String, DateTime?, bool);
    return measurementValueCounts(ref, argument.$1, argument.$2, argument.$3);
  }

  @override
  bool operator ==(Object other) {
    return other is MeasurementValueCountsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$measurementValueCountsHash() => r'a92e20ad52075b37e2faaa754ff9fd7619a36be7';

/// How often each value of a category occurred, for the histogram.

final class MeasurementValueCountsFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<MeasurementValueCount>>, (String, DateTime?, bool)> {
  MeasurementValueCountsFamily._()
    : super(
        retry: null,
        name: r'measurementValueCountsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// How often each value of a category occurred, for the histogram.

  MeasurementValueCountsProvider call(
    String categoryId,
    DateTime? since,
    bool summedPerDay,
  ) => MeasurementValueCountsProvider._(
    argument: (categoryId, since, summedPerDay),
    from: this,
  );

  @override
  String toString() => r'measurementValueCountsProvider';
}

/// One category with its children and without their entries, null while it
/// does not exist (or no longer does).

@ProviderFor(measurementCategory)
final measurementCategoryProvider = MeasurementCategoryFamily._();

/// One category with its children and without their entries, null while it
/// does not exist (or no longer does).

final class MeasurementCategoryProvider
    extends
        $FunctionalProvider<
          AsyncValue<MeasurementCategory?>,
          MeasurementCategory?,
          Stream<MeasurementCategory?>
        >
    with $FutureModifier<MeasurementCategory?>, $StreamProvider<MeasurementCategory?> {
  /// One category with its children and without their entries, null while it
  /// does not exist (or no longer does).
  MeasurementCategoryProvider._({
    required MeasurementCategoryFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'measurementCategoryProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$measurementCategoryHash();

  @override
  String toString() {
    return r'measurementCategoryProvider'
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
    final argument = this.argument as String;
    return measurementCategory(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is MeasurementCategoryProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$measurementCategoryHash() => r'9064d6e8ee04c562a1ae1bb8c1f6523f6f22ee9d';

/// One category with its children and without their entries, null while it
/// does not exist (or no longer does).

final class MeasurementCategoryFamily extends $Family
    with $FunctionalFamilyOverride<Stream<MeasurementCategory?>, String> {
  MeasurementCategoryFamily._()
    : super(
        retry: null,
        name: r'measurementCategoryProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// One category with its children and without their entries, null while it
  /// does not exist (or no longer does).

  MeasurementCategoryProvider call(String id) =>
      MeasurementCategoryProvider._(argument: id, from: this);

  @override
  String toString() => r'measurementCategoryProvider';
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
