import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wger/helpers/shared_preferences.dart';
import 'package:wger/models/workouts/day_data.dart';
import 'package:wger/models/workouts/routine.dart';
import 'package:wger/models/workouts/set_config_data.dart';

part 'gym_state.g.dart';

const DEFAULT_DURATION = Duration(hours: 5);

enum PageType {
  start,
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

  PageEntry copyWith({
    PageType? type,
    int? pageIndex,
    List<SlotPageEntry>? slotPages,
  }) {
    return PageEntry(
      type: type ?? this.type,
      pageIndex: pageIndex ?? this.pageIndex,
      slotPages: slotPages ?? this.slotPages,
    );
  }

  List<int> get exerciseIds {
    final ids = <int>{};
    for (final entry in slotPages) {
      ids.add(entry.exerciseId);
    }
    return ids.toList();
  }

  // Whether all sub-pages (e.g. log pages) are marked as done.
  bool get allLogsDone =>
      slotPages.where((entry) => entry.type == SlotPageType.log).every((entry) => entry.logDone);

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

  /// Whether the log page has been marked as done
  final bool logDone;

  /// The associated SetConfigData, only available for SlotPageType.log
  final SetConfigData? setConfigData;

  SlotPageEntry({
    required this.type,
    required this.pageIndex,
    required this.exerciseId,
    required this.setIndex,
    this.setConfigData,
    this.logDone = false,
  });

  SlotPageEntry copyWith({
    SlotPageType? type,
    int? exerciseId,
    int? setIndex,
    int? pageIndex,
    SetConfigData? setConfigData,
    bool? logDone,
  }) {
    return SlotPageEntry(
      type: type ?? this.type,
      exerciseId: exerciseId ?? this.exerciseId,
      setIndex: setIndex ?? this.setIndex,
      pageIndex: pageIndex ?? this.pageIndex,
      setConfigData: setConfigData ?? this.setConfigData,
      logDone: logDone ?? this.logDone,
    );
  }

  @override
  String toString() =>
      'SlotPageEntry(type: $type, exerciseId: $exerciseId, setIndex: $setIndex, pageIndex: $pageIndex)';
}

class GymModeState {
  final _logger = Logger('GymModeState');

  final bool isInitialized;

  final List<PageEntry> pages;
  final int currentPage;

  final bool showExercisePages;
  final bool showTimerPages;

  final TimeOfDay startTime;
  final DateTime validUntil;

  late final int dayId;
  late final int iteration;
  late final Routine routine;

  GymModeState({
    this.isInitialized = false,
    this.pages = const [],
    this.currentPage = 0,

    this.showExercisePages = true,
    this.showTimerPages = true,

    int? dayId,
    int? iteration,
    Routine? routine,

    DateTime? validUntil,
    TimeOfDay? startTime,
  }) : validUntil = validUntil ?? clock.now().add(DEFAULT_DURATION),
       startTime = startTime ?? TimeOfDay.fromDateTime(clock.now()) {
    if (dayId != null) {
      this.dayId = dayId;
    }

    if (iteration != null) {
      this.iteration = iteration;
    }

    if (routine != null) {
      this.routine = routine;
    }
  }

  GymModeState copyWith({
    bool? isInitialized,
    List<PageEntry>? pages,
    bool? showExercisePages,
    bool? showTimerPages,
    int? currentPage,
    int? totalPages,
    int? dayId,
    int? iteration,
    DateTime? validUntil,
    TimeOfDay? startTime,
    Routine? routine,
  }) {
    return GymModeState(
      isInitialized: isInitialized ?? this.isInitialized,
      pages: pages ?? this.pages,
      showExercisePages: showExercisePages ?? this.showExercisePages,
      showTimerPages: showTimerPages ?? this.showTimerPages,
      currentPage: currentPage ?? this.currentPage,
      dayId: dayId ?? this.dayId,
      iteration: iteration ?? this.iteration,
      validUntil: validUntil ?? this.validUntil,
      startTime: startTime ?? this.startTime,
      routine: routine ?? this.routine,
    );
  }

  int get totalPages {
    // Main pages (start, session, etc.)
    var count = pages.where((p) => p.type != PageType.set).length;

    // Add all other sub pages (sets, timer, etc.)
    count += pages.fold(0, (prev, e) => prev + e.slotPages.length);

    return count;
  }

  DayData get dayDataGym =>
      routine.dayDataGym.where((e) => e.iteration == iteration && e.day?.id == dayId).first;

  DayData get dayDataDisplay => routine.dayData.firstWhere(
    (e) => e.iteration == iteration && e.day?.id == dayId,
  );

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
  GymModeState build() {
    _logger.finer('Initializing GymStateNotifier');
    return GymModeState();
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

  /// Calculates the page entries
  void calculatePages() {
    var totalPages = 1;
    final List<PageEntry> pages = [PageEntry(type: PageType.start, pageIndex: totalPages - 1)];

    for (final slotData in state.dayDataGym.slots) {
      final slotPageIndex = totalPages - 1;
      final slotEntries = <SlotPageEntry>[];
      int setIndex = 0;

      // exercise overview page
      if (state.showExercisePages) {
        totalPages++;
        slotEntries.add(
          SlotPageEntry(
            type: SlotPageType.exerciseOverview,
            exerciseId: slotData.setConfigs.first.exerciseId,
            setIndex: setIndex,
            pageIndex: totalPages - 1,
          ),
        );
      }

      for (final config in slotData.setConfigs) {
        // Timer page
        if (state.showTimerPages) {
          totalPages++;
          slotEntries.add(
            SlotPageEntry(
              type: SlotPageType.timer,
              exerciseId: config.exerciseId,
              setIndex: setIndex,
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
            setIndex: setIndex,
            pageIndex: totalPages - 1,
            setConfigData: config,
          ),
        );

        setIndex++;
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

  int initData(Routine routine, int dayId, int iteration) {
    final validUntil = state.validUntil;
    final currentPage = state.currentPage;

    final shouldReset =
        (state.isInitialized && dayId != state.dayId) || validUntil.isBefore(DateTime.now());
    if (shouldReset) {
      _logger.fine('Day ID mismatch or expired validUntil date. Resetting to page 0.');
    }
    final initialPage = shouldReset ? 0 : currentPage;

    // set dayId and initial page
    state = state.copyWith(
      isInitialized: true,
      dayId: dayId,
      routine: routine,
      iteration: iteration,
      currentPage: initialPage,
    );

    // Calculate the pages
    calculatePages();

    _logger.fine('Initialized GymModeState, initialPage=$initialPage');
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

  void clear() {
    _logger.fine('Clearing state');
    state = state.copyWith(
      isInitialized: false,
      currentPage: 0,
      totalPages: 1,
      validUntil: clock.now().add(DEFAULT_DURATION),
      startTime: null,
    );
  }
}
