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
import 'package:wger/features/routines/providers/gym_state.dart';
import 'package:wger/features/routines/validators.dart';
import 'package:wger/l10n/generated/app_localizations.dart';

/// Identifies the gym session and the slot pages a notification action targets
class WorkoutNotificationPayload extends Equatable {
  final int routineId;
  final int dayId;
  final int iteration;
  final DateTime workoutStart;

  /// The log page the "log set" action logs
  final String? logSlotUuid;

  /// The timer page the "skip rest" action leaves
  final String? restSlotUuid;

  const WorkoutNotificationPayload({
    required this.routineId,
    required this.dayId,
    required this.iteration,
    required this.workoutStart,
    this.logSlotUuid,
    this.restSlotUuid,
  });

  String encode() => jsonEncode({
    'routineId': routineId,
    'dayId': dayId,
    'iteration': iteration,
    'workoutStart': workoutStart.toUtc().toIso8601String(),
    'logSlotUuid': logSlotUuid,
    'restSlotUuid': restSlotUuid,
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
        logSlotUuid: json['logSlotUuid'] as String?,
        restSlotUuid: json['restSlotUuid'] as String?,
      );
    } on Object {
      return null;
    }
  }

  @override
  List<Object?> get props => [routineId, dayId, iteration, workoutStart, logSlotUuid, restSlotUuid];
}

/// The ongoing notification while a workout runs (Android)
class WorkoutControls extends Equatable {
  final String title;
  final String body;

  /// Reference time of the chronometer, none if null
  final DateTime? chronometerAt;
  final bool chronometerCountsDown;

  final bool canLogSet;
  final bool canSkipRest;
  final WorkoutNotificationPayload payload;

  const WorkoutControls({
    required this.title,
    required this.body,
    required this.payload,
    this.chronometerAt,
    this.chronometerCountsDown = false,
    this.canLogSet = false,
    this.canSkipRest = false,
  });

  @override
  List<Object?> get props => [
    title,
    body,
    chronometerAt,
    chronometerCountsDown,
    canLogSet,
    canSkipRest,
    payload,
  ];
}

/// The notification that fires when the rest is over
class RestAlarm extends Equatable {
  final DateTime at;
  final String title;
  final String body;
  final bool canLogSet;
  final WorkoutNotificationPayload payload;

  const RestAlarm({
    required this.at,
    required this.title,
    required this.body,
    required this.payload,
    this.canLogSet = false,
  });

  @override
  List<Object?> get props => [at, title, body, canLogSet, payload];
}

/// Localized texts the platform needs besides the notification content
class WorkoutNotificationLabels extends Equatable {
  final String logSet;
  final String skipRest;
  final String controlsChannel;
  final String alarmChannel;

  const WorkoutNotificationLabels({
    required this.logSet,
    required this.skipRest,
    required this.controlsChannel,
    required this.alarmChannel,
  });

  WorkoutNotificationLabels.of(AppLocalizations i18n)
    : logSet = i18n.workoutNotificationLogSet,
      skipRest = i18n.workoutNotificationSkipRest,
      controlsChannel = i18n.workoutNotificationChannel,
      alarmChannel = i18n.gymModeRestAlarm;

  @override
  List<Object?> get props => [logSet, skipRest, controlsChannel, alarmChannel];
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

/// Derives the workout notifications from [state] at [now].
///
/// [withControls] is whether the ongoing notification is supported and wanted.
WorkoutNotificationTarget buildWorkoutNotification(
  GymModeState state, {
  required DateTime now,
  required AppLocalizations i18n,
  required String languageCode,
  required bool withControls,
}) {
  if (!state.isInitialized) {
    return WorkoutNotificationTarget.none;
  }

  final slotPages = state.pages.expand((p) => p.slotPages).toList();
  final current = state.getSlotEntryPageByIndex();

  String setText(SlotPageEntry page) {
    final config = page.setConfigData!;
    return '${config.exercise.getTranslation(languageCode).name} ${config.textRepr}';
  }

  bool plannedComplete(SlotPageEntry page) => isWorkoutLogComplete(
    repetitions: page.setConfigData!.repetitions,
    weight: page.setConfigData!.weight,
  );

  WorkoutNotificationPayload payload({String? logSlotUuid, String? restSlotUuid}) =>
      WorkoutNotificationPayload(
        routineId: state.routine.id!,
        dayId: state.dayId,
        iteration: state.iteration,
        workoutStart: state.workoutStart,
        logSlotUuid: logSlotUuid,
        restSlotUuid: restSlotUuid,
      );

  if (current?.type == SlotPageType.timer) {
    final next = slotPages.firstWhereOrNull(
      (p) => p.type == SlotPageType.log && p.pageIndex > current!.pageIndex,
    );
    final body = next == null ? '' : i18n.workoutNotificationNext(setText(next));
    // "Log set" only works from the rest right before the set
    final canLogSet =
        next != null &&
        next.pageIndex == current!.pageIndex + 1 &&
        !next.logDone &&
        plannedComplete(next);
    final actionPayload = payload(logSlotUuid: next?.uuid, restSlotUuid: current!.uuid);

    final endsAt = state.restEndsAt;
    final restRunning = endsAt != null && endsAt.isAfter(now);

    final alarm = state.restAlarmEnabled && restRunning
        ? RestAlarm(
            at: endsAt,
            title: i18n.workoutNotificationRestOver,
            body: body,
            canLogSet: canLogSet,
            payload: actionPayload,
          )
        : null;

    final controls = withControls
        ? WorkoutControls(
            title: endsAt != null && !restRunning ? i18n.workoutNotificationRestOver : i18n.pause,
            body: body,
            chronometerAt: endsAt == null ? state.restStartedAt : (restRunning ? endsAt : null),
            chronometerCountsDown: restRunning,
            canLogSet: canLogSet,
            canSkipRest: true,
            payload: actionPayload,
          )
        : null;

    return WorkoutNotificationTarget(controls: controls, alarm: alarm);
  }

  if (!withControls) {
    return WorkoutNotificationTarget.none;
  }

  if (current?.type == SlotPageType.log) {
    final page = state.getPageByIndex(current!.pageIndex)!;
    final sameExercise = page.slotPages
        .where(
          (p) =>
              p.type == SlotPageType.log &&
              p.setConfigData!.exerciseId == current.setConfigData!.exerciseId,
        )
        .toList();
    final config = current.setConfigData!;

    return WorkoutNotificationTarget(
      controls: WorkoutControls(
        title: config.exercise.getTranslation(languageCode).name,
        body:
            '${i18n.workoutNotificationSetOf(sameExercise.indexOf(current) + 1, sameExercise.length)}'
            ' · ${config.textRepr}',
        canLogSet: !current.logDone && plannedComplete(current),
        payload: payload(logSlotUuid: current.uuid),
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
