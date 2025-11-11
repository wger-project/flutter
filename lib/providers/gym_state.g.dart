// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gym_state.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(GymStateNotifier)
const gymStateProvider = GymStateNotifierProvider._();

final class GymStateNotifierProvider extends $NotifierProvider<GymStateNotifier, GymState> {
  const GymStateNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'gymStateProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$gymStateNotifierHash();

  @$internal
  @override
  GymStateNotifier create() => GymStateNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GymState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GymState>(value),
    );
  }
}

String _$gymStateNotifierHash() => r'ee943c23a68e678830c65a0c53bfd609feb6bf62';

abstract class _$GymStateNotifier extends $Notifier<GymState> {
  GymState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<GymState, GymState>;
    final element =
        ref.element
            as $ClassProviderElement<AnyNotifier<GymState, GymState>, GymState, Object?, Object?>;
    element.handleValue(ref, created);
  }
}
