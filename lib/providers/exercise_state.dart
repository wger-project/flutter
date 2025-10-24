import 'package:wger/models/exercises/category.dart';
import 'package:wger/models/exercises/equipment.dart';
import 'package:wger/models/exercises/exercise.dart';
import 'package:wger/providers/exercises.dart';

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
