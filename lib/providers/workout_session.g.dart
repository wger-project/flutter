// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_session.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(sessionStateReady)
const sessionStateReadyProvider = SessionStateReadyProvider._();

final class SessionStateReadyProvider
    extends $FunctionalProvider<AsyncValue<void>, void, FutureOr<void>>
    with $FutureModifier<void>, $FutureProvider<void> {
  const SessionStateReadyProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sessionStateReadyProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sessionStateReadyHash();

  @$internal
  @override
  $FutureProviderElement<void> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<void> create(Ref ref) {
    return sessionStateReady(ref);
  }
}

String _$sessionStateReadyHash() => r'18a6a7239149a753760d90c35cfcb739aec8a631';

@ProviderFor(WorkoutSessionNotifier)
const workoutSessionProvider = WorkoutSessionNotifierProvider._();

final class WorkoutSessionNotifierProvider
    extends $StreamNotifierProvider<WorkoutSessionNotifier, List<WorkoutSession>> {
  const WorkoutSessionNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'workoutSessionProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$workoutSessionNotifierHash();

  @$internal
  @override
  WorkoutSessionNotifier create() => WorkoutSessionNotifier();
}

String _$workoutSessionNotifierHash() => r'10a3dc311941aac5efa09e047f97bc1387ccd0ef';

abstract class _$WorkoutSessionNotifier extends $StreamNotifier<List<WorkoutSession>> {
  Stream<List<WorkoutSession>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<List<WorkoutSession>>, List<WorkoutSession>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<WorkoutSession>>, List<WorkoutSession>>,
              AsyncValue<List<WorkoutSession>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
