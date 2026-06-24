// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_logs_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Streams the past logs for [exerciseId] within [routineId], newest first.
///
/// Reads the local `workout_log` table directly, so a set logged during a
/// workout shows up immediately, independent of the gym-mode routine snapshot.

@ProviderFor(pastExerciseLogs)
final pastExerciseLogsProvider = PastExerciseLogsFamily._();

/// Streams the past logs for [exerciseId] within [routineId], newest first.
///
/// Reads the local `workout_log` table directly, so a set logged during a
/// workout shows up immediately, independent of the gym-mode routine snapshot.

final class PastExerciseLogsProvider
    extends
        $FunctionalProvider<AsyncValue<List<Log>>, List<Log>, Stream<List<Log>>>
    with $FutureModifier<List<Log>>, $StreamProvider<List<Log>> {
  /// Streams the past logs for [exerciseId] within [routineId], newest first.
  ///
  /// Reads the local `workout_log` table directly, so a set logged during a
  /// workout shows up immediately, independent of the gym-mode routine snapshot.
  PastExerciseLogsProvider._({
    required PastExerciseLogsFamily super.from,
    required ({int routineId, int exerciseId}) super.argument,
  }) : super(
         retry: null,
         name: r'pastExerciseLogsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$pastExerciseLogsHash();

  @override
  String toString() {
    return r'pastExerciseLogsProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $StreamProviderElement<List<Log>> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<List<Log>> create(Ref ref) {
    final argument = this.argument as ({int routineId, int exerciseId});
    return pastExerciseLogs(
      ref,
      routineId: argument.routineId,
      exerciseId: argument.exerciseId,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is PastExerciseLogsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$pastExerciseLogsHash() => r'e2345fbf5c2bcbaa81a673d39212a59099de5424';

/// Streams the past logs for [exerciseId] within [routineId], newest first.
///
/// Reads the local `workout_log` table directly, so a set logged during a
/// workout shows up immediately, independent of the gym-mode routine snapshot.

final class PastExerciseLogsFamily extends $Family
    with
        $FunctionalFamilyOverride<
          Stream<List<Log>>,
          ({int routineId, int exerciseId})
        > {
  PastExerciseLogsFamily._()
    : super(
        retry: null,
        name: r'pastExerciseLogsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Streams the past logs for [exerciseId] within [routineId], newest first.
  ///
  /// Reads the local `workout_log` table directly, so a set logged during a
  /// workout shows up immediately, independent of the gym-mode routine snapshot.

  PastExerciseLogsProvider call({
    required int routineId,
    required int exerciseId,
  }) => PastExerciseLogsProvider._(
    argument: (routineId: routineId, exerciseId: exerciseId),
    from: this,
  );

  @override
  String toString() => r'pastExerciseLogsProvider';
}
