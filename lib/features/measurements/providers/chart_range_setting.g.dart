// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chart_range_setting.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The time range the measurement charts cover, shared by the overview, the
/// category detail screens and the weight screen: a pick follows the user
/// through them instead of every screen starting over at its own default.
///
/// keepAlive on purpose: autoDispose would reset the pick whenever no screen
/// is listening for a moment (a tab switch), which is exactly the surprise
/// this provider removes. It holds for the session; a restart starts over.

@ProviderFor(ChartRangeSetting)
final chartRangeSettingProvider = ChartRangeSettingProvider._();

/// The time range the measurement charts cover, shared by the overview, the
/// category detail screens and the weight screen: a pick follows the user
/// through them instead of every screen starting over at its own default.
///
/// keepAlive on purpose: autoDispose would reset the pick whenever no screen
/// is listening for a moment (a tab switch), which is exactly the surprise
/// this provider removes. It holds for the session; a restart starts over.
final class ChartRangeSettingProvider extends $NotifierProvider<ChartRangeSetting, ChartRange> {
  /// The time range the measurement charts cover, shared by the overview, the
  /// category detail screens and the weight screen: a pick follows the user
  /// through them instead of every screen starting over at its own default.
  ///
  /// keepAlive on purpose: autoDispose would reset the pick whenever no screen
  /// is listening for a moment (a tab switch), which is exactly the surprise
  /// this provider removes. It holds for the session; a restart starts over.
  ChartRangeSettingProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'chartRangeSettingProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$chartRangeSettingHash();

  @$internal
  @override
  ChartRangeSetting create() => ChartRangeSetting();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ChartRange value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ChartRange>(value),
    );
  }
}

String _$chartRangeSettingHash() => r'ca0074ed6745f437866cdddccf93eec3b6e1dd7b';

/// The time range the measurement charts cover, shared by the overview, the
/// category detail screens and the weight screen: a pick follows the user
/// through them instead of every screen starting over at its own default.
///
/// keepAlive on purpose: autoDispose would reset the pick whenever no screen
/// is listening for a moment (a tab switch), which is exactly the surprise
/// this provider removes. It holds for the session; a restart starts over.

abstract class _$ChartRangeSetting extends $Notifier<ChartRange> {
  ChartRange build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<ChartRange, ChartRange>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ChartRange, ChartRange>,
              ChartRange,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
