# Dry-run release before uploading


* Increase build nr in pubspec.yaml
* `flutter build appbundle --release`
* `bundle exec fastlane android test_configuration` (needs the different keys available)

It might be necessary to repeat these steps if upload_to_play_store returns any errors
such as a missing title or similar.



# Accepted language codes

https://support.google.com/googleplay/android-developer/answer/9844778?hl=en#zippy=%2Cview-list-of-available-languages