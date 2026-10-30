/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (c)  2026 wger Team
 *
 * wger Workout Manager is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:wger/core/consts.dart';
import 'package:wger/core/misc.dart';
import 'package:wger/features/routines/models/log.dart';
import 'package:wger/features/routines/models/set_config_data.dart';
import 'package:wger/features/routines/providers/gym_state.dart';
import 'package:wger/features/routines/validators.dart';
import 'package:wger/l10n/generated/app_localizations.dart';

/// How much "+30 s" adds to a rest
const REST_EXTENSION = Duration(seconds: 30);

/// Identifies the gym session and the slot pages a notification action targets
class WorkoutNotificationPayload extends Equatable {
  final int routineId;
  final int dayId;
  final int iteration;
  final DateTime workoutStart;

  /// The log page the "log set" action logs
  final String? logSlotKey;

  /// The timer page the "skip rest" action leaves
  final String? restSlotKey;

  const WorkoutNotificationPayload({
    required this.routineId,
    required this.dayId,
    required this.iteration,
    required this.workoutStart,
    this.logSlotKey,
    this.restSlotKey,
  });

  /// Whether this belongs to the session [state] is running
  bool matches(GymModeState state) =>
      state.isInitialized &&
      state.routine.id == routineId &&
      state.dayId == dayId &&
      state.iteration == iteration &&
      state.workoutStart.isAtSameMomentAs(workoutStart);

  String encode() => jsonEncode({
    'routineId': routineId,
    'dayId': dayId,
    'iteration': iteration,
    'workoutStart': workoutStart.toUtc().toIso8601String(),
    'logSlotKey': logSlotKey,
    'restSlotKey': restSlotKey,
  });

  /// Null if [payload] is missing or not one of ours
  static WorkoutNotificationPayload? decode(String? payload) {
    if (payload == null) {
      return null;
    }
    try {
      final json = jsonDecode(payload) as Map<String, dynamic>;
      return WorkoutNotificationPayload(
        routineId: json['routineId'] as int,
        dayId: json['dayId'] as int,
        iteration: json['iteration'] as int,
        workoutStart: DateTime.parse(json['workoutStart'] as String),
        logSlotKey: json['logSlotKey'] as String?,
        restSlotKey: json['restSlotKey'] as String?,
      );
    } on Object {
      return null;
    }
  }

  @override
  List<Object?> get props => [routineId, dayId, iteration, workoutStart, logSlotKey, restSlotKey];
}

/// The ongoing notification while a workout runs (Android)
class WorkoutControls extends Equatable {
  final String title;
  final String body;

  /// Shown next to the app name, e.g. that the rest is over
  final String? subtitle;

  /// Reference time of the chronometer, none if null
  final DateTime? chronometerAt;
  final bool chronometerCountsDown;

  final bool canLogSet;
  final bool canSkipRest;
  final bool canExtendRest;
  final WorkoutNotificationPayload payload;

  /// Values of earlier logs that "log set" offers besides the planned ones
  final List<String> quickLogs;

  /// Image of the exercise the notification is about
  final Uri? image;

  const WorkoutControls({
    required this.title,
    required this.body,
    required this.payload,
    this.subtitle,
    this.chronometerAt,
    this.chronometerCountsDown = false,
    this.canLogSet = false,
    this.canSkipRest = false,
    this.canExtendRest = false,
    this.quickLogs = const [],
    this.image,
  });

  @override
  List<Object?> get props => [
    title,
    body,
    subtitle,
    chronometerAt,
    chronometerCountsDown,
    canLogSet,
    canSkipRest,
    canExtendRest,
    payload,
    quickLogs,
    image,
  ];
}

/// The notification that fires when the rest is over
class RestAlarm extends Equatable {
  final DateTime at;
  final String title;
  final String body;
  final String? subtitle;
  final bool canLogSet;
  final bool canExtendRest;
  final WorkoutNotificationPayload payload;

  /// See [WorkoutControls.quickLogs]
  final List<String> quickLogs;
  final Uri? image;

  /// Without sound, only to switch the controls to the rest end
  final bool silent;

  const RestAlarm({
    required this.at,
    required this.title,
    required this.body,
    required this.payload,
    this.subtitle,
    this.canLogSet = false,
    this.canExtendRest = false,
    this.quickLogs = const [],
    this.image,
    this.silent = false,
  });

  @override
  List<Object?> get props => [
    at,
    title,
    body,
    subtitle,
    canLogSet,
    canExtendRest,
    payload,
    quickLogs,
    image,
    silent,
  ];
}

