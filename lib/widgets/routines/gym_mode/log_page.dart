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

import 'package:collection/collection.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:wger/helpers/consts.dart';
import 'package:wger/helpers/i18n.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/models/exercises/exercise.dart';
import 'package:wger/models/workouts/log.dart';
import 'package:wger/models/workouts/set_config_data.dart';
import 'package:wger/models/workouts/slot_entry.dart';
import 'package:wger/providers/gym_state.dart';
import 'package:wger/providers/gym_state_notifier.dart';
import 'package:wger/providers/rest_timer_notifier.dart';
import 'package:wger/providers/user_profile_notifier.dart';
import 'package:wger/providers/workout_logs_notifier.dart';
import 'package:wger/widgets/exercises/exercises.dart';
import 'package:wger/widgets/routines/gym_mode/log_page/palette.dart';
import 'package:wger/widgets/routines/gym_mode/workout_menu.dart';

part 'log_page/chrome.dart';
part 'log_page/hero.dart';
part 'log_page/set_panel.dart';
part 'log_page/sets_section.dart';
part 'log_page/sheets.dart';

// ---------------------------------------------------------------------------
// LogPage
// ---------------------------------------------------------------------------

class LogPage extends ConsumerStatefulWidget {
  final PageController _controller;
  final PageEntry _pageEntry;

  // ignore: prefer_const_constructors_in_immutables
  LogPage(this._controller, {required PageEntry pageEntry}) : _pageEntry = pageEntry;

  @override
  ConsumerState<LogPage> createState() => _LogPageState();
}

class _LogPageState extends ConsumerState<LogPage> {
  final Map<String, Log> _logs = {};
  final Map<String, TextEditingController> _weightControllers = {};
  final Map<String, TextEditingController> _repsControllers = {};
  final Map<String, TextEditingController> _rirControllers = {};

  int _selectedWeightUnitId = WEIGHT_UNIT_KG;

  /// The set the user has explicitly tapped to work on. When null, the active
  /// set defaults to the earliest un-logged one. Tapping any set row selects it,
  /// which is how a set is skipped and returned to later (FR6c): tap the next
  /// set to skip ahead past e.g. a warm-up, tap the warm-up again to come back.
  /// Selecting an already-logged set re-opens it for editing.
  String? _activeSlotUUID;
  final Map<String, SlotEntryType> _setTypeOverrides = {};

  /// Drives the horizontal action bar so a mouse wheel / trackpad can scroll it
  /// on desktop and web (same treatment as the exercise-queue strip).
  final ScrollController _actionBarController = ScrollController();

  @override
  void initState() {
    super.initState();
    _initLogs();
    _initWeightUnit();
  }

  void _ensureControllersForSlot(SlotPageEntry sp, GymModeState gymState) {
    if (_logs.containsKey(sp.uuid)) {
      return;
    }

    final log = Log.fromSetConfigData(sp.setConfigData!);
    log.routineId = gymState.routine.id!;
    log.iteration = gymState.iteration;
    log.weightUnitId = _selectedWeightUnitId;
    _logs[sp.uuid] = log;

    final config = sp.setConfigData!;
    final w = config.weight;
    final r = config.repetitions;
    final rir = config.rir;

    _weightControllers[sp.uuid] = TextEditingController(
      text: w != null ? (w % 1 == 0 ? w.toInt().toString() : w.toString()) : '',
    );
    _repsControllers[sp.uuid] = TextEditingController(
      text: r != null ? (r % 1 == 0 ? r.toInt().toString() : r.toString()) : '',
    );
    _rirControllers[sp.uuid] = TextEditingController(
      text: rir != null ? (rir % 1 == 0 ? rir.toInt().toString() : rir.toString()) : '',
    );
  }

  void _initLogs() {
    final gymState = ref.read(gymStateProvider);
    for (final sp in widget._pageEntry.slotPages.where((sp) => sp.type == SlotPageType.log)) {
      _ensureControllersForSlot(sp, gymState);
    }
  }

