import 'package:flutter/material.dart';

class PlateConfiguration extends ChangeNotifier {
  //olympic standard weights
  List<double> _plateWeights = [1.25, 2.5, 5, 10, 15, 20, 25];

  List<double> get plateWeights => _plateWeights;

  void setPlateWeights(List<double> weights) {
    _plateWeights = weights;
    notifyListeners();
  }
}