/// Localized texts the platform needs besides the notification content
class WorkoutNotificationLabels extends Equatable {
  final String logSet;
  final String skipRest;
  final String extendRest;
  final String controlsChannel;
  final String alarmChannel;
  final String notLoggedTitle;
  final String notLoggedBody;

  const WorkoutNotificationLabels({
    required this.logSet,
    required this.skipRest,
    required this.extendRest,
    required this.controlsChannel,
    required this.alarmChannel,
    required this.notLoggedTitle,
    required this.notLoggedBody,
  });

  WorkoutNotificationLabels.of(AppLocalizations i18n)
    : logSet = i18n.workoutNotificationLogSet,
      skipRest = i18n.workoutNotificationSkipRest,
      extendRest = i18n.workoutNotificationExtendRest(REST_EXTENSION.inSeconds),
      controlsChannel = i18n.workoutNotificationChannel,
      alarmChannel = i18n.workoutNotificationAlarmChannel,
      notLoggedTitle = i18n.workoutNotificationNotLoggedTitle,
      notLoggedBody = i18n.workoutNotificationNotLoggedBody;

  @override
  List<Object?> get props => [
    logSet,
    skipRest,
    extendRest,
    controlsChannel,
    alarmChannel,
    notLoggedTitle,
    notLoggedBody,
  ];
}

/// What the OS should show for the workout, nothing if both are null
class WorkoutNotificationTarget extends Equatable {
  final WorkoutControls? controls;
  final RestAlarm? alarm;

  const WorkoutNotificationTarget({this.controls, this.alarm});

  static const none = WorkoutNotificationTarget();

  bool get isEmpty => controls == null && alarm == null;

  @override
  List<Object?> get props => [controls, alarm];
}

/// How many earlier logs "log set" offers at most
const _MAX_QUICK_LOGS = 3;

/// The earlier logs of [planned]'s exercise that "log set" offers, by label.
///
/// Newest first, one per label, without the planned values. Only plain
/// repetitions: other units have server names that need a BuildContext. The
/// label leaves out the RiR, so a choice keeps the planned one.
Map<String, Log> quickLogChoices(SetConfigData planned, List<Log> recentLogs) {
  // What "log set" logs, with the units resolved
  final plannedLog = Log.fromSetConfigData(planned);
  final choices = <String, Log>{};
  for (final log in recentLogs) {
    if (choices.length == _MAX_QUICK_LOGS) {
      break;
    }
    final isPlanned =
        log.repetitions == plannedLog.repetitions &&
        log.repetitionsUnitId == plannedLog.repetitionsUnitId &&
        log.weight == plannedLog.weight &&
        log.weightUnitId == plannedLog.weightUnitId;
    if (log.exerciseId != planned.exerciseId ||
        log.repetitionsUnitId != REP_UNIT_REPETITIONS_ID ||
        log.repetitions == null ||
        isPlanned) {
      continue;
    }
    final weight = log.weight;
    final label = [
      formatNum(log.repetitions!).toString(),
      if (weight != null && weight != 0) ...[
        '×',
        formatNum(weight).toString(),
        ?log.weightUnitObj?.name,
      ],
    ].join(' ');
    choices.putIfAbsent(label, () => log.copyWith()..rir = plannedLog.rir);
  }
  return choices;
}

