// ignore_for_file: avoid_print

import 'dart:io';
import 'flatpak_shared.dart';

/// Creates an archive containing all the sources for the Flatpak package for a
/// specific architecture.
///
/// arguments:
/// --meta [file]
///   Required argument for providing the metadata file for this script.

/// --github
///   Use this option to pull release info from Github rather than the metadata file.

/// --addTodaysVersion [version]
///   If pulling data from Github, this provides a way to specify the release to be released today.

void main(List<String> arguments) async {
  if (!Platform.isLinux) {
    throw Exception('Must be run under Linux');
  }

  // PARSE ARGUMENTS
  final metaIndex = arguments.indexOf('--meta');
  if (metaIndex == -1) {
    throw Exception(
        'You must run this script with a metadata file argument, using the --meta flag.');
  }
  if (arguments.length == metaIndex + 1) {
    throw Exception('The --meta flag must be followed by the path to the metadata file.');
  }

  final metaFile = File(arguments[metaIndex + 1]);
  if (!(await metaFile.exists())) {
    throw Exception('The provided metadata file does not exist.');
  }

  final fetchFromGithub = arguments.contains('--github');

  final addTodaysVersionIndex = arguments.indexOf('--addTodaysVersion');
  if (addTodaysVersionIndex != -1 && arguments.length == addTodaysVersionIndex + 1) {
    throw Exception('The --addTodaysVersion flag must be followed by the version name.');
  }

  final addedTodaysVersion =
      addTodaysVersionIndex != -1 ? arguments[addTodaysVersionIndex + 1] : null;

  // GENERATE PACKAGE

  final meta = FlatpakMeta.fromJson(metaFile, skipLocalReleases: fetchFromGithub);

  final outputDir = Directory('${Directory.current.path}/flatpak_generator_exports');
  await outputDir.create();

  final packageGenerator = PackageGenerator(
      inputDir: metaFile.parent, meta: meta, addedTodaysVersion: addedTodaysVersion);

  await packageGenerator.generatePackage(
      outputDir,
      await PackageGenerator.runningOnARM() ? CPUArchitecture.aarch64 : CPUArchitecture.x86_64,
      fetchFromGithub);
}

class PackageGenerator {
  final Directory inputDir;
  final FlatpakMeta meta;
  final String? addedTodaysVersion;

  PackageGenerator({required this.inputDir, required this.meta, required this.addedTodaysVersion});

  Future<void> generatePackage(
      Directory outputDir, CPUArchitecture arch, bool fetchReleasesFromGithub) async {
    final tempDir = await outputDir.createTemp('flutter_generator_temp');
    final appId = meta.appId;

    // desktop file
    final desktopFile = File('${inputDir.path}/${meta.desktopPath}');

    if (!(await desktopFile.exists())) {
      throw Exception(
          'The desktop file does not exist under the specified path: ${desktopFile.path}');
    }

    await desktopFile.copy('${tempDir.path}/$appId.desktop');

    // icons
    final iconTempDir = Directory('${tempDir.path}/icons');

    for (final icon in meta.icons) {
      final iconFile = File('${inputDir.path}/${icon.path}');
      if (!(await iconFile.exists())) {
        throw Exception('The icon file ${iconFile.path} does not exist.');
      }
      final iconSubdir = Directory('${iconTempDir.path}/${icon.type}');
      await iconSubdir.create(recursive: true);
      await iconFile.copy('${iconSubdir.path}/${icon.getFilename(appId)}');
    }

    // AppStream metainfo file
    final origAppStreamFile = File('${inputDir.path}/${meta.appStreamPath}');
    if (!(await origAppStreamFile.exists())) {
      throw Exception(
          'The app data file does not exist under the specified path: ${origAppStreamFile.path}');
    }

    final editedAppStreamContent = AppStreamModifier.replaceVersions(
        await origAppStreamFile.readAsString(),
        await meta.getReleases(fetchReleasesFromGithub, addedTodaysVersion));

    final editedAppStreamFile = File('${tempDir.path}/$appId.metainfo.xml');
    await editedAppStreamFile.writeAsString(editedAppStreamContent);

    // build files
    final bundlePath =
        '${inputDir.path}/${meta.localLinuxBuildDir}/${arch.flutterDirName}/release/bundle';
    final buildDir = Directory(bundlePath);
    if (!(await buildDir.exists())) {
      throw Exception(
          'The linux build directory does not exist under the specified path: ${buildDir.path}');
    }
    final destDir = Directory('${tempDir.path}/bin');
    await destDir.create();

    final baseFilename = '${meta.lowercaseAppName}-linux-${arch.flatpakArchCode}';
    final packagePath = '${outputDir.absolute.path}/$baseFilename.tar.gz';
    final shaPath = '${outputDir.absolute.path}/$baseFilename.sha256';

    await Process.run('cp', ['-r', '${buildDir.absolute.path}/.', destDir.absolute.path]);
    await Process.run('tar', ['-czvf', packagePath, '.'], workingDirectory: tempDir.absolute.path);

    print('Generated $packagePath');

    final preShasum = await Process.run('shasum', ['-a', '256', packagePath]);
    final shasum = preShasum.stdout.toString().split(' ').first;

    await File(shaPath).writeAsString(shasum);

    print('Generated $shaPath');

    await tempDir.delete(recursive: true);
  }

  static Future<bool> runningOnARM() async {
    final unameRes = await Process.run('uname', ['-m']);
    final unameString = unameRes.stdout.toString().trimLeft();
    return unameString.startsWith('arm') || unameString.startsWith('aarch');
  }
}

// updates releases in ${appName}.metainfo.xml
class AppStreamModifier {
  static String replaceVersions(String origAppStreamContent, List<Release> versions) {
    final joinedReleases =
        versions.map((v) => '\t\t<release version="${v.version}" date="${v.date}" />').join('\n');
    final releasesSection = '<releases>\n$joinedReleases\n\t</releases>'; //TODO check this
    if (origAppStreamContent.contains('<releases')) {
      return origAppStreamContent
          .replaceAll('\n', '<~>')
          .replaceFirst(RegExp('<releases.*</releases>'), releasesSection)
          .replaceAll('<~>', '\n');
    } else {
      return origAppStreamContent.replaceFirst(
          '</component>', '\n\t$releasesSection\n</component>');
    }
  }
}
