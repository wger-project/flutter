import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:wger/models/exercises/category.dart';
import 'package:wger/models/exercises/equipment.dart';
import 'package:wger/models/exercises/muscle.dart';

class AddExerciseProvider with ChangeNotifier {
  List<File> get exerciseImages => [..._exerciseImages];
  List<File> _exerciseImages = [];
  String? _name;
  List<String> _alternativeNames = [];
  ExerciseCategory? _targetArea;
  List<Equipment> _equipment = [];
  List<Muscle> _primaryMuscles = [];
  List<Muscle> _secondaryMuscles = [];

  void clear() {
    _exerciseImages = [];
    _alternativeNames = [];
    _targetArea = null;
    _equipment = [];
    _primaryMuscles = [];
    _secondaryMuscles = [];
  }

  set exerciseName(String name) => _name = name;
  set equipment(List<Equipment> equipment) => _equipment = equipment;
  set alternateNames(List<String> names) => _alternativeNames = names;
  set targetArea(ExerciseCategory target) => _targetArea = target;

  List<Muscle> get primaryMuscles => [..._primaryMuscles];
  set primaryMuscles(List<Muscle> muscles) {
    if (muscles.isNotEmpty) {
      _primaryMuscles = muscles;
    }
  }

  List<Muscle> get secondaryMuscles => [..._secondaryMuscles];
  set secondaryMuscles(List<Muscle> muscles) {
    if (muscles.isNotEmpty) {
      _secondaryMuscles = muscles;
    }
  }

  void addExerciseImages(List<File> exercises) {
    _exerciseImages.addAll(exercises);
    notifyListeners();
  }

  void removeExercise(String path) {
    final file = _exerciseImages.where((element) => element.path == path).first;
    _exerciseImages.remove(file);
    notifyListeners();
  }

  //Just to Debug Provider
  void printValues() {
    log('Collected exercise data');
    log('------------------------');
    log('Name $_name');
    log('alternate names : $_alternativeNames');
    log('target area : $_targetArea');
    log('primary muscles');
    log('Equipment: $_equipment');
    log('Primary muscles: $_primaryMuscles');
    log('Secondary muscles: $_secondaryMuscles');
  }
}
