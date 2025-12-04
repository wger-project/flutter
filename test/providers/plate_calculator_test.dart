import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart'; // Added for annotations
import 'package:mockito/mockito.dart'; // Added for mockito
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wger/helpers/consts.dart';
import 'package:wger/providers/plate_weights.dart';

import 'plate_calculator_test.mocks.dart';

@GenerateMocks([SharedPreferencesAsync])
void main() {
  group('PlateWeightsNotifier', () {
    late PlateCalculatorNotifier notifier;
    late ProviderContainer container;
    late MockSharedPreferencesAsync mockPrefs;

    setUp(() {
      mockPrefs = MockSharedPreferencesAsync();
      when(mockPrefs.getString(PREFS_KEY_PLATES)).thenAnswer((_) async => null);
      when(mockPrefs.setString(any, any)).thenAnswer((_) async => true);

      container = ProviderContainer.test(
        overrides: [
          plateCalculatorProvider.overrideWith(
            () => PlateCalculatorNotifier(prefs: mockPrefs),
          ),
        ],
      );
      notifier = container.read(plateCalculatorProvider.notifier);
    });

    test('toggleSelection adds and removes plates', () async {
      // Test adding a plate
      await notifier.toggleSelection(0.5);
      expect(notifier.state.selectedPlates.contains(0.5), true);

      // Test removing a plate
      await notifier.toggleSelection(0.5);
      expect(notifier.state.selectedPlates.contains(0.5), false);
    });

    test('unitChange updates state correctly', () {
      // Change to imperial
      notifier.setWeight(123);
      notifier.unitChange(unit: WeightUnitEnum.lb);
      expect(notifier.state.isMetric, false);
      expect(notifier.state.totalWeight, 0);
      expect(notifier.state.selectedPlates, DEFAULT_LB_PLATES);
      expect(notifier.state.barWeight, DEFAULT_BAR_WEIGHT_LB);
      expect(notifier.state.availablePlates, notifier.state.availablePlatesLb);

      // Change back to metric
      notifier.setWeight(123);
      notifier.unitChange(unit: WeightUnitEnum.kg);
      expect(notifier.state.isMetric, true);
      expect(notifier.state.totalWeight, 0);
      expect(notifier.state.selectedPlates, DEFAULT_KG_PLATES);
      expect(notifier.state.barWeight, DEFAULT_BAR_WEIGHT_KG);
      expect(notifier.state.availablePlates, notifier.state.availablePlatesKg);
    });

    test('setWeight updates totalWeight', () {
      notifier.setWeight(100);
      expect(notifier.state.totalWeight, 100);
    });
  });

  group('PlateWeightsState', () {
    test('copyWith creates a new instance with updated values', () {
      final initialState = PlateCalculatorState();
      final updatedState = initialState.copyWith(
        isMetric: false,
        totalWeight: 100,
        barWeight: 15,
        selectedPlates: [1, 2, 3],
      );

      expect(updatedState.isMetric, false);
      expect(updatedState.barWeight, 15);
      expect(updatedState.totalWeight, 100);
      expect(updatedState.selectedPlates, [1, 2, 3]);
    });

    test('toJson returns correct map', () {
      final state = PlateCalculatorState(isMetric: false, selectedPlates: [10, 20]);
      final json = state.toJson();
      expect(json['isMetric'], false);
      expect(json['barWeight'], DEFAULT_BAR_WEIGHT_LB);
      expect(json['selectedPlates'], [10, 20]);
    });

    test('barWeight returns correct default value based on isMetric', () {
      final metricState = PlateCalculatorState(isMetric: true);
      expect(metricState.barWeight, DEFAULT_BAR_WEIGHT_KG);

      final imperialState = PlateCalculatorState(isMetric: false);
      expect(imperialState.barWeight, DEFAULT_BAR_WEIGHT_LB);
    });

    test('availablePlates returns correct default list based on isMetric', () {
      final metricState = PlateCalculatorState(isMetric: true);
      expect(metricState.availablePlates, metricState.availablePlatesKg);

      final imperialState = PlateCalculatorState(isMetric: false);
      expect(imperialState.availablePlates, metricState.availablePlatesLb);
    });

    test('getColor returns correct color - 1', () {
      final metricState = PlateCalculatorState(isMetric: true);
      expect(metricState.getColor(20), Colors.blue);
      expect(metricState.getColor(10), Colors.green);
      expect(metricState.getColor(0.1), Colors.grey, reason: 'Fallback color');

      final imperialState = PlateCalculatorState(isMetric: false);
      expect(imperialState.getColor(45), Colors.blue);
      expect(imperialState.getColor(35), Colors.yellow);
      expect(imperialState.getColor(0.1), Colors.grey, reason: 'Fallback color');
    });

    test('getColor returns correct color - 2', () {
      final metricState = PlateCalculatorState(isMetric: true, useColors: false);
      expect(metricState.getColor(20), Colors.grey);
      expect(metricState.getColor(10), Colors.grey);

      final imperialState = PlateCalculatorState(isMetric: false, useColors: false);
      expect(imperialState.getColor(45), Colors.grey);
      expect(imperialState.getColor(25), Colors.grey);
    });
  });
}
