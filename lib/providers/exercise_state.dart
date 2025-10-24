import 'package:wger/models/exercises/category.dart';
import 'package:wger/models/exercises/equipment.dart';
import 'package:wger/models/exercises/exercise.dart';

class ExerciseState {
  final List<Exercise> exercises;
  final List<Exercise> filteredExercises;
  final List<Equipment> equipment;
  final List<ExerciseCategory> categories;
  final Filters filters;
  final bool isLoading;

  ExerciseState({
    this.exercises = const [],
    this.filteredExercises = const [],
    this.equipment = const [],
    this.categories = const [],
    this.isLoading = false,
    Filters? filters,
  }) : filters = filters ?? Filters();

  ExerciseState copyWith({
    List<Exercise>? exercises,
    List<Exercise>? filteredExercises,
    List<Equipment>? equipment,
    List<ExerciseCategory>? categories,
    Filters? filters,
    bool? isLoading,
  }) {
    return ExerciseState(
      exercises: exercises ?? this.exercises,
      filteredExercises: filteredExercises ?? this.filteredExercises,
      filters: filters ?? this.filters,
      equipment: equipment ?? this.equipment,
      categories: categories ?? this.categories,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class FilterCategory<T> {
  bool isExpanded;
  final Map<T, bool> items;
  final String title;

  List<T> get selected => [...items.keys].where((key) => items[key]!).toList();

  FilterCategory({required this.title, required this.items, this.isExpanded = false});

  FilterCategory<T> copyWith({bool? isExpanded, Map<T, bool>? items, String? title}) {
    return FilterCategory(
      isExpanded: isExpanded ?? this.isExpanded,
      items: items ?? this.items,
      title: title ?? this.title,
    );
  }
}

class Filters {
  late final FilterCategory<ExerciseCategory> exerciseCategories;
  late final FilterCategory<Equipment> equipment;
  String searchTerm;

  Filters({
    FilterCategory<ExerciseCategory>? exerciseCategories,
    FilterCategory<Equipment>? equipment,
    this.searchTerm = '',
    bool doesNeedUpdate = false,
  }) : _doesNeedUpdate = doesNeedUpdate {
    this.exerciseCategories =
        exerciseCategories ??
        FilterCategory<ExerciseCategory>(
          title: 'Category',
          items: {},
        );
    this.equipment =
        equipment ??
        FilterCategory<Equipment>(
          title: 'Equipment',
          items: {},
        );
  }

  List<FilterCategory> get filterCategories => [exerciseCategories, equipment];

  bool get isNothingMarked {
    final isExerciseCategoryMarked = exerciseCategories.items.values.any((isMarked) => isMarked);
    final isEquipmentMarked = equipment.items.values.any((isMarked) => isMarked);
    return !isExerciseCategoryMarked && !isEquipmentMarked;
  }

  bool _doesNeedUpdate = false;

  bool get doesNeedUpdate => _doesNeedUpdate;

  void markNeedsUpdate() {
    _doesNeedUpdate = true;
  }

  void markUpdated() {
    _doesNeedUpdate = false;
  }

  Filters copyWith({
    FilterCategory<ExerciseCategory>? exerciseCategories,
    FilterCategory<Equipment>? equipment,
    String? searchTerm,
    bool? doesNeedUpdate,
  }) {
    return Filters(
      exerciseCategories: exerciseCategories ?? this.exerciseCategories,
      equipment: equipment ?? this.equipment,
      searchTerm: searchTerm ?? this.searchTerm,
      doesNeedUpdate: doesNeedUpdate ?? _doesNeedUpdate,
    );
  }
}
