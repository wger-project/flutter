# Prerequisites
## Setting up the flathub_meta.json file
The dart scripts here require a metadata file as input. This file is already prepared for this repository — see ../flatpak_meta.json.

## Publishing on Flathub
If uploading to Flathub for the first time, follow the official contributing guidelines: https://github.com/flathub/flathub/blob/master/CONTRIBUTING.md .

# Local builds

To run a local build:

1. Build the Linux release using Flutter.
2. Add the new release version and date to the start of the "releases" list in the "spec.json" file (and adjust other parameters in the file if needed).
3. Run "dart flatpak_packager.dart --meta ../flatpak_meta.json -n pubspec.yaml" in this folder.
4. Run "dart manifest_generator.dart --meta ../flatpak_meta.json -n pubspec.yaml" in this folder.
5. Test the Flatpak using the guide at https://docs.flatpak.org/en/latest/first-build.html, using the generated json manifest as your Flatpak manifest.

# Builds based on data fetched from Github

To generate and publish a release on Github:

1. Create a new release on Github using the app's version name for the tag (e.g. "1.0.0"), without any assets for now.
2. Build the Linux release using Flutter.
3. Run "dart flatpak_packager.dart --meta ../flatpak_meta.json --github -n pubspec.yaml" in this folder.
4. Upload the generated tar.gz file as a Github release.
5. Run "dart manifest_generator.dart --meta ../flatpak_meta.json --github -n pubspec.yaml" in this folder.
6. Upload your Flathub manifest file to your Flathub Github repo, overwriting any old manifest file you may have there. If you're building for only certain architectures and the "flathub.json" file is not in your Flathub Github repo yet, upload that too.

All of this can be automated via Github Actions.