// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rest_timer_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Holds the set timer for gym mode.
///
/// The timer lives in a keepAlive provider rather than in the log page widget
/// so that it keeps running when the user navigates between exercises (the page
/// widget that started it is disposed on auto-advance). The state is `null`
/// until the first set is logged.

@ProviderFor(RestTimer)
final restTimerProvider = RestTimerProvider._();

/// Holds the set timer for gym mode.
///
/// The timer lives in a keepAlive provider rather than in the log page widget
/// so that it keeps running when the user navigates between exercises (the page
/// widget that started it is disposed on auto-advance). The state is `null`
/// until the first set is logged.
final class RestTimerProvider
    extends $NotifierProvider<RestTimer, RestTimerState?> {
  /// Holds the set timer for gym mode.
  ///
  /// The timer lives in a keepAlive provider rather than in the log page widget
  /// so that it keeps running when the user navigates between exercises (the page
  /// widget that started it is disposed on auto-advance). The state is `null`
  /// until the first set is logged.
  RestTimerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'restTimerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$restTimerHash();

  @$internal
  @override
  RestTimer create() => RestTimer();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RestTimerState? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RestTimerState?>(value),
    );
  }
}

String _$restTimerHash() => r'98478a1501958769e6c2a598ccb637050aaa8438';

/// Holds the set timer for gym mode.
///
/// The timer lives in a keepAlive provider rather than in the log page widget
/// so that it keeps running when the user navigates between exercises (the page
/// widget that started it is disposed on auto-advance). The state is `null`
/// until the first set is logged.

abstract class _$RestTimer extends $Notifier<RestTimerState?> {
  RestTimerState? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<RestTimerState?, RestTimerState?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<RestTimerState?, RestTimerState?>,
              RestTimerState?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
