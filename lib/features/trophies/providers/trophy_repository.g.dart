// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trophy_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(trophyRepository)
final trophyRepositoryProvider = TrophyRepositoryProvider._();

final class TrophyRepositoryProvider
    extends $FunctionalProvider<TrophyRepository, TrophyRepository, TrophyRepository>
    with $Provider<TrophyRepository> {
  TrophyRepositoryProvider._()
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
