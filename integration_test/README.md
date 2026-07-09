This will generate some screenshots and save them to the Play Store metadata folder.

1) Start the correct emulator/simulator for the device size you want.
2) Run, selecting the device size via `--dart-define=DEVICE_TYPE`:
   ```
   flutter drive \
       --driver=test_driver/screenshot_driver.dart \
       --target=integration_test/make_screenshots_test.dart \
       --dart-define=DEVICE_TYPE=androidPhone
   ```
   For the available device types, consult the `DeviceType` enum in
   `make_screenshots_test.dart`.
3) If you get errors or the screenshots are not written to disk, edit the
   `languages` list and comment some of the languages out.

See also

* <https://github.com/openfoodfacts/smooth-app/issues/217#issuecomment-1092678779>
* <https://dev.to/mjablecnik/take-screenshot-during-flutter-integration-tests-435k>
