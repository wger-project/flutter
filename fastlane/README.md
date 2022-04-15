fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

### playstore

```sh
[bundle exec] fastlane playstore
```



----


## Android

### android test_configuration

```sh
[bundle exec] fastlane android test_configuration
```

Check playstore configuration, does not upload any files

### android production

```sh
[bundle exec] fastlane android production
```

Upload app to production

### android update_alpha

```sh
[bundle exec] fastlane android update_alpha
```

Upload closed alpha app and update store entry

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
