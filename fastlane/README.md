fastlane documentation
================
# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```
xcode-select --install
```

Install _fastlane_ using
```
[sudo] gem install fastlane -NV
```
or alternatively using `brew install fastlane`

# Available Actions
### playstore
```
fastlane playstore
```


----

## Android
### android test_configuration
```
fastlane android test_configuration
```
Check configuration
### android production
```
fastlane android production
```
Upload app to production
### android update_alpha
```
fastlane android update_alpha
```
Upload closed alpha app and update store entry

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.
More information about fastlane can be found on [fastlane.tools](https://fastlane.tools).
The documentation of fastlane can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
