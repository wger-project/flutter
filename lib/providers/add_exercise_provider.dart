import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:wger/models/exercises/base.dart';
import 'package:wger/models/exercises/category.dart';
import 'package:wger/models/exercises/equipment.dart';
import 'package:wger/models/exercises/language.dart';
import 'package:wger/models/exercises/muscle.dart';

class AddExerciseProvider with ChangeNotifier {
  List<File> get exerciseImages => [..._exerciseImages];
  List<File> _exerciseImages = [];
  String? _nameEn;
  String? _nameTranslation;
  String? _descriptionEn;
  String? _descriptionTranslation;
  Language? _language;
  List<String> _alternativeNamesEn = [];
  List<String> _alternativeNamesTranslation = [];
  ExerciseCategory? _targetArea;
  List<ExerciseBase> _variations = [];
  List<Equipment> _equipment = [];
  List<Muscle> _primaryMuscles = [];
  List<Muscle> _secondaryMuscles = [];

  void clear() {
    _exerciseImages = [];
    _alternativeNamesEn = [];
    _alternativeNamesTranslation = [];
    _targetArea = null;
    _equipment = [];
    _primaryMuscles = [];
    _secondaryMuscles = [];
  }

  set exerciseNameEn(String name) => _nameEn = name;
  set exerciseNameTrans(String name) => _nameTranslation = name;
  set descriptionEn(String description) => _descriptionEn = description;
  set descriptionTrans(String description) => _descriptionTranslation = description;
  set alternateNamesEn(List<String> names) => _alternativeNamesEn = names;
  set alternateNamesTrans(List<String> names) => _alternativeNamesTranslation = names;

  set equipment(List<Equipment> equipment) => _equipment = equipment;
  set targetArea(ExerciseCategory target) => _targetArea = target;
  set language(Language language) => _language = language;

  List<Muscle> get primaryMuscles => [..._primaryMuscles];
  set primaryMuscles(List<Muscle> muscles) {
    _primaryMuscles = muscles;
  }

  List<Muscle> get secondaryMuscles => [..._secondaryMuscles];
  set secondaryMuscles(List<Muscle> muscles) {
    _secondaryMuscles = muscles;
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

    log('Base data...');
    log('Target area : $_targetArea');
    log('Primary muscles: $_primaryMuscles');
    log('Secondary muscles: $_secondaryMuscles');
    log('Equipment: $_equipment');
    log('Variations: $_variations');

    log('');
    log('Language specific...');
    log('Language: ${_language?.shortName}');
    log('Name: en/$_nameEn translation/$_nameTranslation');
    log('Description: en/$_descriptionEn translation/$_descriptionTranslation');
    log('Alternate names: en/$_alternativeNamesEn translation/$_alternativeNamesTranslation');
  }
}
