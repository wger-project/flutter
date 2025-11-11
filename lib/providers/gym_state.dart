import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wger/helpers/shared_preferences.dart';
import 'package:wger/models/exercises/exercise.dart';
import 'package:wger/models/workouts/day_data.dart';

part 'gym_state.g.dart';

const DEFAULT_DURATION = Duration(hours: 5);

enum PageType {
  overview,
  set,
  session,
}

enum SlotPageType {
  exerciseOverview,
  log,
  timer,
}

class PageEntry {
  final PageType type;

  /// Absolute page index
  final int pageIndex;

  final List<SlotPageEntry> slotPages;

  PageEntry({
    required this.type,
    required this.pageIndex,
    this.slotPages = const [],
  }) : assert(
         slotPages.isEmpty || type == PageType.set,
         'SlotEntries can only be set for set pages',
       );

  List<int> get exerciseIds {
    final ids = <int>{};
    for (final entry in slotPages) {
      ids.add(entry.exerciseId);
    }
    return ids.toList();
  }

  @override
  String toString() => 'PageEntry(type: $type, pageIndex: $pageIndex)';
}

class SlotPageEntry {
  final SlotPageType type;

  final int exerciseId;

  /// index within a set for overview (e.g. "1 of 5 sets")
  final int setIndex;

  /// Absolute page index
  final int pageIndex;

  const SlotPageEntry({
    required this.type,
    required this.pageIndex,
    required this.exerciseId,
    required this.setIndex,
  });

  @override
  String toString() =>
      'SlotEntry(type: $type, exerciseId: $exerciseId, setIndex: $setIndex, pageIndex: $pageIndex)';
}

class GymState {
  final _logger = Logger('GymState');

  final List<PageEntry> pages;
  final bool showExercisePages;
  final bool showTimerPages;
  final int currentPage;
  final int totalPages;
  final int? dayId;
  final TimeOfDay startTime;
  final DateTime validUntil;

  GymState({
    this.pages = const [],
    this.showExercisePages = true,
    this.showTimerPages = true,
    this.currentPage = 0,
    this.totalPages = 1,
    this.dayId,
    DateTime? validUntil,
    TimeOfDay? startTime,
  }) : validUntil = validUntil ?? clock.now().add(DEFAULT_DURATION),
       startTime = startTime ?? TimeOfDay.fromDateTime(clock.now());

  GymState copyWith({
    List<PageEntry>? pages,
    bool? showExercisePages,
    bool? showTimerPages,
    int? currentPage,
    int? totalPages,
    int? totalElements,
    int? dayId,
    DateTime? validUntil,
    TimeOfDay? startTime,
  }) {
    return GymState(
      pages: pages ?? this.pages,
      showExercisePages: showExercisePages ?? this.showExercisePages,
      showTimerPages: showTimerPages ?? this.showTimerPages,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      dayId: dayId ?? this.dayId,
      validUntil: validUntil ?? this.validUntil,
      startTime: startTime ?? this.startTime,
    );
  }

  SlotPageEntry? getSlotPageByIndex([int? pageIndex]) {
    final index = pageIndex ?? currentPage;

    for (final slotPage in pages.expand((p) => p.slotPages)) {
      if (slotPage.pageIndex == index) {
        return slotPage;
      }
    }
    return null;
  }

  double get ratioCompleted {
    if (totalPages == 0) {
      return 0.0;
    }

    return currentPage / totalPages;
  }

  @override
  String toString() {
    return 'GymState('
        'currentPage: $currentPage, '
        'totalPages: $totalPages, '
        'pages: ${pages.length} entries, '
        'dayId: $dayId, '
        'validUntil: $validUntil '
        'startTime: $startTime, '
        'showExercisePages: $showExercisePages, '
        'showTimerPages: $showTimerPages, '
        ')';
  }
}

@Riverpod(keepAlive: true)
class GymStateNotifier extends _$GymStateNotifier {
  final _logger = Logger('GymStateNotifier');

  @override
  GymState build() {
    _logger.finer('Initializing GymStateNotifier with default state');
    //loadPrefs();
    return GymState();
  }

