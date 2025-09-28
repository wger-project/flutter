import 'package:flutter/services.dart';
import 'package:health/health.dart';
import 'package:logging/logging.dart';

class HealthService {
  final _logger = Logger('HealthService');

  final Health health = Health();

  /// Requests permissions for health data types. Returns true if granted, false otherwise.
  Future<bool> requestPermissions() async {
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
      return granted;
    } on MissingPluginException catch (e) {
      // Health Connect plugin is missing or not installed
      _logger.warning('Health Connect plugin not found: ${e.message}');
      _logger.warning('Health Connect plugin not found: ${e}');
      _logger.warning('Health Connect is not available. Please install it from the Play Store.');
      return false;
    } on UnsupportedError catch (e) {
      // Health Connect is not available on this device
      _logger.warning('Health Connect is not supported on this device: ${e.message}');
      _logger.warning('Health Connect is not supported on this device: ${e.stackTrace}');
      _logger.warning('Health Connect is not available. Please install it from the Play Store.');
      return false;
    } catch (e) {
      // Other errors
      _logger.warning('Error requesting health permissions: $e');
      return false;
    }
  }
}