/// Derives the workout notifications from [state] at [now].
///
/// [withControls] is whether the ongoing notification is supported and wanted.
/// [recentLogs] are earlier logs of the exercise of the set to log, see
/// [quickLogChoices], and [mediaUrl] turns an image path into its URL.
WorkoutNotificationTarget buildWorkoutNotification(
  GymModeState state, {
  required DateTime now,
  required AppLocalizations i18n,
  required String languageCode,
  required bool withControls,
  List<Log> recentLogs = const [],
  Uri? Function(String? path)? mediaUrl,
}) {
  if (!state.isInitialized) {
    return WorkoutNotificationTarget.none;
  }

  final slotPages = state.pages.expand((p) => p.slotPages).toList();
  final current = state.getSlotEntryPageByIndex();

  // The rest and RiR in the full text don't fit a notification
  String values(SetConfigData config) => config.textReprShort ?? config.textRepr;

  String setText(SlotPageEntry page) {
    final config = page.setConfigData!;
    return '${config.exercise.getTranslation(languageCode).name} ${values(config)}';
  }

  String exerciseName(SlotPageEntry page) =>
      page.setConfigData!.exercise.getTranslation(languageCode).name;

  /// "Set 2 of 3 · 10 × 60 kg", counted within the exercise
  String setOf(SlotPageEntry page) {
    final sameExercise = state
        .getPageByIndex(page.pageIndex)!
        .slotPages
        .where(
          (p) =>
              p.type == SlotPageType.log &&
              p.setConfigData!.exerciseId == page.setConfigData!.exerciseId,
        )
        .toList();
    return '${i18n.workoutNotificationSetOf(sameExercise.indexOf(page) + 1, sameExercise.length)}'
        ' · ${values(page.setConfigData!)}';
  }

  bool canLog(SlotPageEntry page) =>
      !state.progressOf(page.key).done &&
      isWorkoutLogComplete(
        repetitions: page.setConfigData!.repetitions,
        weight: page.setConfigData!.weight,
      );

  List<String> quickLogs(SlotPageEntry page) =>
      canLog(page) ? quickLogChoices(page.setConfigData!, recentLogs).keys.toList() : const [];

  Uri? image(SlotPageEntry? page) =>
      page == null ? null : mediaUrl?.call(page.setConfigData!.exercise.getMainImage?.image);

  WorkoutNotificationPayload payload({String? logSlotKey, String? restSlotKey}) =>
      WorkoutNotificationPayload(
        routineId: state.routine.id!,
        dayId: state.dayId,
        iteration: state.iteration,
        workoutStart: state.workoutStart,
        logSlotKey: logSlotKey,
        restSlotKey: restSlotKey,
      );

  if (current?.type == SlotPageType.timer) {
    final following = slotPages.firstWhereOrNull(
      (p) => p.type == SlotPageType.log && p.pageIndex > current!.pageIndex,
    );
    // The set right after the rest, the one the rest end is about
    final next = following?.pageIndex == current!.pageIndex + 1 ? following : null;
    final actionPayload = payload(logSlotKey: next?.key, restSlotKey: current.key);

    final nextText = following == null ? '' : i18n.workoutNotificationNext(setText(following));
    final endsAt = state.restEndsAt;
    final restRunning = endsAt != null && endsAt.isAfter(now);

    // Once the rest is over the notification shows the set, like the page
    // after the rest. Logging during the rest is left to the set itself. With
    // the alert off the controls still switch over, silently.
    final alarm = restRunning && (state.alertOnCountdownEnd || withControls)
        ? RestAlarm(
            at: endsAt,
            title: next == null ? i18n.workoutNotificationRestOver : exerciseName(next),
            body: next == null ? nextText : setOf(next),
            subtitle: next == null ? null : i18n.workoutNotificationRestOver,
            canLogSet: next != null && canLog(next),
            // Starts another short countdown
            canExtendRest: true,
            payload: actionPayload,
            quickLogs: next == null ? const [] : quickLogs(next),
            image: image(next ?? following),
            silent: !state.alertOnCountdownEnd,
          )
        : null;

    final WorkoutControls? controls;
    if (!withControls) {
      controls = null;
    } else if (endsAt != null && !restRunning && next != null) {
      controls = WorkoutControls(
        title: exerciseName(next),
        body: setOf(next),
        subtitle: i18n.workoutNotificationRestOver,
        canLogSet: canLog(next),
        canExtendRest: true,
        payload: actionPayload,
        quickLogs: quickLogs(next),
        image: image(next),
      );
    } else {
      controls = WorkoutControls(
        title: endsAt != null && !restRunning ? i18n.workoutNotificationRestOver : i18n.pause,
        body: nextText,
        chronometerAt: endsAt == null ? state.restStartedAt : (restRunning ? endsAt : null),
        chronometerCountsDown: restRunning,
        canSkipRest: true,
        canExtendRest: endsAt != null,
        payload: actionPayload,
        image: image(following),
      );
    }

    return WorkoutNotificationTarget(controls: controls, alarm: alarm);
  }

  if (!withControls) {
    return WorkoutNotificationTarget.none;
  }

  if (current?.type == SlotPageType.log) {
    return WorkoutNotificationTarget(
      controls: WorkoutControls(
        title: exerciseName(current!),
        body: setOf(current),
        canLogSet: canLog(current),
        payload: payload(logSlotKey: current.key),
        quickLogs: quickLogs(current),
        image: image(current),
      ),
    );
  }

  return WorkoutNotificationTarget(
    controls: WorkoutControls(
      title: i18n.workoutNotificationInProgress,
      body: '',
      chronometerAt: state.workoutStart,
      payload: payload(),
    ),
  );
}
