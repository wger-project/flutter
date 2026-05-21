// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_session_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(WorkoutSessionNotifier)
final workoutSessionProvider = WorkoutSessionNotifierProvider._();

final class WorkoutSessionNotifierProvider
    extends $StreamNotifierProvider<WorkoutSessionNotifier, List<WorkoutSession>> {
  WorkoutSessionNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'workoutSessionProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$workoutSessionNotifierHash();

  @$internal
  @override
  WorkoutSessionNotifier create() => WorkoutSessionNotifier();
}

String _$workoutSessionNotifierHash() => r'82394a22af6348c7a228d757b7757a8d394e91a4';

abstract class _$WorkoutSessionNotifier extends $StreamNotifier<List<WorkoutSession>> {
  Stream<List<WorkoutSession>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<WorkoutSession>>, List<WorkoutSession>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<WorkoutSession>>, List<WorkoutSession>>,
              AsyncValue<List<WorkoutSession>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