  void _initWeightUnit() {
    // Only kg / lb can be represented by the in-panel toggle.
    int? pickToggleUnit(int? id) => (id == WEIGHT_UNIT_KG || id == WEIGHT_UNIT_LB) ? id : null;

    final gymState = ref.read(gymStateProvider);
    final firstSlot = widget._pageEntry.slotPages.firstWhereOrNull(
      (sp) => sp.type == SlotPageType.log,
    );

    // FR4b: default to the unit used for this exercise in the most recent
    // previous session, falling back to the routine's per-set-config unit.
    int? priorUnit;
    final exerciseId = firstSlot?.setConfigData?.exerciseId;
    if (exerciseId != null) {
      final priorLogs =
          gymState.routine
              .filterLogsByExercise(exerciseId)
              .where((l) => l.date.isBefore(gymState.startedAt) && l.weightUnitId != null)
              .toList()
            ..sort((a, b) => b.date.compareTo(a.date));
      if (priorLogs.isNotEmpty) {
        priorUnit = priorLogs.first.weightUnitId;
      }
    }

    var unitId =
        pickToggleUnit(priorUnit) ?? pickToggleUnit(firstSlot?.setConfigData?.weightUnitId);

    // ...otherwise the user's profile preference, then kg.
    if (unitId == null) {
      final profile = ref.read(userProfileProvider).value;
      unitId = profile == null
          ? WEIGHT_UNIT_KG
          : (profile.isMetric ? WEIGHT_UNIT_KG : WEIGHT_UNIT_LB);
    }

    _selectedWeightUnitId = unitId;
    for (final log in _logs.values) {
      log.weightUnitId = _selectedWeightUnitId;
    }
  }

  @override
  void dispose() {
    for (final ctrl in _weightControllers.values) {
      ctrl.dispose();
    }
    for (final ctrl in _repsControllers.values) {
      ctrl.dispose();
    }
    for (final ctrl in _rirControllers.values) {
      ctrl.dispose();
    }
    _actionBarController.dispose();
    super.dispose();
  }

  void _toggleWeightUnit() {
    final newUnitId = _selectedWeightUnitId == WEIGHT_UNIT_KG ? WEIGHT_UNIT_LB : WEIGHT_UNIT_KG;
    setState(() {
      _selectedWeightUnitId = newUnitId;
      for (final log in _logs.values) {
        log.weightUnitId = newUnitId;
      }
    });
  }

