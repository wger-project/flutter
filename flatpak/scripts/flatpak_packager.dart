// ignore_for_file: avoid_print

import 'dart:io';

import 'flatpak_shared.dart';

/// arguments:
/// --meta [file]
/// --github
void main(List<String> arguments) async {
  if (Platform.isWindows) {
    throw Exception('Must be run under a UNIX-like operating system.');
  }

  final metaIndex = arguments.indexOf('--meta');
  if (metaIndex == -1) {
    throw Exception(
        'You must run this script with a metadata file argument, using the --meta flag.');
  }
  if (arguments.length == metaIndex + 1) {
    throw Exception('The --meta flag must be followed by the path to the metadata file.');
  }

  final metaFile = File(arguments[metaIndex + 1]);
  if (!metaFile.existsSync()) {
    throw Exception('The provided metadata file does not exist.');
  }

  final meta = FlatpakMeta.fromJson(metaFile);

  final fetchFromGithub = arguments.contains('--github');

  final outputDir = Directory('${Directory.current.path}/flatpak_generator_exports');
  outputDir.createSync();

  final packageGenerator = PackageGenerator(inputDir: metaFile.parent, meta: meta);

  packageGenerator.generatePackage(
    outputDir,
    PackageGenerator.runningOnARM() ? CPUArchitecture.aarch64 : CPUArchitecture.x86_64,
    fetchFromGithub,
  );
}

class PackageGenerator {
  final Directory inputDir;
  final FlatpakMeta meta;
  final Map<CPUArchitecture, String> shaByArch = {};

  PackageGenerator({required this.inputDir, required this.meta});

  Future<void> generatePackage(
      Directory outputDir, CPUArchitecture arch, bool fetchReleasesFromGithub) async {
    final tempDir = outputDir.createTempSync('flutter_generator_temp');
    final appId = meta.appId;

    // desktop file
    final desktopFile = File('${inputDir.path}/${meta.desktopPath}');

    if (!desktopFile.existsSync()) {
      throw Exception(
          'The desktop file does not exist under the specified path: ${desktopFile.path}');
    }

    desktopFile.copySync('${tempDir.path}/$appId.desktop');

    // icons
    final iconTempDir = Directory('${tempDir.path}/icons');

    for (final icon in meta.icons) {
      final iconFile = File('${inputDir.path}/${icon.path}');
      if (!iconFile.existsSync()) {
        throw Exception('The icon file ${iconFile.path} does not exist.');
      }
      final iconSubdir = Directory('${iconTempDir.path}/${icon.type}');
      iconSubdir.createSync(recursive: true);
      iconFile.copySync('${iconSubdir.path}/${icon.getFilename(appId)}');
    }

    // appdata file
    final origAppDataFile = File('${inputDir.path}/${meta.appDataPath}');
    if (!origAppDataFile.existsSync()) {
      throw Exception(
          'The app data file does not exist under the specified path: ${origAppDataFile.path}');
    }

    final editedAppDataContent = AppDataModifier.replaceVersions(
        origAppDataFile.readAsStringSync(), await meta.getReleases(fetchReleasesFromGithub));

    final editedAppDataFile = File('${tempDir.path}/$appId.appdata.xml');
    editedAppDataFile.writeAsStringSync(editedAppDataContent);

    // build files
    final bundlePath =
        '${inputDir.path}/${meta.localLinuxBuildDir}/${arch.flutterDirName}/release/bundle';
    final buildDir = Directory(bundlePath);
    if (!buildDir.existsSync()) {
      throw Exception(
          'The linux build directory does not exist under the specified path: ${buildDir.path}');
    }
    final destDir = Directory('${tempDir.path}/bin');
    destDir.createSync();

    final baseFileName = '${meta.lowercaseAppName}-linux-${arch.flatpakArchCode}';

    final packagePath = '${outputDir.absolute.path}/$baseFileName.tar.gz';
    Process.runSync('cp', ['-r', '${buildDir.absolute.path}/.', destDir.absolute.path]);
    Process.runSync('tar', ['-czvf', packagePath, '.'], workingDirectory: tempDir.absolute.path);
    print('Generated $packagePath');

    final preShasum = Process.runSync('shasum', ['-a', '256', packagePath]);
    final sha256 = preShasum.stdout.toString().split(' ').first;

    final shaFile = await File('${outputDir.path}/$baseFileName.sha256').writeAsString(sha256);
    print('Generated ${shaFile.path}');

    shaByArch.putIfAbsent(arch, () => sha256);

    final localReleaseAssetsFile = await File('${outputDir.path}/local_release_assets.json')
      .writeAsString('[{"arch": "${arch.flatpakArchCode}", "tarballPath": "$packagePath"}]');
    print('Generated ${localReleaseAssetsFile.path}');

    tempDir.deleteSync(recursive: true);
  }

  static bool runningOnARM() {
    final unameRes = Process.runSync('uname', ['-m']);
    final unameString = unameRes.stdout.toString().trimLeft();
    return unameString.startsWith('arm') || unameString.startsWith('aarch');
  }
}

// updates releases in ${appName}.appdata.xml
class AppDataModifier {
  static String replaceVersions(String origAppDataContent, List<Release> versions) {
    final joinedReleases =
        versions.map((v) => '\t\t<release version="${v.version}" date="${v.date}" />').join('\n');
    final releasesSection = '<releases>\n$joinedReleases\n\t</releases>'; //todo check this
    if (origAppDataContent.contains('<releases')) {
      return origAppDataContent
          .replaceAll('\n', '<~>')
          .replaceFirst(RegExp('<releases.*</releases>'), releasesSection)
          .replaceAll('<~>', '\n');
    } else {
      return origAppDataContent.replaceFirst('</component>', '\n\t$releasesSection\n</component>');
    }
  }
}