  Future<void> loadPrefs() async {
    final prefs = PreferenceHelper.asyncPref;

    final showExercise = await prefs.getBool('showExercisePrefs');
    if (showExercise != null && showExercise != state.showExercisePages) {
      state = state.copyWith(showExercisePages: showExercise);
    }

    final showTimer = await prefs.getBool('showTimerPrefs');
    if (showTimer != null && showTimer != state.showTimerPages) {
      state = state.copyWith(showTimerPages: showTimer);
    }
    _logger.finer('Loaded preferences: showExercise=$showExercise showTimer=$showTimer');
  }

  Future<void> _savePrefs() async {
    final prefs = PreferenceHelper.asyncPref;
    await prefs.setBool('showExercisePrefs', state.showExercisePages);
    await prefs.setBool('showTimerPrefs', state.showTimerPages);
    _logger.finer(
      'Saved preferences: showExercise=${state.showExercisePages} showTimer=${state.showTimerPages}',
    );
  }

  void calculatePages(DayData dayData) {
    var totalPages = 1;

    final List<PageEntry> pages = [PageEntry(type: PageType.overview, pageIndex: 1)];

    for (final slot in dayData.slots) {
      final slotPageIndex = totalPages - 1;
      final slotEntries = <SlotPageEntry>[];

      // exercise overview page
      if (state.showExercisePages) {
        totalPages++;
        slotEntries.add(
          SlotPageEntry(
            type: SlotPageType.exerciseOverview,
            exerciseId: slot.setConfigs.first.exerciseId,
            setIndex: 0,
            pageIndex: totalPages - 1,
          ),
        );
      }

      int setNr = 1;
      for (final config in slot.setConfigs) {
        // Timer page
        if (state.showTimerPages) {
          totalPages++;
          slotEntries.add(
            SlotPageEntry(
              type: SlotPageType.timer,
              exerciseId: config.exerciseId,
              setIndex: setNr,
              pageIndex: totalPages - 1,
            ),
          );
        }

        // Log page
        totalPages++;
        slotEntries.add(
          SlotPageEntry(
            type: SlotPageType.log,
            exerciseId: config.exerciseId,
            setIndex: setNr,
            pageIndex: totalPages - 1,
          ),
        );

        setNr++;
      }

      pages.add(
        PageEntry(
          type: PageType.set,
          pageIndex: slotPageIndex,
          slotPages: slotEntries,
        ),
      );
    }

    pages.add(
      PageEntry(type: PageType.session, pageIndex: totalPages),
    );

    state = state.copyWith(
      pages: pages,
      totalPages: totalPages,
    );
    _logger.finer('Initialized ${state.pages.length} pages');
  }

  Future<int> initForDay(
    DayData dayData, {
    required Exercise Function(int) findExerciseById,
  }) async {
    calculatePages(dayData);

    final newDayId = dayData.day!.id!;
    final validUntil = state.validUntil;
    final currentPage = state.currentPage;
    final savedDayId = state.dayId;

    final shouldReset = newDayId != savedDayId || validUntil.isBefore(DateTime.now());
    if (shouldReset) {
      _logger.fine('Day ID mismatch or expired validUntil date. Resetting to page 0.');
    }
    final initialPage = shouldReset ? 0 : currentPage;

    // set dayId and initial page
    state = state.copyWith(
      dayId: newDayId,
      currentPage: initialPage,
    );

    return initialPage;
  }

  void setCurrentPage(int page) {
    state = state.copyWith(currentPage: page);
  }

  void setShowExercisePages(bool value) {
    state = state.copyWith(showExercisePages: value);
    _savePrefs();
  }

  void setShowTimerPages(bool value) {
    state = state.copyWith(showTimerPages: value);
    _savePrefs();
  }

  void setDayId(int dayId) {
    state = state.copyWith(dayId: dayId);
  }

  void clear() {
    _logger.fine('Clearing state');
    state = state.copyWith(
      currentPage: 0,
      totalPages: 1,
      dayId: null,
      validUntil: clock.now().add(DEFAULT_DURATION),
      startTime: null,
    );
  }
}
