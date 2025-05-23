import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wger/helpers/gym_mode.dart';

const DEFAULT_KG_PLATES = [2.5, 5, 10, 15, 20, 25];

const PREFS_KEY_PLATES = 'selectedPlates';

final plateWeightsProvider = StateNotifierProvider<PlateWeightsNotifier, PlateWeightsState>((ref) {
  return PlateWeightsNotifier();
});

class PlateWeightsState {
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
    1.25: Colors.white,
  };

  final bool isMetric;
  final num totalWeight;
  final num barWeight;
  final List<num> selectedPlates;
  final List<num> kgWeights = const [0.5, 1, 1.25, 2, 2.5, 5, 10, 15, 20, 25];
  final List<num> lbsWeights = const [2.5, 5, 10, 25, 35, 45];

  PlateWeightsState({
    this.isMetric = true,
    this.totalWeight = 0,
    this.barWeight = 20,
    List<num>? selectedPlates,
  }) : selectedPlates = selectedPlates ?? [...DEFAULT_KG_PLATES];

  num get totalWeightInKg => isMetric ? totalWeight : totalWeight / 2.205;

  num get barWeightInKg => isMetric ? barWeight : barWeight / 2.205;

  List<num> get platesList {
    return plateCalculator(totalWeight, barWeight, selectedPlates);
  }

  bool get hasPlates {
    return platesList.isNotEmpty;
  }

  Map<num, int> get calculatePlates {
    List<num> sortedPlates = List.from(selectedPlates)..sort();
    return groupPlates(plateCalculator(totalWeight, barWeight, sortedPlates));
  }

  Color getColor(num plate) {
    if (isMetric) {
      return plateColorMapKg[plate.toDouble()] ?? Colors.grey;
    }
    return plateColorMapLb[plate.toDouble()] ?? Colors.grey;
  }

  PlateWeightsState copyWith({
    bool? isMetric,
    num? totalWeight,
    num? barWeight,
    List<num>? selectedPlates,
  }) {
    return PlateWeightsState(
      isMetric: isMetric ?? this.isMetric,
      totalWeight: totalWeight ?? this.totalWeight,
      barWeight: barWeight ?? this.barWeight,
      selectedPlates: selectedPlates ?? this.selectedPlates,
    );
  }
}

class PlateWeightsNotifier extends StateNotifier<PlateWeightsState> {
  PlateWeightsNotifier() : super(PlateWeightsState()) {
    _readPlates();
  }

  Future<void> _saveIntoSharedPrefs() async {
    final pref = await SharedPreferences.getInstance();
    pref.setString(PREFS_KEY_PLATES, jsonEncode(state.selectedPlates));
  }

  Future<void> _readPlates() async {
    final pref = await SharedPreferences.getInstance();
    final platePrefData = pref.getString(PREFS_KEY_PLATES);
    if (platePrefData != null) {
      try {
        final plateData = json.decode(platePrefData);
        if (plateData is List) {
          state = state.copyWith(selectedPlates: plateData.cast<num>());
        } else {
          throw const FormatException('Not a List');
        }
      } catch (e) {
        state = state.copyWith(selectedPlates: []);
      }
    }
  }

  Future<void> toggleSelection(num x) async {
    final newSelectedPlates = List<num>.from(state.selectedPlates);
    if (newSelectedPlates.contains(x)) {
      newSelectedPlates.remove(x);
    } else {
      newSelectedPlates.add(x);
    }
    state = state.copyWith(selectedPlates: newSelectedPlates);
    await _saveIntoSharedPrefs();
  }

  void unitChange() {
    if (state.isMetric == false) {
      state = state.copyWith(
        isMetric: true,
        totalWeight: state.totalWeightInKg,
        barWeight: state.barWeightInKg,
      );
    } else {
      state = state.copyWith(
        isMetric: false,
        totalWeight: state.totalWeightInKg * 2.205,
        barWeight: state.barWeightInKg * 2.205,
      );
    }
  }

  void clear() async {
    state = state.copyWith(selectedPlates: []);
    await _saveIntoSharedPrefs();
  }

  void setWeight(num x) {
    state = state.copyWith(totalWeight: x);
  }

  void resetPlates() async {
    state = state.copyWith(selectedPlates: [...DEFAULT_KG_PLATES]);
    await _saveIntoSharedPrefs();
  }

  void selectAllPlates() async {
    state = state.copyWith(selectedPlates: [...state.kgWeights]);
    await _saveIntoSharedPrefs();
  }
}
