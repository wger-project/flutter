fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

## iOS

### ios apikey

```sh
[bundle exec] fastlane ios apikey
```

Set AppStore Connect API KEY using the provided environment variables.

### ios release

```sh
[bundle exec] fastlane ios release
```

Push a new release build to AppStore Connect for manual submission to TestFlight beta testing or App Store Release.

### ios test_env

```sh
[bundle exec] fastlane ios test_env
```

Test if all environment variables are present and check if API key is working properly.

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
