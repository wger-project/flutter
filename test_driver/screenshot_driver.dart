import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:integration_test/integration_test_driver_extended.dart';

// cf. https://dev.to/mjablecnik/take-screenshot-during-flutter-integration-tests-435k
Future<void> main() async {
  try {
    await integrationDriver(
      onScreenshot: (String screenshotName, List<int> screenshotBytes,
          [_]) async {
        final File image = await File(screenshotName).create(recursive: true);
        image.writeAsBytesSync(screenshotBytes);
        return true;
      },
    );
  } catch (e) {
    if (kDebugMode) {
      print('An error occurred: $e');
    }
  }
}
