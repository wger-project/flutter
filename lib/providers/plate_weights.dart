import 'package:flutter/widgets.dart';
import 'package:wger/helpers/gym_mode.dart';

class PlateWeights extends ChangeNotifier{
  String unitOfPlate = 'kg';
  bool flag = false;
  num totalWeight = 0;
  num barWeight = 20;
  num convertTolbs = 2.205;
  num totalWeightInKg = 0;
  num barWeightInKg = 20;
  List<num> selectedWeights = [];
  List<num> kgWeights = [1.25, 2.5, 5, 10, 15, 20, 25];
  List<num> lbsWeights = [2.5, 5, 10, 25, 35, 45];
  List<num> customPlates = [];
  late Map<num,int> grouped;

  void unitChange() {
    if(unitOfPlate=='lbs') {
      totalWeight = totalWeightInKg;
      unitOfPlate = 'kg';
      barWeight = barWeightInKg;
    } else {
      unitOfPlate = 'lbs';
      totalWeight = totalWeightInKg*2.205;
      barWeight = barWeightInKg*2.205;
    }
    notifyListeners();
  }

  void toggleSelection(num x) {
    if(unitOfPlate == 'kg') {
      if(selectedWeights.contains(x)) {
        selectedWeights.remove(x);
      } else {
        selectedWeights.add(x);
      }
    } else {
        if(selectedWeights.contains(x)) {
          selectedWeights.remove(x);
        } else {
          selectedWeights.add(x);
        }
    }
    notifyListeners();
  }

  void clear() {
    selectedWeights.clear();
    notifyListeners();
  }

  void setWeight(num x) {
    totalWeight = x;
    totalWeightInKg=x;
    notifyListeners();
  }

  void calculatePlates() {
    selectedWeights.sort();
    customPlates = plateCalculator(totalWeight,barWeight,selectedWeights);
    grouped =  groupPlates(customPlates);
    notifyListeners();
  }

  void resetPlates() {
    selectedWeights = [];
    notifyListeners();
  } 
}  