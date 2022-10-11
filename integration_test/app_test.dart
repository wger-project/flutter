import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'gym_mode.dart';
import 'nutritional_plan.dart';
import 'weight.dart';

Future<void> takeScreenshot(tester, binding, String language, String name) async {
  if (Platform.isAndroid) {
    await binding.convertFlutterSurfaceToImage();
    await tester.pumpAndSettle();
  }
  await binding
      .takeScreenshot('fastlane/metadata/android/$language/images/phoneScreenshots/$name.png');
}

// Available languages in weblate for the android metadata
const languages = [
  'ca',
  'de-DE',
  'en-US',
  'es-ES',
  'fr-FR',
  'hi-IN',
  'hr',
  'it-IT',
  'pt-BR',
  'nb-NO',
  'pl-PL',
  'ru-RU',
  'tr-TR',
  'uk',
  'zh-CN'
];

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Generate screenshots', () {
    for (final language in languages) {
      final languageCode = language.split('-')[0];

      testWidgets('gym mode screen - $language', (WidgetTester tester) async {
        await tester.pumpWidget(createGymModeScreen(locale: languageCode));
        await tester.tap(find.byType(TextButton));
        await tester.pumpAndSettle();
        await takeScreenshot(tester, binding, language, '03 - gym mode');
      });

      testWidgets('nutritional plan detail - $language', (WidgetTester tester) async {
        await tester.pumpWidget(createNutritionalPlanScreen(locale: languageCode));
        await tester.tap(find.byType(TextButton));
        await tester.pumpAndSettle();
        await takeScreenshot(tester, binding, language, '04 - nutritional plan');
      });

      testWidgets('body weight screen - $language', (WidgetTester tester) async {
        await tester.pumpWidget(createWeightScreen(locale: languageCode));
        await tester.pumpAndSettle();
        await takeScreenshot(tester, binding, language, '05 - weight');
      });
    }
  });
}
