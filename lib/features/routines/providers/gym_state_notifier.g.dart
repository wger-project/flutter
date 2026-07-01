// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gym_state_notifier.dart';

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

String _$gymStateNotifierHash() => r'213315cfc2f3047fe99ab88e81ee7e570e7c6ec3';

abstract class _$GymStateNotifier extends $Notifier<GymModeState> {
  GymModeState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<GymModeState, GymModeState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<GymModeState, GymModeState>,
              GymModeState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
