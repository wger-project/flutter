// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'body_weight_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The user's official body weight category.
///
/// The category is created by the server (registration / data migration) and
/// only arrives via sync; a `null` value means the initial sync has not
/// delivered it yet. Mutations go through `measurementProvider`'s notifier,
/// its readings through the aggregated queries, which take its id from here.
///
/// Selected by its type in the query rather than picked out of every category
/// afterwards: it has no fixed id, the server assigns it.

@ProviderFor(bodyWeightCategoryOnly)
final bodyWeightCategoryOnlyProvider = BodyWeightCategoryOnlyProvider._();

/// The user's official body weight category.
///
/// The category is created by the server (registration / data migration) and
/// only arrives via sync; a `null` value means the initial sync has not
/// delivered it yet. Mutations go through `measurementProvider`'s notifier,
/// its readings through the aggregated queries, which take its id from here.
///
/// Selected by its type in the query rather than picked out of every category
/// afterwards: it has no fixed id, the server assigns it.

final class BodyWeightCategoryOnlyProvider
    extends
        $FunctionalProvider<
          AsyncValue<MeasurementCategory?>,
          MeasurementCategory?,
          Stream<MeasurementCategory?>
        >
    with $FutureModifier<MeasurementCategory?>, $StreamProvider<MeasurementCategory?> {
  /// The user's official body weight category.
  ///
  /// The category is created by the server (registration / data migration) and
  /// only arrives via sync; a `null` value means the initial sync has not
  /// delivered it yet. Mutations go through `measurementProvider`'s notifier,
  /// its readings through the aggregated queries, which take its id from here.
  ///
  /// Selected by its type in the query rather than picked out of every category
  /// afterwards: it has no fixed id, the server assigns it.
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

String _$bodyWeightCategoryOnlyHash() => r'4da2ba139461e391f146b0a3d51e59a82c28afe3';