  Future<void> _onSetChecked(
    String uuid,
    bool? checked,
    BuildContext context,
    PageEntry currentEntry,
  ) async {
    if (checked == null) {
      return;
    }
    final gymNotifier = ref.read(gymStateProvider.notifier);

    if (!checked) {
      gymNotifier.markSlotPageAsDone(uuid, isDone: false);
      return;
    }

    final log = _logs[uuid]!;
    final weightText = _weightControllers[uuid]!.text.replaceAll(',', '.');
    final repsText = _repsControllers[uuid]!.text.replaceAll(',', '.');
    final rirText = _rirControllers[uuid]?.text.replaceAll(',', '.');
    log.weight = num.tryParse(weightText);
    log.repetitions = num.tryParse(repsText);
    log.rir = rirText != null && rirText.isNotEmpty ? num.tryParse(rirText) : null;

    try {
      await ref.read(workoutLogProvider).addEntry(log);
      gymNotifier.markSlotPageAsDone(uuid, isDone: true);

      final gymState = ref.read(gymStateProvider);
      final restSecs = currentEntry.slotPages
          .firstWhereOrNull((sp) => sp.uuid == uuid)
          ?.setConfigData
          ?.restTime;
      // Logging a set (re)starts the set timer. It counts down when this set
      // has a rest time (or the global countdown is on); otherwise it counts up
      // the time since the set was logged.
      final restSeconds =
          restSecs?.toInt() ??
          (gymState.useCountdownBetweenSets ? gymState.countdownDuration.inSeconds : null);
      ref.read(restTimerProvider.notifier).logSet(restSeconds: restSeconds);

      if (!mounted) {
        return;
      }
      final updatedEntry = ref
          .read(gymStateProvider)
          .pages
          .firstWhereOrNull((p) => p.uuid == widget._pageEntry.uuid);
      if (updatedEntry?.allLogsDone ?? false) {
        setState(() => _activeSlotUUID = null);
        _goToNextExercise();
      } else {
        // Advance to the next un-logged set after the one just logged; if there
        // is none after it, fall back to the earliest un-logged (e.g. a warm-up
        // that was skipped earlier resurfaces once everything else is done).
        final logs =
            updatedEntry?.slotPages.where((sp) => sp.type == SlotPageType.log).toList() ??
            const <SlotPageEntry>[];
        final loggedIdx = logs.indexWhere((sp) => sp.uuid == uuid);
        final nextSlot =
            logs.skip(loggedIdx + 1).firstWhereOrNull((sp) => !sp.logDone) ??
            logs.firstWhereOrNull((sp) => !sp.logDone);
        setState(() => _activeSlotUUID = nextSlot?.uuid);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  void _goToNextExercise() {
    final gymState = ref.read(gymStateProvider);
    final pages = gymState.pages;
    final currentIdx = pages.indexWhere((p) => p.uuid == widget._pageEntry.uuid);
    PageEntry? next;
    for (var i = currentIdx + 1; i < pages.length; i++) {
      if (pages[i].type == PageType.set || pages[i].type == PageType.session) {
        next = pages[i];
        break;
      }
    }
    if (next == null) {
      return;
    }
    widget._controller.animateToPage(
      gymState.renderIndexFor(next.pageIndex),
      duration: DEFAULT_ANIMATION_DURATION,
      curve: DEFAULT_ANIMATION_CURVE,
    );
  }

  Widget _buildActionChips(
    BuildContext context,
    PageEntry pageEntry,
    Exercise? exercise,
    String languageCode,
  ) {
    final theme = Theme.of(context);
    final p = GymPalette.of(context);
    final i18n = AppLocalizations.of(context);
    final gymState = ref.read(gymStateProvider);

    void showExerciseSheet(String title, Widget Function(BuildContext) childBuilder) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (ctx) => Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 8,
            bottom: 16 + MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: SizedBox(
            height: MediaQuery.of(ctx).size.height * 0.85,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(title, style: Theme.of(ctx).textTheme.titleMedium),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      tooltip: MaterialLocalizations.of(ctx).closeButtonLabel,
                      onPressed: () => Navigator.of(ctx).pop(),
                    ),
                  ],
                ),
                Expanded(child: SingleChildScrollView(child: childBuilder(ctx))),
              ],
            ),
          ),
        ),
      );
    }

    void showSwap() {
      showExerciseSheet(
        i18n.gymModeSwap,
        (ctx) => ExerciseSwapWidget(pageEntry.uuid, onDone: () => Navigator.of(ctx).pop()),
      );
    }

    void showAddExercise() {
      showExerciseSheet(
        i18n.addExercise,
        (ctx) => ExerciseAddWidget(pageEntry.uuid, onDone: () => Navigator.of(ctx).pop()),
      );
    }

    void addSet() => ref.read(gymStateProvider.notifier).addSetToPage(pageEntry.uuid);

    void showInfo() {
      if (exercise == null) {
        return;
      }
      final name = exercise.getTranslation(languageCode).name;
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text(name),
          content: SingleChildScrollView(child: ExerciseDetail(exercise)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(MaterialLocalizations.of(context).closeButtonLabel),
            ),
          ],
        ),
      );
    }

    void showHistory() {
      if (exercise == null) {
        return;
      }
      final sessions = _historySessionsFor(gymState, exercise.id);
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (_) => _HistorySheet(
          exercise: exercise,
          sessions: sessions,
          languageCode: languageCode,
        ),
      );
    }

    final chipLabel = theme.textTheme.bodySmall?.copyWith(
      fontWeight: FontWeight.w600,
      color: p.textPrimary,
    );

    Widget pill({required IconData icon, required String label, required VoidCallback? onPressed}) {
      return ActionChip(
        avatar: Icon(icon, size: 14, color: onPressed != null ? p.textPrimary : p.textSecondary),
        label: Text(label, style: chipLabel),
        onPressed: onPressed,
        shape: const StadiumBorder(),
        side: BorderSide.none,
        backgroundColor: p.neutralTint,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        visualDensity: VisualDensity.compact,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      );
    }

    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: p.divider, width: 0.5)),
      ),
      child: Listener(
        onPointerSignal: (event) {
          if (event is PointerScrollEvent) {
            final pos = _actionBarController.position;
            _actionBarController.jumpTo(
              (pos.pixels + event.scrollDelta.dy).clamp(pos.minScrollExtent, pos.maxScrollExtent),
            );
          }
        },
        child: ScrollConfiguration(
          behavior: const DragScrollBehavior(),
          child: SingleChildScrollView(
            controller: _actionBarController,
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Row(
              children: [
                pill(icon: Icons.swap_horiz, label: i18n.gymModeSwap, onPressed: showSwap),
                const SizedBox(width: 6),
                pill(
                  icon: Icons.add_circle_outline,
                  label: i18n.addExercise,
                  onPressed: showAddExercise,
                ),
                const SizedBox(width: 6),
                pill(icon: Icons.add, label: i18n.addSet, onPressed: addSet),
                const SizedBox(width: 6),
                pill(
                  icon: Icons.info_outline,
                  label: i18n.gymModeExerciseInfo,
                  onPressed: exercise != null ? showInfo : null,
                ),
                const SizedBox(width: 6),
                pill(
                  icon: Icons.history,
                  label: i18n.labelWorkoutLogs,
                  onPressed: exercise != null ? showHistory : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showTypePickerSheet(BuildContext context, SlotPageEntry sp, PageEntry pageEntry) {
    final currentType = resolveType(sp, _setTypeOverrides);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _TypePickerSheet(
        currentType: currentType,
        onPick: (type) {
          Navigator.of(context).pop();
          setState(() => _setTypeOverrides[sp.uuid] = type);
        },
        onRemove: () {
          Navigator.of(context).pop();
          ref.read(gymStateProvider.notifier).removeSetFromPage(pageEntry.uuid, sp.uuid);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gymState = ref.watch(gymStateProvider);
    final languageCode = Localizations.localeOf(context).languageCode;

    final pageEntry =
        gymState.pages.firstWhereOrNull((p) => p.uuid == widget._pageEntry.uuid) ??
        widget._pageEntry;
    final logSlotPages = pageEntry.slotPages.where((sp) => sp.type == SlotPageType.log).toList();

    for (final sp in logSlotPages) {
      _ensureControllersForSlot(sp, gymState);
    }

    final exercises = pageEntry.exercises;
    final isSuperset = exercises.length > 1;

    final pendingIdx = logSlotPages.indexWhere((sp) => !sp.logDone);
    final pendingSlot = pendingIdx >= 0 ? logSlotPages[pendingIdx] : null;

    // The active set is the one the user explicitly selected, otherwise the
    // earliest un-logged one. A stale selection (e.g. after a set was removed)
    // is cleared on the next frame.
    final selectedSlot = _activeSlotUUID == null
        ? null
        : logSlotPages.firstWhereOrNull((sp) => sp.uuid == _activeSlotUUID);
    if (_activeSlotUUID != null && selectedSlot == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() => _activeSlotUUID = null);
        }
      });
    }

    final activeSlot = selectedSlot ?? pendingSlot;
    final activeIdx = activeSlot != null ? logSlotPages.indexOf(activeSlot) : -1;

    // Selecting an already-logged set re-opens it for editing.
    final isEditing = activeSlot != null && activeSlot.logDone;

    // The exercise/config currently being logged. For a superset this follows
    // the active set across exercises; otherwise it is the page's exercise.
    final activeExercise =
        activeSlot?.setConfigData?.exercise ?? (exercises.isNotEmpty ? exercises.first : null);
    final activeConfig =
        activeSlot?.setConfigData ??
        (logSlotPages.isNotEmpty ? logSlotPages.first.setConfigData : null);

    // The hero describes the *exercise*, not the specific set being logged.
    // Warm-up sets carry no target text or note, so when one is the active set
    // fall back to the first set of the same exercise that does have a
    // prescription — otherwise the target pill and the note silently vanish
    // whenever a warm-up set is selected.
    final heroConfig = (activeConfig?.textRepr ?? '').isNotEmpty
        ? activeConfig
        : (logSlotPages
                  .map((sp) => sp.setConfigData)
                  .whereType<SetConfigData>()
                  .firstWhereOrNull(
                    (c) => c.exerciseId == activeExercise?.id && c.textRepr.isNotEmpty,
                  ) ??
              activeConfig);

    // Build working-set number map. Numbering restarts per exercise so each
    // exercise in a superset is counted independently (e.g. A1, A2, B1, B2).
    final workingCounts = <String, int>{};
    final perExerciseWorking = <int, int>{};
    for (final sp in logSlotPages) {
      if (resolveType(sp, _setTypeOverrides) == SlotEntryType.normal) {
        final exId = sp.setConfigData?.exerciseId ?? -1;
        final next = (perExerciseWorking[exId] ?? 0) + 1;
        perExerciseWorking[exId] = next;
        workingCounts[sp.uuid] = next;
      }
    }

    final hasRir = logSlotPages.any((sp) => sp.setConfigData?.rir != null);

    return ColoredBox(
      color: Theme.of(context).colorScheme.surface,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            children: [
              _ExerciseHero(
                exercise: activeExercise,
                exercises: exercises,
                activeExerciseId: activeExercise?.id,
                isSuperset: isSuperset,
                firstConfig: heroConfig,
                languageCode: languageCode,
              ),
              _buildActionChips(context, pageEntry, activeExercise, languageCode),
              Expanded(
                child: _SetsSection(
                  logSlotPages: logSlotPages,
                  activeUUID: activeSlot?.uuid,
                  workingCounts: workingCounts,
                  setTypeOverrides: _setTypeOverrides,
                  weightControllers: _weightControllers,
                  repsControllers: _repsControllers,
                  weightUnitId: _selectedWeightUnitId,
                  isSuperset: isSuperset,
                  languageCode: languageCode,
                  // Tap any set row to make it active; tapping the active one
                  // again reverts to the default (earliest un-logged) set.
                  onSelectTap: (uuid) => setState(() {
                    _activeSlotUUID = _activeSlotUUID == uuid ? null : uuid;
                  }),
                  onTypeTap: (sp) => _showTypePickerSheet(context, sp, pageEntry),
                ),
              ),
              _PendingSetPanel(
                activeSlot: activeSlot,
                activeIdx: activeIdx,
                isEditing: isEditing,
                pendingSlot: pendingSlot,
                weightController: activeSlot != null ? _weightControllers[activeSlot.uuid] : null,
                repsController: activeSlot != null ? _repsControllers[activeSlot.uuid] : null,
                rirController: (activeSlot != null && hasRir)
                    ? _rirControllers[activeSlot.uuid]
                    : null,
                weightUnitId: _selectedWeightUnitId,
                setTypeOverrides: _setTypeOverrides,
                workingCounts: workingCounts,
                onLogSet: () {
                  if (activeSlot == null) {
                    return;
                  }
                  if (isEditing) {
                    setState(() => _activeSlotUUID = null);
                  } else {
                    _onSetChecked(activeSlot.uuid, true, context, pageEntry);
                  }
                },
                onCancelEdit: () => setState(() => _activeSlotUUID = null),
                onAddSet: () => ref.read(gymStateProvider.notifier).addSetToPage(pageEntry.uuid),
                onUnitToggle: _toggleWeightUnit,
                onTypeTap: activeSlot != null
                    ? () => _showTypePickerSheet(context, activeSlot, pageEntry)
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
