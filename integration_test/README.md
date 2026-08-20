This will generate the store screenshots and save them to the fastlane metadata
folders.

The device types are the values of the `DeviceType` enum in
`make_screenshots_test.dart`. `DEVICE_TYPE` decides which folder the images are
written to, so it has to match the device you booted. An unknown value silently
falls back to `androidPhone`.

## 1. Create the emulator, once

Use the same profile the workflow uses, then nothing else needs setting up: the
resolution that comes out is the one the profile has.

| Device type           | Profile           | Resolution |
|-----------------------|-------------------|------------|
| `androidPhone`        | Pixel 10          | 1080x2424  |
| `androidTabletSmall`  | Small Tablet      | 1200x1920  |
| `androidTabletBig`    | Pixel Tablet      | 1600x2560  |
| `iOSPhoneBig`         | iPhone 17 Pro Max | 1320x2868  |
| `iOSTabletBig`        | iPad Pro 13-inch  | 2064x2752  |

For Android either pick the profile in Android Studio under Device Manager, or
on the command line. Pixel 10 and Small Tablet need reasonably current SDK
command line tools; the ones on the CI runner are too old for them, which is why
the workflow installs its own before creating the AVD.

For the Apple device types just install the matching simulator in Xcode.

## 2. Pick the languages

The `languages` list in `make_screenshots_test.dart` decides what gets written.
Comment out everything but the language you are working on while trying things
out, and put the list back for a real run.

## 3. Boot one device and run the driver

Start the emulator or simulator for the device type you want, then:

```bash
flutter drive \
    --driver=test_driver/screenshot_driver.dart \
    --target=integration_test/make_screenshots_test.dart \
    --dart-define=DEVICE_TYPE=androidPhone
```

Add `-d <device id>` if more than one device is attached, `flutter devices`
lists them. The images land in `fastlane/metadata/`, `git status` shows what
changed.

## In CI

The `Update screenshots` workflow does all of this for every device type and,
when asked for, commits the result to a dated branch. It creates its own AVDs,
so the setup above is only needed locally.

## Troubleshooting

If you get errors or the screenshots are not written to disk, comment out some
of the languages. It seems if too many are processed at once, sometimes the
process disappears and no images are written. Doing this in smaller steps works
fine.

See also

* <https://github.com/openfoodfacts/smooth-app/issues/217#issuecomment-1092678779>
* <https://dev.to/mjablecnik/take-screenshot-during-flutter-integration-tests-435k>
