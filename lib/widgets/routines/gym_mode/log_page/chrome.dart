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

part of '../log_page.dart';

// ---------------------------------------------------------------------------
// Persistent chrome (header + exercise queue)
// ---------------------------------------------------------------------------

/// The fixed top chrome for the set-logging pages: the routine header and the
/// exercise queue strip.
///
/// This is rendered once *above* the gym-mode `PageView` (not inside each page)
/// so it stays still while only the content below — the hero, set list and
/// input panel — slides when navigating between exercises.
class GymModeChrome extends ConsumerWidget {
  final PageController controller;

  /// UUID of the set page currently shown, used to highlight the queue.
  final String currentPageUUID;

  const GymModeChrome({
    super.key,
    required this.controller,
    required this.currentPageUUID,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gymState = ref.watch(gymStateProvider);
    final languageCode = Localizations.localeOf(context).languageCode;
    final allSetPages = gymState.pages.where((p) => p.type == PageType.set).toList();

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _GymLogHeader(gymState: gymState),
            _ExerciseQueueStrip(
              pages: allSetPages,
              currentPageUUID: currentPageUUID,
              controller: controller,
              languageCode: languageCode,
              gymState: gymState,
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Header
// ---------------------------------------------------------------------------

class _GymLogHeader extends ConsumerStatefulWidget {
  final GymModeState gymState;

  const _GymLogHeader({
    required this.gymState,
  });

  @override
  ConsumerState<_GymLogHeader> createState() => _GymLogHeaderState();
}

class _GymLogHeaderState extends ConsumerState<_GymLogHeader> {
  late Timer _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _ticker.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final p = GymPalette.of(context);
    final i18n = AppLocalizations.of(context);

    final gymState = widget.gymState;

    // Total elapsed time since the workout started, shown as the primary header
    // clock in place of the (uninformative) routine name + week.
    final totalWorkoutSeconds = gymState.isInitialized
        ? DateTime.now().difference(gymState.startedAt).inSeconds
        : 0;

    // Formats an elapsed/remaining duration, switching to h:mm:ss past an hour.
    String fmtMinSec(int totalSeconds) {
      final h = totalSeconds ~/ 3600;
      final m = (totalSeconds % 3600) ~/ 60;
      final s = totalSeconds % 60;
      if (h > 0) {
        return '$h:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
      }
      return '$m:${s.toString().padLeft(2, '0')}';
    }

    // The rest timer only exists once the first set is logged; until then the
    // badge is hidden (total workout time is shown on the left instead). It has
    // three colour states: counting up since the last set (neutral), counting
    // down a prescribed rest (accent) and "time's up" once a rest has elapsed
    // (success/green).
    final restTimer = ref.watch(restTimerProvider);
    final (IconData, Color, Color)? timerStyle = restTimer == null
        ? null
        : switch (restTimer.mode) {
            RestTimerMode.countDown => (Icons.timer_outlined, p.accentTint, p.onAccentTint),
            RestTimerMode.timesUp => (Icons.timer_off, p.successContainer, p.onSuccessContainer),
            RestTimerMode.countUp => (Icons.timer, p.neutralTint, p.onPanel),
          };

    return Material(
      color: p.panel,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(4, 4, 8, 4),
          child: Row(
            children: [
              IconButton(
                icon: Icon(Icons.close, color: p.onPanel),
                tooltip: i18n.close,
                onPressed: () => Navigator.of(context).pop(),
              ),
              Expanded(
                child: Row(
                  children: [
                    Icon(Icons.schedule, size: 18, color: p.onPanelMuted),
                    const SizedBox(width: 6),
                    Text(
                      fmtMinSec(totalWorkoutSeconds),
                      key: const ValueKey('gym-total-time'),
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: p.onPanel,
                        fontWeight: FontWeight.w700,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
              ),
              if (restTimer != null && timerStyle != null)
                Tooltip(
                  message: i18n.restTime,
                  triggerMode: TooltipTriggerMode.tap,
                  child: Container(
                    key: const ValueKey('gym-rest-timer'),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: timerStyle.$2,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(timerStyle.$1, size: 13, color: timerStyle.$3),
                        const SizedBox(width: 4),
                        Text(
                          fmtMinSec(restTimer.seconds),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: timerStyle.$3,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Exercise queue strip
// ---------------------------------------------------------------------------

class _ExerciseQueueStrip extends StatefulWidget {
  final List<PageEntry> pages;
  final String currentPageUUID;
  final PageController controller;
  final String languageCode;
  final GymModeState gymState;

  const _ExerciseQueueStrip({
    required this.pages,
    required this.currentPageUUID,
    required this.controller,
    required this.languageCode,
    required this.gymState,
  });

  @override
  State<_ExerciseQueueStrip> createState() => _ExerciseQueueStripState();
}

class _ExerciseQueueStripState extends State<_ExerciseQueueStrip> {
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = GymPalette.of(context);
    return Container(
      decoration: BoxDecoration(
        color: p.surface,
        border: Border(bottom: BorderSide(color: p.divider, width: 0.5)),
      ),
      child: Listener(
        onPointerSignal: (event) {
          if (event is PointerScrollEvent) {
            final pos = _scrollController.position;
            _scrollController.jumpTo(
              (pos.pixels + event.scrollDelta.dy).clamp(pos.minScrollExtent, pos.maxScrollExtent),
            );
          }
        },
        child: ScrollConfiguration(
          behavior: const DragScrollBehavior(),
          child: SingleChildScrollView(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            child: Row(
              children: [
                for (var i = 0; i < widget.pages.length; i++) ...[
                  _QueueChip(
                    key: ValueKey('gym-queue-chip-${widget.pages[i].uuid}'),
                    page: widget.pages[i],
                    index: i,
                    isCurrent: widget.pages[i].uuid == widget.currentPageUUID,
                    languageCode: widget.languageCode,
                    controller: widget.controller,
                    gymState: widget.gymState,
                  ),
                  const SizedBox(width: 6),
                ],
                _FinishQueueChip(controller: widget.controller, gymState: widget.gymState),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _QueueChip extends StatelessWidget {
  final PageEntry page;
  final int index;
  final bool isCurrent;
  final String languageCode;
  final PageController controller;
  final GymModeState gymState;

  const _QueueChip({
    super.key,
    required this.page,
    required this.index,
    required this.isCurrent,
    required this.languageCode,
    required this.controller,
    required this.gymState,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final p = GymPalette.of(context);
    final isDone = page.allLogsDone;

    Color bgColor;
    Color textColor;
    Color numberBg;
    Color numberFg;

    if (isCurrent) {
      bgColor = p.accent;
      textColor = p.onAccent;
      numberBg = p.onAccent.withValues(alpha: 0.22);
      numberFg = p.onAccent;
    } else if (isDone) {
      bgColor = p.successContainer;
      textColor = p.onSuccessContainer;
      numberBg = p.success;
      numberFg = p.onSuccess;
    } else {
      bgColor = p.neutralTint;
      textColor = p.textPrimary;
      numberBg = p.c.outline;
      numberFg = p.textSecondary;
    }

    final exercises = page.exercises;
    final name = exercises.isNotEmpty
        ? exercises.first.getTranslation(languageCode).name
        : AppLocalizations.of(context).exerciseNr('${index + 1}');
    final shortName = name.length > 14 ? '${name.substring(0, 13)}…' : name;
    final numberLabel = isDone ? '✓' : '${index + 1}';

    return GestureDetector(
      onTap: () {
        final firstLog = page.slotPages.firstWhereOrNull((sp) => sp.type == SlotPageType.log);
        final target = gymState.renderIndexFor(firstLog?.pageIndex ?? page.pageIndex);
        controller.animateToPage(
          target,
          duration: DEFAULT_ANIMATION_DURATION,
          curve: DEFAULT_ANIMATION_CURVE,
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(shape: BoxShape.circle, color: numberBg),
              alignment: Alignment.center,
              child: Text(
                numberLabel,
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: numberFg),
              ),
            ),
            const SizedBox(width: 5),
            Text(
              shortName,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Terminal "Finish" action that lives at the end of the exercise queue strip
/// (rather than in the header), so it reads as the last step after the
/// exercises. Jumps to the session/summary page.
class _FinishQueueChip extends StatelessWidget {
  final PageController controller;
  final GymModeState gymState;

  const _FinishQueueChip({
    required this.controller,
    required this.gymState,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final p = GymPalette.of(context);
    final i18n = AppLocalizations.of(context);

    final sessionPage = gymState.pages.firstWhereOrNull((sp) => sp.type == PageType.session);
    final sessionPageIndex = sessionPage != null
        ? gymState.renderIndexFor(sessionPage.pageIndex)
        : (gymState.totalPages - 2);

    return GestureDetector(
      key: const ValueKey('gym-finish-button'),
      onTap: () => controller.animateToPage(
        sessionPageIndex,
        duration: DEFAULT_ANIMATION_DURATION,
        curve: DEFAULT_ANIMATION_CURVE,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: p.accent),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.flag_outlined, size: 14, color: p.accent),
            const SizedBox(width: 5),
            Text(
              i18n.gymModeFinish,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: p.accent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
