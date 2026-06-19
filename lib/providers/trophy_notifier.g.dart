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

String _$trophyStateNotifierHash() => r'e9518c333786def1e29b5e03d9f2bccfca31f7c3';

abstract class _$TrophyStateNotifier extends $Notifier<TrophyState> {
  TrophyState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<TrophyState, TrophyState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<TrophyState, TrophyState>,
              TrophyState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
