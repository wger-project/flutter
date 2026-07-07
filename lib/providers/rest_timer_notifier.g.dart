// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rest_timer_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Holds the rest countdown for gym mode.
///
/// The timer lives in a keepAlive provider rather than in the log page widget
/// so that it keeps running when the user navigates between exercises (the page
/// widget that started it is disposed on auto-advance). The state is the number
/// of seconds remaining, or `null` when no countdown is running.

@ProviderFor(RestTimer)
final restTimerProvider = RestTimerProvider._();

/// Holds the rest countdown for gym mode.
///
/// The timer lives in a keepAlive provider rather than in the log page widget
/// so that it keeps running when the user navigates between exercises (the page
/// widget that started it is disposed on auto-advance). The state is the number
/// of seconds remaining, or `null` when no countdown is running.
final class RestTimerProvider extends $NotifierProvider<RestTimer, RestTimerState?> {
  /// Holds the rest countdown for gym mode.
  ///
  /// The timer lives in a keepAlive provider rather than in the log page widget
  /// so that it keeps running when the user navigates between exercises (the page
  /// widget that started it is disposed on auto-advance). The state is the number
  /// of seconds remaining, or `null` when no countdown is running.
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

String _$restTimerHash() => r'60cbc1eac1920b7a781c0fd288736f9f5f3d5ddc';

/// Holds the rest countdown for gym mode.
///
/// The timer lives in a keepAlive provider rather than in the log page widget
/// so that it keeps running when the user navigates between exercises (the page
/// widget that started it is disposed on auto-advance). The state is the number
/// of seconds remaining, or `null` when no countdown is running.

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
