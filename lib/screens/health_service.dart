import 'dart:io';

import 'package:flutter/services.dart';
import 'package:health/health.dart';
import 'package:logging/logging.dart';
import 'package:wger/models/measurements/measurement_category.dart';
import 'package:wger/models/measurements/measurement_entry.dart';
import 'package:wger/providers/health_sync_provider.dart';
import 'package:wger/providers/measurement.dart';

class HealthService {
  final _logger = Logger('HealthService');
  final Health health = Health();
  final HealthSyncProvider provider;
  final MeasurementProvider measurementProvider;

  final types = [
    HealthDataType.HEART_RATE,
    HealthDataType.STEPS,
    HealthDataType.ACTIVE_ENERGY_BURNED,
    HealthDataType.WEIGHT,
    HealthDataType.WATER,
  ];

  HealthService(this.provider, this.measurementProvider);

  /// Requests permissions for health data types. Updates provider state accordingly.
  Future<bool> requestPermissions() async {
    provider.setLoading(true);
    provider.setError(null);

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

  String internalNameForType(HealthDataType type) {
    return type.toString().split('.').last.toLowerCase();
  }

  /// Ensures all required categories for the given HealthDataTypes exist in MeasurementProvider
  Future<void> _ensureCategoriesExist(List<HealthDataType> types) async {
    // Only run on Android and iOS
    if (!(Platform.isAndroid || Platform.isIOS)) {
      return;
    }
    await measurementProvider.fetchAndSetCategories();
    final existingCategories = measurementProvider.categories;

    String displayNameForType(HealthDataType type) {
      switch (type) {
        case HealthDataType.HEART_RATE:
          return 'Heart Rate';
        case HealthDataType.STEPS:
          return 'Steps';
        case HealthDataType.ACTIVE_ENERGY_BURNED:
          return 'Active Energy Burned';
        case HealthDataType.SLEEP_ASLEEP:
          return 'Sleep Asleep';
        case HealthDataType.DISTANCE_DELTA:
          return 'Distance';
        default:
          return internalNameForType(type);
      }
    }

    String unitForType(HealthDataType type) {
      switch (type) {
        case HealthDataType.HEART_RATE:
          return 'bpm';
        case HealthDataType.STEPS:
          return 'steps';
        case HealthDataType.ACTIVE_ENERGY_BURNED:
          return 'kcal';
        case HealthDataType.SLEEP_ASLEEP:
          return 'minutes';
        case HealthDataType.DISTANCE_DELTA:
          return 'm';
        default:
          return '';
      }
    }

    String sourceForPlatform() {
      if (Platform.isAndroid) return 'google_health';
      if (Platform.isIOS) return 'apple_health';
      return '';
    }

    for (final type in types) {
      final internalName = internalNameForType(type);
      final exists = existingCategories.any((cat) => cat.internalName == internalName);
      if (!exists) {
        await measurementProvider.addCategory(
          MeasurementCategory(
            name: displayNameForType(type),
            internalName: internalName,
            unit: unitForType(type),
            source: sourceForPlatform(),
          ),
        );
      }
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

    // Ensure all required categories exist before syncing
    await _ensureCategoriesExist(types);
    await measurementProvider.fetchAndSetCategories();
    final updatedCategories = measurementProvider.categories;

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
        // Kategorie-ID dynamisch suchen
        final internalName = internalNameForType(point.type);
        final category = updatedCategories.firstWhere(
          (cat) => cat.internalName == internalName,
          orElse: () => throw Exception('No category for $internalName'),
        );
        return MeasurementEntry(
          id: null,
          category: category.id!,
          date: point.dateFrom,
          value: 3,
          // value: point.value,
          notes: unit,
          source: point.sourceName ?? 'health_platform',
          uuid: point.uuid ?? null,
          created: DateTime.now(),
        );
      }).toList();
      await measurementProvider.addEntries(entries);
    } catch (e) {
      _logger.warning('Error syncing historical health data: $e');
      provider.setError('Error syncing historical health data: $e');
    }
  }
}
