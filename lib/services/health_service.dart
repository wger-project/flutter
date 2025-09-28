// ...existing code...
import 'package:health/health.dart';

class HealthService {
  Future<bool> requestPermissions() async {
    final health = HealthFactory();
    final types = [
      HealthDataType.HEART_RATE,
      HealthDataType.STEPS,
      HealthDataType.ACTIVE_ENERGY_BURNED,
      HealthDataType.SLEEP_ASLEEP,
      HealthDataType.DISTANCE_DELTA,
    ];
    final permissions = types.map((_) => HealthDataAccess.READ).toList();
    final granted = await health.requestAuthorization(types, permissions: permissions);
    return granted;
  }
}

// ...existing code...
