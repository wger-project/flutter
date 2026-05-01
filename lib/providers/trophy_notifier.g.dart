// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trophy_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(TrophyStateNotifier)
final trophyStateProvider = TrophyStateNotifierProvider._();

final class TrophyStateNotifierProvider
    extends $NotifierProvider<TrophyStateNotifier, TrophyState> {
  TrophyStateNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'trophyStateProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$trophyStateNotifierHash();

  @$internal
  @override
  TrophyStateNotifier create() => TrophyStateNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TrophyState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TrophyState>(value),
    );
  }
}

String _$trophyStateNotifierHash() => r'624d9b9f4e6fb2c8a31a1e7c5dd9ec8dce870c2f';

abstract class _$TrophyStateNotifier extends $Notifier<TrophyState> {
  TrophyState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<TrophyState, TrophyState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<TrophyState, TrophyState>,
              TrophyState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
