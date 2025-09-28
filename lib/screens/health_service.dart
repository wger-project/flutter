import 'package:flutter/services.dart';
import 'package:health/health.dart';
import 'package:logging/logging.dart';

import '../models/measurements/measurement_entry.dart';
import '../providers/health_sync_provider.dart';
import '../providers/measurement.dart';

class HealthService {
  final _logger = Logger('HealthService');
  final Health health = Health();
  final HealthSyncProvider provider;
  final MeasurementProvider measurementProvider;

  HealthService(this.provider, this.measurementProvider);

  /// Requests permissions for health data types. Updates provider state accordingly.
  Future<bool> requestPermissions() async {
    provider.setLoading(true);
    provider.setError(null);
    final types = [
      HealthDataType.HEART_RATE,
      HealthDataType.STEPS,
      HealthDataType.ACTIVE_ENERGY_BURNED,
      HealthDataType.WEIGHT,
      HealthDataType.WATER,
    ];
    final permissions = types.map((_) => HealthDataAccess.READ).toList();
    try {
      final granted = await health.requestAuthorization(types, permissions: permissions);
      if (granted) {
        await _syncHistoricalData();
      }
      provider.setConnected(granted);
      provider.setLoading(false);
      return granted;
    } on MissingPluginException catch (e) {
      _logger.warning('Health Connect plugin not found: ${e.message}');
      provider.setError('Health Connect is not available. Please install it from the Play Store.');
      provider.setConnected(false);
      provider.setLoading(false);
      return false;
    } on UnsupportedError catch (e) {
      _logger.warning('Health Connect is not supported on this device: ${e.message}');
      provider.setError('Health Connect is not supported on this device.');
      provider.setConnected(false);
      provider.setLoading(false);
      return false;
    } catch (e) {
      _logger.warning('Error requesting health permissions: $e');
      provider.setError('Error requesting health permissions: $e');
      provider.setConnected(false);
      provider.setLoading(false);
      return false;
    }
  }

  /// Fetch historical health data for the last 30 days
  Future<void> _syncHistoricalData() async {
    final now = DateTime.now();
    final startTime = now.subtract(const Duration(days: 30));
    final types = [
      HealthDataType.HEART_RATE,
      HealthDataType.STEPS,
      HealthDataType.ACTIVE_ENERGY_BURNED,
      HealthDataType.SLEEP_ASLEEP,
      HealthDataType.DISTANCE_DELTA,
    ];

    final Map<HealthDataType, int> categoryMap = {
      HealthDataType.HEART_RATE: 1,
      HealthDataType.STEPS: 2,
      HealthDataType.ACTIVE_ENERGY_BURNED: 3,
      HealthDataType.SLEEP_ASLEEP: 4,
      HealthDataType.DISTANCE_DELTA: 5,
    };
    try {
      final dataPoints = await health.getHealthDataFromTypes(
        startTime: startTime,
        endTime: now,
        types: types,
      );
      final entries = dataPoints.map((point) {
        String unit;
        switch (point.type) {
          case HealthDataType.HEART_RATE:
            unit = 'bpm';
            break;
          case HealthDataType.STEPS:
            unit = 'steps';
            break;
          case HealthDataType.ACTIVE_ENERGY_BURNED:
            unit = 'kcal';
            break;
          case HealthDataType.SLEEP_ASLEEP:
            unit = 'minutes';
            break;
          case HealthDataType.DISTANCE_DELTA:
            unit = 'm';
            break;
          default:
            unit = point.unitString ?? '';
        }
        return MeasurementEntry(
          id: null,
          category: categoryMap[point.type] ?? 0,
          date: point.dateFrom,
          value: 3,
          //point.value,
          notes: unit,
          source: point.sourceName ?? 'health_platform',
          uuid: point.uuid ?? null,
          created: DateTime.now(),
        );
      }).toList();
      //await measurementProvider.addEntries(entries);
    } catch (e) {
      _logger.warning('Error syncing historical health data: $e');
      provider.setError('Error syncing historical health data: $e');
    }
  }
}
