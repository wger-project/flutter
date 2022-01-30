import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:wger/models/exercises/category.dart';

class AddExcerciseProvider with ChangeNotifier {
  List<File> get excerciseImages => [..._excerciseImages];
  final List<File> _excerciseImages = [];
  String? _name;
  List<String> _alternativeNames = [];
  ExerciseCategory? _targetArea;
  List<String?>? _primaryMuscles = [];
  List<String?>? _secondaryMuscles = [];

  set exerciseName(String name) => _name = name;
  set alternateNames(List<String> names) => _alternativeNames = names;
  set targetArea(ExerciseCategory target) => _targetArea = target;
  set primaryMuclses(List<String?>? muscles) {
    if (muscles?.isNotEmpty ?? false) {
      _primaryMuscles = muscles;
    }
  }

  set secondayMuclses(List<String?>? muscles) {
    if (muscles?.isNotEmpty ?? false) {
      _secondaryMuscles = muscles;
    }
  }

  void addExcerciseImages(List<File> excercizes) {
    _excerciseImages.addAll(excercizes);
    notifyListeners();
  }

  void removeExcercise(String path) {
    final file = _excerciseImages.where((element) => element.path == path).first;
    _excerciseImages.remove(file);
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
    if (_primaryMuscles != null) {
      for (final a in _primaryMuscles!) {
        log(a!);
      }
    }
    log('seconday mucsles');
    if (_secondaryMuscles != null) {
      for (final a in _secondaryMuscles!) {
        log(a!);
      }
    }
  }
}
