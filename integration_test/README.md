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

## 2. Boot one device and run the driver

Start the emulator or simulator for the device type you want, then:

```bash
flutter drive \
    --driver=test_driver/screenshot_driver.dart \
    --target=integration_test/make_screenshots_test.dart \
    --dart-define=DEVICE_TYPE=androidPhone \
    --dart-define=LANGUAGES=de-DE
```

`LANGUAGES` takes a comma separated subset, or `2/5` for the second of five
equal blocks. Leave it out for all of them. Add `-d <device id>` if more than
one device is attached, `flutter devices` lists them. The images land in
`fastlane/metadata/`, `git status` shows what changed.

A run keeps every screenshot in memory on the device and hands the lot over to
the driver once the tests are through. Over all 25 languages that is upwards of
70MB of JSON, and when the app loses its VM service under it the run ends with
no images at all, so the workflow walks the list in blocks of five.

## In CI

The `Update screenshots` workflow does all of this for every device type and,
when asked for, commits the result to a dated branch. It creates its own AVDs,
so the setup above is only needed locally.

## Troubleshooting

If a run ends with `DriverError: ... Service has disappeared` and writes no
images, it lost the app before it could collect them. Fewer languages per run
makes that less likely, otherwise just run it again.

See also

* <https://github.com/openfoodfacts/smooth-app/issues/217#issuecomment-1092678779>
* <https://dev.to/mjablecnik/take-screenshot-during-flutter-integration-tests-435k>
