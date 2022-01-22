import 'package:flutter/foundation.dart';

import 'dart:io';

import 'package:wger/models/exercises/muscle.dart';

class AddExcerciseProvider with ChangeNotifier {
  List<File> get excerciseImages => [..._excerciseImages];
  final List<File> _excerciseImages = [];
  String? _name;
  String? _alternativeName;
  String? _targetArea;
  List<String?>? _primaryMuscles = [];
  List<String?>? _secondaryMuscles = [];

  set exerciseName(String name) => _name = name;
  set alternateName(String? name) => _alternativeName = name;
  set targetArea(String target) => _targetArea = target;
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
  printValues() {
    print('Name ${_name}');
    print('alternate name : ${_alternativeName}');
    print('target area : ${_targetArea}');
    print('primary mucsles');
    if (_primaryMuscles != null) {
      for (final a in _primaryMuscles!) {
        print(a);
      }
    }
    print('seconday mucsles');
    if (_secondaryMuscles != null) {
      for (final a in _secondaryMuscles!) {
        print(a);
      }
    }
  }
}
