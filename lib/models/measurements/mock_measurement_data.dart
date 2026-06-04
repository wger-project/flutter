import 'package:wger/models/measurements/measurement_category.dart';
import 'package:wger/models/measurements/measurement_entry.dart';
import 'package:wger/models/measurements/measurement_group.dart';

// ignore: avoid_classes_with_only_static_members
class MeasurementMockData {
  static List<MeasurementGroup> get dummyGroups => [
    const MeasurementGroup(
      id: 9901,
      name: 'Body Composition (Mock)',
    ),
    const MeasurementGroup(
      id: 9902,
      name: 'Cardiovascular Metrics (Mock)',
    ),
    const MeasurementGroup(
      id: 9903,
      name: 'Strength Performance (Mock)',
    ),
  ];

  static List<MeasurementCategory> get dummyCategories {
    final now = DateTime.now();

    return [
      MeasurementCategory(
        id: 8801,
        name: 'Weight (Mock)',
        unit: 'kg',
        groupId: 9901,
        formula: 'NONE',
        entries: [
          MeasurementEntry(
            id: 7701,
            category: 8801,
            date: now.subtract(const Duration(days: 14)),
            value: 89.5,
            notes: 'Initial mock reading.',
          ),
          MeasurementEntry(
            id: 7702,
            category: 8801,
            date: now.subtract(const Duration(days: 7)),
            value: 88.8,
            notes: 'Morning weight after fasting.',
          ),
          MeasurementEntry(
            id: 7703,
            category: 8801,
            date: now.subtract(const Duration(days: 1)),
            value: 88.2,
            notes: 'Consistent drop tracked.',
          ),
          MeasurementEntry(
            id: 7726,
            category: 8801,
            date: now.subtract(const Duration(days: 32)),
            value: 88.4,
            notes: 'Auto-generated mock reading 5.',
          ),
          MeasurementEntry(
            id: 7725,
            category: 8801,
            date: now.subtract(const Duration(days: 30)),
            value: 87.9,
            notes: 'Auto-generated mock reading 6.',
          ),
          MeasurementEntry(
            id: 7724,
            category: 8801,
            date: now.subtract(const Duration(days: 28)),
            value: 87.5,
            notes: 'Auto-generated mock reading 7.',
          ),
          MeasurementEntry(
            id: 7723,
            category: 8801,
            date: now.subtract(const Duration(days: 26)),
            value: 87.3,
            notes: 'Auto-generated mock reading 8.',
          ),
          MeasurementEntry(
            id: 7722,
            category: 8801,
            date: now.subtract(const Duration(days: 24)),
            value: 87.1,
            notes: 'Auto-generated mock reading 9.',
          ),
          MeasurementEntry(
            id: 7721,
            category: 8801,
            date: now.subtract(const Duration(days: 22)),
            value: 86.6,
            notes: 'Auto-generated mock reading 10.',
          ),
          MeasurementEntry(
            id: 7720,
            category: 8801,
            date: now.subtract(const Duration(days: 20)),
            value: 86.4,
            notes: 'Auto-generated mock reading 11.',
          ),
          MeasurementEntry(
            id: 7719,
            category: 8801,
            date: now.subtract(const Duration(days: 18)),
            value: 86.0,
            notes: 'Auto-generated mock reading 12.',
          ),
          MeasurementEntry(
            id: 7718,
            category: 8801,
            date: now.subtract(const Duration(days: 16)),
            value: 85.7,
            notes: 'Auto-generated mock reading 13.',
          ),
          MeasurementEntry(
            id: 7717,
            category: 8801,
            date: now.subtract(const Duration(days: 14)),
            value: 85.4,
            notes: 'Auto-generated mock reading 14.',
          ),
          MeasurementEntry(
            id: 7716,
            category: 8801,
            date: now.subtract(const Duration(days: 12)),
            value: 85.3,
            notes: 'Auto-generated mock reading 15.',
          ),
          MeasurementEntry(
            id: 7715,
            category: 8801,
            date: now.subtract(const Duration(days: 10)),
            value: 84.9,
            notes: 'Auto-generated mock reading 16.',
          ),
          MeasurementEntry(
            id: 7714,
            category: 8801,
            date: now.subtract(const Duration(days: 8)),
            value: 84.8,
            notes: 'Auto-generated mock reading 17.',
          ),
          MeasurementEntry(
            id: 7713,
            category: 8801,
            date: now.subtract(const Duration(days: 6)),
            value: 84.7,
            notes: 'Auto-generated mock reading 18.',
          ),
          MeasurementEntry(
            id: 7712,
            category: 8801,
            date: now.subtract(const Duration(days: 4)),
            value: 84.2,
            notes: 'Auto-generated mock reading 19.',
          ),
          MeasurementEntry(
            id: 7711,
            category: 8801,
            date: now.subtract(const Duration(days: 2)),
            value: 83.9,
            notes: 'Auto-generated mock reading 20.',
          ),
        ],
      ),

      //   BMI
      MeasurementCategory(
        id: 8802,
        name: 'Body Mass Index (Mock Formula)',
        unit: 'index',
        groupId: 9901,
        formula: 'BMI',
        entries: [
          MeasurementEntry(
            id: 7704,
            category: 8802,
            date: now.subtract(const Duration(days: 14)),
            value: 24.5,
            notes: 'Computed dynamically from height/weight metrics.',
          ),
          MeasurementEntry(
            id: 7705,
            category: 8802,
            date: now.subtract(const Duration(days: 7)),
            value: 24.2,
            notes: 'Auto-updated baseline entry.',
          ),
        ],
      ),

      //  Chest Circumference has No Assigned Group Link
      MeasurementCategory(
        id: 8803,
        name: 'Chest Circumference (Mock)',
        unit: 'cm',
        groupId: null,
        formula: 'NONE',
        entries: [
          MeasurementEntry(
            id: 7706,
            category: 8803,
            date: now.subtract(const Duration(days: 30)),
            value: 104.0,
            notes: 'Baseline measurement.',
          ),
          MeasurementEntry(
            id: 7707,
            category: 8803,
            date: now,
            value: 106.5,
            notes: 'Hypertrophy progress visible.',
          ),
        ],
      ),

      //  Blood Pressure
      MeasurementCategory(
        id: 8804,
        name: 'Systolic Blood Pressure (Mock)',
        unit: 'mmHg',
        groupId: 9902,
        formula: 'NONE',
        entries: [
          MeasurementEntry(
            id: 7708,
            category: 8804,
            date: now.subtract(const Duration(days: 3)),
            value: 120.0,
            notes: 'Normal home rest conditions.',
          ),
        ],
      ),
    ];
  }
}
