/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (C) 2020, 2025 wger Team
 *
 * wger Workout Manager is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * wger Workout Manager is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */
import 'dart:async';

import 'package:clock/clock.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:wger/features/routines/providers/gym_state.dart';
import 'package:wger/features/routines/providers/gym_state_notifier.dart';
import 'package:wger/features/routines/widgets/gym_mode/navigation.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/theme/theme.dart';

class TimerWidget extends ConsumerStatefulWidget {
  final PageController _controller;

  /// Identifies which slot page this widget renders, so it shows its own
  /// up-next information instead of whatever the globally-current page
  /// happens to be.
  final String slotUuid;

  const TimerWidget(this._controller, this.slotUuid);

  @override
  _TimerWidgetState createState() => _TimerWidgetState();
}

class _TimerWidgetState extends ConsumerState<TimerWidget> {
  final _maxSeconds = 600;
  late Timer _uiTimer;

  @override
  void initState() {
    super.initState();

    // The start time lives in the gym state so the timer continues when the
    // page is disposed and re-created while navigating. Deferred because a
    // provider can't be modified during the widget life-cycle.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(gymStateProvider.notifier).startTimerIfNeeded(widget.slotUuid);
      }
    });

    _uiTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      // ignore: no-empty-block, avoid-empty-setstate
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _uiTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final startTime = ref
        .watch(gymStateProvider)
        .getSlotPageByUUID(widget.slotUuid)
        ?.timerStartedAt;
    final elapsed = clock.now().difference(startTime ?? clock.now()).inSeconds;
    final displaySeconds = elapsed > _maxSeconds ? _maxSeconds : elapsed;
    final displayTime = DateTime(2000, 1, 1, 0, 0, 0).add(Duration(seconds: displaySeconds));

    return Column(
      children: [
        NavigationHeader(
          AppLocalizations.of(context).pause,
          widget._controller,
        ),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                DateFormat('m:ss').format(displayTime),
                style: Theme.of(context).textTheme.displayLarge!.copyWith(color: wgerPrimaryColor),
              ),
              const SizedBox(height: 16),
              UpNextWidget(widget.slotUuid),
            ],
          ),
        ),
        NavigationFooter(widget._controller),
      ],
    );
  }
}

class TimerCountdownWidget extends ConsumerStatefulWidget {
  final PageController _controller;
  final int _seconds;

  /// Identifies which slot page this widget renders, so it shows its own
  /// up-next information instead of whatever the globally-current page
  /// happens to be.
  final String slotUuid;

  const TimerCountdownWidget(
    this._controller,
    this._seconds,
    this.slotUuid,
  );

  @override
  _TimerCountdownWidgetState createState() => _TimerCountdownWidgetState();
}

class _TimerCountdownWidgetState extends ConsumerState<TimerCountdownWidget> {
  late Timer _uiTimer;

  bool _hasNotified = false;

  /// The moment the countdown ends. The start time lives in the gym state so
  /// the countdown continues when the page is disposed and re-created while
  /// navigating; until the state is updated, fall back to starting now.
  DateTime _endTime(GymModeState gymState) {
    final startedAt = gymState.getSlotPageByUUID(widget.slotUuid)?.timerStartedAt;
    return (startedAt ?? clock.now()).add(Duration(seconds: widget._seconds));
  }

  @override
  void initState() {
    super.initState();

    // Deferred because a provider can't be modified during the widget
    // life-cycle.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      ref.read(gymStateProvider.notifier).startTimerIfNeeded(widget.slotUuid);

      // Don't notify when returning to a countdown that already expired while
      // the user was on another page.
      if (_endTime(ref.read(gymStateProvider)).isBefore(clock.now())) {
        _hasNotified = true;
      }
    });

    _uiTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      // ignore: no-empty-block, avoid-empty-setstate
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _uiTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gymState = ref.watch(gymStateProvider);
    final remaining = _endTime(gymState).difference(clock.now());
    final remainingSeconds = remaining.inSeconds <= 0 ? 0 : remaining.inSeconds;
    final displayTime = DateTime(2000, 1, 1, 0, 0, 0).add(Duration(seconds: remainingSeconds));

    //  When countdown finishes, notify ONCE, and respect settings
    if (remainingSeconds == 0 && !_hasNotified) {
      if (gymState.alertOnCountdownEnd) {
        HapticFeedback.mediumImpact();

        // Not that this only works on desktop platforms
        SystemSound.play(SystemSoundType.alert);
      }
      setState(() {
        _hasNotified = true;
      });
    }

    return Column(
      children: [
        NavigationHeader(
          AppLocalizations.of(context).pause,
          widget._controller,
        ),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                DateFormat('m:ss').format(displayTime),
                style: Theme.of(context).textTheme.displayLarge!.copyWith(color: wgerPrimaryColor),
              ),
              const SizedBox(height: 16),
              UpNextWidget(widget.slotUuid),
            ],
          ),
        ),
        NavigationFooter(widget._controller),
      ],
    );
  }
}

/// Shows the set that will be performed once the rest timer on the slot page
/// identified by [slotUuid] ends. This can be the next set of the same
/// exercise (e.g. when progressing weights within an exercise) or the first
/// set of the next exercise. Renders nothing for the last rest of the day.
class UpNextWidget extends ConsumerWidget {
  final String slotUuid;

  const UpNextWidget(this.slotUuid, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final gymState = ref.watch(gymStateProvider);

    final currentSlotPage = gymState.getSlotPageByUUID(slotUuid);
    final nextSlotPage = currentSlotPage == null
        ? null
        : gymState.getNextLogPage(currentSlotPage.pageIndex);
    if (nextSlotPage == null) {
      return const SizedBox.shrink();
    }

    final setConfigData = nextSlotPage.setConfigData!;
    final exerciseName = setConfigData.exercise
        .getTranslation(Localizations.localeOf(context).languageCode)
        .name;
    final nrOfLogPages = gymState
        .getPageByIndex(nextSlotPage.pageIndex)
        ?.slotPages
        .where((e) => e.type == SlotPageType.log)
        .length;

    return Column(
      children: [
        Text(
          AppLocalizations.of(context).upNext,
          style: theme.textTheme.titleMedium,
        ),
        Text(
          exerciseName,
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineSmall,
        ),
        Text(
          setConfigData.textReprWithType,
          textAlign: TextAlign.center,
          style: theme.textTheme.titleLarge?.copyWith(color: theme.colorScheme.primary),
        ),
        if (nrOfLogPages != null)
          Text(
            '${nextSlotPage.setIndex + 1} / $nrOfLogPages',
            style: theme.textTheme.bodyLarge,
          ),
      ],
    );
  }
}
