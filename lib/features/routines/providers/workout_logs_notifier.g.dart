// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_logs_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Streams the past logs for [exerciseId], newest first.
///
/// Without [weeksBack] only the logs of [routineId] are returned. Setting it
/// widens the scope to all routines and instead limits the logs to the last
/// [weeksBack] weeks, in which case [routineId] is ignored. With [distinct],
/// only the newest log of each repetition/weight combination is kept.

@ProviderFor(pastExerciseLogs)
final pastExerciseLogsProvider = PastExerciseLogsFamily._();

/// Streams the past logs for [exerciseId], newest first.
///
/// Without [weeksBack] only the logs of [routineId] are returned. Setting it
/// widens the scope to all routines and instead limits the logs to the last
/// [weeksBack] weeks, in which case [routineId] is ignored. With [distinct],
/// only the newest log of each repetition/weight combination is kept.

final class PastExerciseLogsProvider
    extends $FunctionalProvider<AsyncValue<List<Log>>, List<Log>, Stream<List<Log>>>
    with $FutureModifier<List<Log>>, $StreamProvider<List<Log>> {
  /// Streams the past logs for [exerciseId], newest first.
  ///
  /// Without [weeksBack] only the logs of [routineId] are returned. Setting it
  /// widens the scope to all routines and instead limits the logs to the last
  /// [weeksBack] weeks, in which case [routineId] is ignored. With [distinct],
  /// only the newest log of each repetition/weight combination is kept.
  PastExerciseLogsProvider._({
    required PastExerciseLogsFamily super.from,
    required ({int routineId, int exerciseId, int? weeksBack, bool distinct}) super.argument,
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
    final argument =
        this.argument as ({int routineId, int exerciseId, int? weeksBack, bool distinct});
    return pastExerciseLogs(
      ref,
      routineId: argument.routineId,
      exerciseId: argument.exerciseId,
      weeksBack: argument.weeksBack,
      distinct: argument.distinct,
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

String _$pastExerciseLogsHash() => r'b700cebfb109d1a8ff651d5af76812aabf2eae81';

/// Streams the past logs for [exerciseId], newest first.
///
/// Without [weeksBack] only the logs of [routineId] are returned. Setting it
/// widens the scope to all routines and instead limits the logs to the last
/// [weeksBack] weeks, in which case [routineId] is ignored. With [distinct],
/// only the newest log of each repetition/weight combination is kept.

final class PastExerciseLogsFamily extends $Family
    with
        $FunctionalFamilyOverride<
          Stream<List<Log>>,
          ({int routineId, int exerciseId, int? weeksBack, bool distinct})
        > {
  PastExerciseLogsFamily._()
    : super(
        retry: null,
        name: r'pastExerciseLogsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Streams the past logs for [exerciseId], newest first.
  ///
  /// Without [weeksBack] only the logs of [routineId] are returned. Setting it
  /// widens the scope to all routines and instead limits the logs to the last
  /// [weeksBack] weeks, in which case [routineId] is ignored. With [distinct],
  /// only the newest log of each repetition/weight combination is kept.

  PastExerciseLogsProvider call({
    required int routineId,
    required int exerciseId,
    int? weeksBack,
    bool distinct = true,
  }) => PastExerciseLogsProvider._(
    argument: (
      routineId: routineId,
      exerciseId: exerciseId,
      weeksBack: weeksBack,
      distinct: distinct,
    ),
    from: this,
  );

  @override
  String toString() => r'pastExerciseLogsProvider';
}
