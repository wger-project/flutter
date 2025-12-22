// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trophies.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(trophyRepository)
const trophyRepositoryProvider = TrophyRepositoryProvider._();

final class TrophyRepositoryProvider
    extends $FunctionalProvider<TrophyRepository, TrophyRepository, TrophyRepository>
    with $Provider<TrophyRepository> {
  const TrophyRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'trophyRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$trophyRepositoryHash();

  @$internal
  @override
  $ProviderElement<TrophyRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  TrophyRepository create(Ref ref) {
    return trophyRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TrophyRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TrophyRepository>(value),
    );
  }
}

String _$trophyRepositoryHash() => r'0699f0c0f7f324f3ba9b21420d9845a3e3096b61';

@ProviderFor(TrophyStateNotifier)
const trophyStateProvider = TrophyStateNotifierProvider._();

final class TrophyStateNotifierProvider extends $NotifierProvider<TrophyStateNotifier, void> {
  const TrophyStateNotifierProvider._()
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
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$trophyStateNotifierHash() => r'47b4babf337bbb8bf60142ebe59dc760fa08dce3';

abstract class _$TrophyStateNotifier extends $Notifier<void> {
  void build();
  @$mustCallSuper
  @override
  void runBuild() {
    build();
    final ref = this.ref as $Ref<void, void>;
    final element =
        ref.element as $ClassProviderElement<AnyNotifier<void, void>, void, Object?, Object?>;
    element.handleValue(ref, null);
  }
}
