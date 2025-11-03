// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_session.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

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

String _$workoutSessionNotifierHash() => r'2d2a67179eb60855d6985af73429e39db4f80886';

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
