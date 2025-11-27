import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '1_dashboard.dart';
import '2_workout.dart';
import '3_gym_mode.dart';
import '4_measurements.dart';
import '5_nutritional_plan.dart';
import '6_weight.dart';

/// Type of device
///
/// For Apple: https://developer.apple.com/help/app-store-connect/reference/app-information/screenshot-specifications
enum DeviceType {
  androidPhone('phoneScreenshots'),
  androidTableSmall('7inchScreenshots'),
  androidTabletBig('10inchScreenshots'),
  androidTv('tvScreenshots'),
  androidWear('wearScreenshots'),

  iOSPhoneBig('iPhone 6.9', isAndroid: false),
  iOSPhoneSmall('iPhone 6.7', isAndroid: false);

  final String folderName;
  final bool isAndroid;

  const DeviceType(this.folderName, {this.isAndroid = true});

  String fastlanePath(String language, String name) {
    final os = isAndroid ? 'android' : 'ios';

    return 'fastlane/metadata/$os/$language/images/$folderName/$name.png';
  }
}

const _deviceArg = String.fromEnvironment('DEVICE_TYPE', defaultValue: 'androidPhone');

// Determine the destination device type based on the provided argument
final DeviceType destination = DeviceType.values.firstWhere(
  (d) => d.toString().split('.').last == _deviceArg || ((d.name ?? '') == _deviceArg),
  orElse: () {
    print('***** Unknown DEVICE_TYPE="$_deviceArg", defaulting to androidPhone *****');
    return DeviceType.androidPhone;
  },
);

Future<void> takeScreenshot(
  WidgetTester tester,
  IntegrationTestWidgetsFlutterBinding binding,
  String language,
  String name,
) async {
  if (Platform.isAndroid) {
    await tester.pumpAndSettle();
    await binding.convertFlutterSurfaceToImage();
    await tester.pumpAndSettle();
  }

  final filename = destination.fastlanePath(language, name);
  await binding.takeScreenshot(filename);
}

// Available languages in weblate for the fastlane/metadata/android folder (not necessarily
// those for which the application is translated)
const languages = [
  // Note: it seems if too many languages are processed at once, some processes
  // disappear and no images are written. Doing this in smaller steps works fine
  'de-DE',
];

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Generate screenshots', () {
    for (final language in languages) {
      final languageCode = language.split('-')[0];

      testWidgets('dashboard screen - $language', (WidgetTester tester) async {
        await tester.pumpWidget(createDashboardScreen(locale: languageCode));
        await takeScreenshot(tester, binding, language, '01 - dashboard');
      });

      testWidgets('workout detail screen - $language', (WidgetTester tester) async {
        await tester.pumpWidget(createWorkoutDetailScreen(locale: languageCode));
        await tester.tap(find.byType(TextButton));
        await tester.pumpAndSettle();
        await takeScreenshot(tester, binding, language, '02 - workout detail');
      });

      testWidgets('gym mode screen - $language', (WidgetTester tester) async {
        await tester.pumpWidget(createGymModeScreen(locale: languageCode));
        await tester.tap(find.byType(TextButton));
        await tester.pumpAndSettle();
        await takeScreenshot(tester, binding, language, '03 - gym mode');
      });

      testWidgets('measurement screen - $language', (WidgetTester tester) async {
        await tester.pumpWidget(createMeasurementScreen(locale: languageCode));
        await takeScreenshot(tester, binding, language, '04 - measurements');
      });

      testWidgets('nutritional plan detail - $language', (WidgetTester tester) async {
        await tester.pumpWidget(createNutritionalPlanScreen(locale: languageCode));
        await tester.tap(find.byType(TextButton));
        await tester.pumpAndSettle();
        await takeScreenshot(tester, binding, language, '05 - nutritional plan');
      });

      testWidgets('body weight screen - $language', (WidgetTester tester) async {
        await tester.pumpWidget(createWeightScreen(locale: languageCode));
        await tester.pumpAndSettle();
        await takeScreenshot(tester, binding, language, '06 - weight');
      });
    }
  });
}
