// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gym_log_state.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(GymLogNotifier)
final gymLogProvider = GymLogNotifierProvider._();

final class GymLogNotifierProvider extends $NotifierProvider<GymLogNotifier, Log?> {
  GymLogNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'gymLogProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$gymLogNotifierHash();

  @$internal
  @override
  GymLogNotifier create() => GymLogNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Log? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Log?>(value),
    );
  }
}

String _$gymLogNotifierHash() => r'25aa3cab12922554aaae891192cb1fe354aae0fe';

abstract class _$GymLogNotifier extends $Notifier<Log?> {
  Log? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<Log?, Log?>;
    final element =
        ref.element as $ClassProviderElement<AnyNotifier<Log?, Log?>, Log?, Object?, Object?>;
    element.handleCreate(ref, build);
  }
}
