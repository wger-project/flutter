This will generate some screenshots and save them to the Play Store metadata folder.

1) Set the correct value for the device size by setting the `destination` variable
2) Start the correct emulator and
   run
   ```
   flutter drive \
       --driver=test_driver/screenshot_driver.dart \
       --target=integration_test/make_screenshots_test.dart \
       --dart-define=DEVICE_TYPE=androidPhone
   ```
   For the values of device type, consult the values of the DeviceType enum in
   `make_screenshots_test.dart`
5) flutter drive --driver=test_driver/screenshot_driver.dart --target=integration_test/make_screenshots_test.dart --dart-define=DEVICE_TYPE=androidPhone`
3) If you get errors or the screenshots are not written to disk, edit the
   `languages` list and comment some of the languages

See also

* <https://github.com/openfoodfacts/smooth-app/issues/217#issuecomment-1092678779>
* <https://dev.to/mjablecnik/take-screenshot-during-flutter-integration-tests-435k>
