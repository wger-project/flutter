// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_logs.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(WorkoutLogNotifier)
const workoutLogProvider = WorkoutLogNotifierProvider._();

final class WorkoutLogNotifierProvider
    extends $StreamNotifierProvider<WorkoutLogNotifier, List<Log>> {
  const WorkoutLogNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'workoutLogProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$workoutLogNotifierHash();

  @$internal
  @override
  WorkoutLogNotifier create() => WorkoutLogNotifier();
}

String _$workoutLogNotifierHash() => r'532917be5ce98bf849b8a16b401d89e934483e67';

abstract class _$WorkoutLogNotifier extends $StreamNotifier<List<Log>> {
  Stream<List<Log>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<List<Log>>, List<Log>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Log>>, List<Log>>,
              AsyncValue<List<Log>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
