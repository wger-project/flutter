/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (c) 2020 - 2026 wger Team
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
import 'dart:async';
import 'dart:math';

import 'package:clock/clock.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:wger/features/routines/providers/gym_state_notifier.dart';
import 'package:wger/features/routines/widgets/gym_mode/navigation.dart';
import 'package:wger/l10n/generated/app_localizations.dart';

/// Rest that counts up, from the rest start in the gym state
class TimerWidget extends ConsumerStatefulWidget {
  final PageController _controller;

  /// The timer page this widget renders
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
    final slotPage = gymState.getSlotPageByUUID(widget.slotUuid);
    if (slotPage == null) {
      return Container();
    }

    // The rest only runs while this is the current page
    final startedAt = gymState.currentPage == slotPage.pageIndex ? gymState.restStartedAt : null;
    final elapsed = startedAt == null ? 0 : clock.now().difference(startedAt).inSeconds;
    final displaySeconds = elapsed > _maxSeconds ? _maxSeconds : elapsed;
    final displayTime = DateTime(2000, 1, 1, 0, 0, 0).add(Duration(seconds: displaySeconds));

    return Column(
      children: [
        NavigationHeader(
          AppLocalizations.of(context).pause,
          widget._controller,
        ),
        Expanded(
          child: Center(
            child: Text(
              DateFormat('m:ss').format(displayTime),
              style: Theme.of(
                context,
              ).textTheme.displayLarge!.copyWith(color: Theme.of(context).colorScheme.primary),
            ),
          ),
        ),
        NavigationFooter(widget._controller),
      ],
    );
  }
}

/// Rest that counts down to the rest end in the gym state
class TimerCountdownWidget extends ConsumerStatefulWidget {
  final PageController _controller;

  /// The timer page this widget renders
  final String slotUuid;

  const TimerCountdownWidget(this._controller, this.slotUuid);

  @override
  _TimerCountdownWidgetState createState() => _TimerCountdownWidgetState();
}

class _TimerCountdownWidgetState extends ConsumerState<TimerCountdownWidget> {
  late Timer _uiTimer;

  /// The rest end the alert was played for, so each rest alerts once
  DateTime? _alertedFor;

  @override
  void initState() {
    super.initState();

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
    final slotPage = gymState.getSlotPageByUUID(widget.slotUuid);
    if (slotPage == null) {
      return Container();
    }

    // The rest only runs while this is the current page, the neighbours show
    // their full length
    final endsAt = gymState.currentPage == slotPage.pageIndex ? gymState.restEndsAt : null;
    final remaining = endsAt == null
        ? gymState.restDurationFor(slotPage)!
        : endsAt.difference(clock.now());
    final remainingSeconds = max(0, remaining.inSeconds);
    final displayTime = DateTime(2000, 1, 1, 0, 0, 0).add(Duration(seconds: remainingSeconds));

    if (endsAt != null && remainingSeconds == 0 && _alertedFor != endsAt) {
      _alertedFor = endsAt;
      if (gymState.alertOnCountdownEnd) {
        // Strongest built-in haptic on both platforms (iOS: full vibration,
        // Android: LONG_PRESS). heavyImpact maps to a weak tick on Android.
        HapticFeedback.vibrate();

        // Not that this only works on desktop platforms
        SystemSound.play(SystemSoundType.alert);
      }
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
                style: Theme.of(
                  context,
                ).textTheme.displayLarge!.copyWith(color: Theme.of(context).colorScheme.primary),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
        NavigationFooter(widget._controller),
      ],
    );
  }
}
