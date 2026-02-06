// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gym_state.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(GymStateNotifier)
final gymStateProvider = GymStateNotifierProvider._();

final class GymStateNotifierProvider extends $NotifierProvider<GymStateNotifier, GymModeState> {
  GymStateNotifierProvider._()
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
  Override overrideWithValue(GymModeState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GymModeState>(value),
    );
  }
}

String _$gymStateNotifierHash() => r'3a0bb78e9f7e682ba93a40a73b170126b5eb5ca9';

abstract class _$GymStateNotifier extends $Notifier<GymModeState> {
  GymModeState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<GymModeState, GymModeState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<GymModeState, GymModeState>,
              GymModeState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
