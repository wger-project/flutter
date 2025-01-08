import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'dashboard_widget.dart';
import 'gym_mode_widget.dart';
import 'measurements_widget.dart';
import 'nutritional_plan_widget.dart';
import 'weight_widget.dart';
import 'workout_widget.dart';

// Type of device
enum DeviceType {
  phoneScreenshots,
  sevenInchScreenshots,
  tenInchScreenshots,
  tvScreenshots,
  wearScreenshots
}

final destination = DeviceType.tenInchScreenshots.name;

Future<void> takeScreenshot(
    tester, binding, String language, String name) async {
  if (Platform.isAndroid) {
    await tester.pumpAndSettle();
    await binding.convertFlutterSurfaceToImage();
    await tester.pumpAndSettle();
  }
  final filename =
      'fastlane/metadata/android/$language/images/$destination/$name.png';
  await binding.takeScreenshot(filename);
}

// Available languages in weblate for the fastlane/metadata/android folder (not necessarily
// those for which the application is translated)
const languages = [
  // Note: it seems if too many languages are processed at once, some processes
  // disappear and no images are written. Doing this in smaller steps works fine

  'ca',
  'cs-CZ',
  'de-DE',
  'el-GR',
  'en-US',
  'es-ES',

  'fr-FR',
  'hi-IN',
  'hr',
  'it-IT',
  'nb-NO',
  'pl-PL',

  'pt-BR',
  'pt-PT',
  'ru-RU',
  'tr-TR',
  'uk',
  'zh-CN',
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

      testWidgets('workout detail screen - $language',
          (WidgetTester tester) async {
        await tester
            .pumpWidget(createWorkoutDetailScreen(locale: languageCode));
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

      testWidgets('measurement screen - $language',
          (WidgetTester tester) async {
        await tester.pumpWidget(createMeasurementScreen(locale: languageCode));
        await takeScreenshot(tester, binding, language, '04 - measurements');
      });

      testWidgets('nutritional plan detail - $language',
          (WidgetTester tester) async {
        await tester
            .pumpWidget(createNutritionalPlanScreen(locale: languageCode));
        await tester.tap(find.byType(TextButton));
        await tester.pumpAndSettle();
        await takeScreenshot(
            tester, binding, language, '05 - nutritional plan');
      });

      testWidgets('body weight screen - $language',
          (WidgetTester tester) async {
        await tester.pumpWidget(createWeightScreen(locale: languageCode));
        await tester.pumpAndSettle();
        await takeScreenshot(tester, binding, language, '06 - weight');
      });
    }
  });
}
