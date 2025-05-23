import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wger/helpers/consts.dart';
import 'package:wger/helpers/gym_mode.dart';
import 'package:wger/helpers/shared_preferences.dart';

const DEFAULT_KG_PLATES = [2.5, 5, 10, 15, 20, 25];
const DEFAULT_LB_PLATES = [2.5, 5, 10, 25, 35, 45];

const PREFS_KEY_PLATES = 'selectedPlates';

final plateCalculatorProvider =
    StateNotifierProvider<PlateCalculatorNotifier, PlateCalculatorState>((ref) {
  return PlateCalculatorNotifier();
});

class PlateCalculatorState {
  final _logger = Logger('PlateWeightsState');

  final barWeightKg = 20;
  final barWeightLb = 45;

  // https://en.wikipedia.org/wiki/Barbell#Bumper_plates
  final Map<double, Color> plateColorMapKg = {
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
  final Map<double, Color> plateColorMapLb = {
    55: Colors.red,
    45: Colors.blue,
    35: Colors.yellow,
    25: Colors.green,
    10: Colors.white,
    5: Colors.blue,
    2.5: Colors.green,
    1.25: Colors.white,
  };

  final bool isMetric;
  final num totalWeight;
  final List<num> selectedPlates;
  final List<num> availablePlatesKg = const [0.5, 1, 1.25, 2, 2.5, 5, 10, 15, 20, 25];
  final List<num> availablePlatesLb = const [2.5, 5, 10, 25, 35, 45];

  PlateCalculatorState({
    this.isMetric = true,
    this.totalWeight = 0,
    List<num>? selectedPlates,
  }) : selectedPlates = selectedPlates ?? [...DEFAULT_KG_PLATES];

  num get barWeight {
    return isMetric ? barWeightKg : barWeightLb;
  }

  List<num> get availablePlates {
    return isMetric ? availablePlatesKg : availablePlatesLb;
  }

  List<num> get platesList {
    return plateCalculator(totalWeight, barWeight, selectedPlates);
  }

  bool get hasPlates {
    return platesList.isNotEmpty;
  }

  Map<num, int> get calculatePlates {
    return groupPlates(plateCalculator(totalWeight, barWeight, selectedPlates));
  }

  Color getColor(num plate) {
    if (isMetric) {
      return plateColorMapKg[plate.toDouble()] ?? Colors.grey;
    }
    return plateColorMapLb[plate.toDouble()] ?? Colors.grey;
  }

  Map<String, dynamic> toJson() {
    return {'isMetric': isMetric, 'selectedPlates': selectedPlates};
  }

  PlateCalculatorState copyWith({
    bool? isMetric,
    num? totalWeight,
    List<num>? selectedPlates,
  }) {
    return PlateCalculatorState(
      isMetric: isMetric ?? this.isMetric,
      totalWeight: totalWeight ?? this.totalWeight,
      selectedPlates: selectedPlates ?? this.selectedPlates,
    );
  }
}

class PlateCalculatorNotifier extends StateNotifier<PlateCalculatorState> {
  final _logger = Logger('PlateCalculatorNotifier');

  late SharedPreferencesAsync prefs;

  PlateCalculatorNotifier({SharedPreferencesAsync? prefs}) : super(PlateCalculatorState()) {
    this.prefs = prefs ?? PreferenceHelper.asyncPref;
    _readDataFromSharedPrefs();
  }

  Future<void> saveToSharedPrefs() async {
    _logger.fine('Saving plate data to SharedPreferences');
    await prefs.setString(PREFS_KEY_PLATES, jsonEncode(state.toJson()));
  }

  Future<void> _readDataFromSharedPrefs() async {
    _logger.fine('Reading plate data from SharedPreferences');
    final prefsData = await prefs.getString(PREFS_KEY_PLATES);

    if (prefsData != null) {
      try {
        final plateData = json.decode(prefsData);
        state = state.copyWith(
          isMetric: plateData['isMetric'] ?? true,
          selectedPlates: plateData['selectedPlates'].cast<num>() ?? [...DEFAULT_KG_PLATES],
        );
      } catch (e) {
        _logger.fine('Error decoding plate data from SharedPreferences: $e');
      }
    }
  }

  Future<void> toggleSelection(num x) async {
    final newSelectedPlates = List.of(state.selectedPlates);
    if (newSelectedPlates.contains(x)) {
      newSelectedPlates.remove(x);
    } else {
      newSelectedPlates.add(x);
    }
    state = state.copyWith(selectedPlates: newSelectedPlates);
    await saveToSharedPrefs();
  }

  void unitChange({WeightUnitEnum? unit}) {
    final WeightUnitEnum changeTo =
        unit ?? (state.isMetric ? WeightUnitEnum.lb : WeightUnitEnum.kg);

    if (changeTo == WeightUnitEnum.kg && !state.isMetric) {
      state = state.copyWith(
        isMetric: true,
        totalWeight: 0,
        selectedPlates: [...DEFAULT_KG_PLATES],
      );
    }

    if (changeTo == WeightUnitEnum.lb && state.isMetric) {
      state = state.copyWith(
        isMetric: false,
        totalWeight: 0,
        selectedPlates: [...DEFAULT_LB_PLATES],
      );
    }
  }

  void setWeight(num x) {
    _logger.fine('Setting weight to $x');
    state = state.copyWith(totalWeight: x);
  }
}
