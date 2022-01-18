import 'package:flutter/foundation.dart';

import 'dart:io';

class AddExcerciseProvider with ChangeNotifier {
  List<File> get excerciseImages => [..._excerciseImages];
  final List<File> _excerciseImages = [];

  void addExcerciseImages(List<File> excercizes) {
    _excerciseImages.addAll(excercizes);
    notifyListeners();
  }

  void removeExcercise(String path) {
    final file = _excerciseImages.where((element) => element.path == path).first;
    _excerciseImages.remove(file);
    notifyListeners();
  }
}
