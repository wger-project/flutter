import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wger/helpers/gym_mode.dart';

const DEFAULT_KG_PLATES = [2.5, 5, 10, 15, 20, 25];

const PREFS_KEY_PLATES = 'selectedPlates';

class PlateWeights extends ChangeNotifier {
  final plateColorMapKg = {
    25: Colors.red,
    20: Colors.blue,
    15: Colors.yellow,
    10: Colors.green,
    5: Colors.white,
    2.5: Colors.red,
    2: Colors.blue,
    1.25: Colors.yellow,
    1: Colors.green,
    0.5: Colors.white,
  };
  final plateColorMapLb = {
    55: Colors.red,
    45: Colors.blue,
    35: Colors.yellow,
    25: Colors.green,
    10: Colors.white,
    5: Colors.blue,
    1.25: Colors.white,
  };

  bool isMetric = true;

  bool loadedFromSharedPref = false;
  num totalWeight = 0;
  num barWeight = 20;
  num convertToLbs = 2.205;
  num totalWeightInKg = 0;
  num barWeightInKg = 20;
  List<num> selectedPlates = [...DEFAULT_KG_PLATES];
  List<num> kgWeights = [0.5, 1, 1.25, 2, 2.5, 5, 10, 15, 20, 25];
  List<num> lbsWeights = [2.5, 5, 10, 25, 35, 45];

  List<num> get data => selectedPlates;

  set data(List<num> newData) {
    selectedPlates = newData;
    saveIntoSharedPrefs();
    notifyListeners();
  }

  Color getColor(num plate) {
    if (isMetric) {
      return plateColorMapKg[plate] ?? Colors.white;
    }

    return plateColorMapLb[plate] ?? Colors.white;
  }

  Future<void> saveIntoSharedPrefs() async {
    final pref = await SharedPreferences.getInstance();
    pref.setString(PREFS_KEY_PLATES, jsonEncode(selectedPlates));
    notifyListeners();
  }

  void readPlates() async {
    final pref = await SharedPreferences.getInstance();
    final platePrefData = pref.getString(PREFS_KEY_PLATES);
    if (platePrefData != null) {
      try {
        final plateData = json.decode(platePrefData);
        if (plateData is List) {
          selectedPlates = plateData.cast<num>();
        } else {
          throw const FormatException('Not a List');
        }
      } catch (e) {
        selectedPlates = [];
      }
    }
    notifyListeners();
  }

  Future<void> toggleSelection(num x) async {
    if (selectedPlates.contains(x)) {
      selectedPlates.remove(x);
    } else {
      selectedPlates.add(x);
    }
    await saveIntoSharedPrefs();
    notifyListeners();
  }

  void unitChange() {
    if (isMetric == false) {
      totalWeight = totalWeightInKg;
      isMetric = true;
      barWeight = barWeightInKg;
    } else {
      isMetric = false;
      totalWeight = totalWeightInKg * 2.205;
      barWeight = barWeightInKg * 2.205;
    }
    notifyListeners();
  }

  void clear() async {
    selectedPlates.clear();
    await saveIntoSharedPrefs();
    notifyListeners();
  }

  void setWeight(num x) {
    totalWeight = x;
    totalWeightInKg = x;
    notifyListeners();
  }

  List<num> get platesList {
    return plateCalculator(totalWeight, barWeight, selectedPlates);
  }

  bool get hasPlates {
    return platesList.isNotEmpty;
  }

  Map<num, int> get calculatePlates {
    selectedPlates.sort();
    return groupPlates(platesList);
  }

  void resetPlates() async {
    selectedPlates = [...DEFAULT_KG_PLATES];
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('selectedPlates', jsonEncode(selectedPlates));
    notifyListeners();
  }

  void selectAllPlates() async {
    selectedPlates = [...kgWeights];
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('selectedPlates', jsonEncode(selectedPlates));
    notifyListeners();
  }
}
