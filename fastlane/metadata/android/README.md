# Release process

## 1. Update flutter version

If we use a new version, update the version used by

* Github Actions in `android-release.yaml` in this repository
* Fdroid build recipe
  in [their repo](https://gitlab.com/fdroid/fdroiddata/-/blob/master/metadata/de.wger.flutter.yml).
  Since this can potentially take some time, it should happen well in advance

## 2. Dry-run release before uploading

* Increase build nr in pubspec.yaml (revert after the dry-run was successful)
* `flutter build appbundle --release`
* `bundle install`
* `bundle update fastlane`
* `bundle exec fastlane android test_configuration` (needs the different keys available)

It might be necessary to repeat these steps if upload_to_play_store returns any errors
such as a missing title or similar.

Also note that if a language was added over the weblate UI, it might be necessary
to set the correct language code:
<https://support.google.com/googleplay/android-developer/answer/9844778?hl=en#zippy=%2Cview-list-of-available-languages>

## 3. Push tags to trigger release

Make sure that the commit that will be tagged was already pushed or didn't change
any dart code, otherwise the automatic linter might push a "correction" commit
and the build step will fail.

Set the vX.Y.Z tag locally, push it and delete it. It will get recreated to X.Y.Z.
by github actions.

`TAG=vX.Y.Z && git tag $TAG && git push origin $TAG && git tag -d $TAG`

## 4. Edit release

If necessary, edit the created release on github

## 5. Merge pull requests

* in the flathub repo: https://github.com/flathub/de.wger.flutter
* in the flutter repo: https://github.com/wger-project/flutter/branches