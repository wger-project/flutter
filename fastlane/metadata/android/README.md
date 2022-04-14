# Dry-run release before uploading

* Increase build nr in pubspec.yaml
* `flutter build appbundle --release`
* `bundle exec fastlane android test_configuration` (needs the different keys available)

It might be necessary to repeat these steps if upload_to_play_store returns any errors
such as a missing title or similar.

# Accepted language codes

https://support.google.com/googleplay/android-developer/answer/9844778?hl=en#zippy=%2Cview-list-of-available-languages

# Push tags to trigger release

Set the vX.Y.Z tag here, push it and delete it, since it gets re-created by github actions
to just X.Y.Z

`TAG=vX.Y.Z && git tag $TAG && git push origin $TAG && git tag -d $TAG`