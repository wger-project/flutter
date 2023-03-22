// ignore_for_file: avoid_classes_with_only_static_members, avoid_print

import 'dart:convert';
import 'dart:io';

void main(List<String> arguments) {
  if (arguments.length != 1) {
    throw Exception('Must have only one argument: the path to the JSON specification.');
  }
  if (!Platform.isLinux) {
    throw Exception('Must be run under x86_64 Linux');
  }
  final jsonFile = File(arguments[0]);
  if (!jsonFile.existsSync()) {
    throw Exception('The provided JSON file does not exist.');
  }
  final specJson = SpecJson.fromJson(jsonFile);

  final outputDir = Directory.current;

  final packageGenerator = PackageGenerator(inputDir: jsonFile.parent, specJson: specJson);
  packageGenerator.generatePackage(Directory.current, _Platform.x86_64);

  if (specJson.linuxArmReleaseBundleDirPath != null) {
    packageGenerator.generatePackage(Directory.current, _Platform.aarch64);
  }

  final sha256x64 = packageGenerator.sha256x64;

  if (sha256x64 == null) {
    throw Exception('Could not generate SHA256 for the created package');
  }

  final sha256aarch64 = packageGenerator.sha256aarch64;

  final manifestContent =
      FlatpakManifestGenerator(specJson).getFlatpakManifest(sha256x64, sha256aarch64);
  final manifestPath = '${outputDir.path}/${specJson.appId}.json';
  final manifestFile = File(manifestPath);
  manifestFile.writeAsStringSync(manifestContent);
  print('Generated $manifestPath');

  if (specJson.linuxArmReleaseBundleDirPath == null) {
    final flathubJsonPath = '${outputDir.path}/${FlathubJsonGenerator.filename}';
    final flathubJsonFile = File(flathubJsonPath);
    flathubJsonFile.writeAsStringSync(FlathubJsonGenerator.generate());
    print('Generated $flathubJsonPath');
  }
}

enum _Platform { x86_64, aarch64 }

class PackageGenerator {
  final Directory inputDir;
  final SpecJson specJson;
  String? sha256x64;
  String? sha256aarch64;

  PackageGenerator({required this.inputDir, required this.specJson});

  void generatePackage(Directory outputDir, _Platform platform) {
    final tempDir = outputDir.createTempSync('flutter_package_generator');
    final appId = specJson.appId;

    // desktop file
    final desktopFile = File('${inputDir.path}/${specJson.desktopPath}');

    if (!desktopFile.existsSync()) {
      throw Exception(
          'The desktop file does not exist under the specified path: ${desktopFile.path}');
    }

    desktopFile.copySync(
        '${tempDir.path}/$appId.desktop'); //todo does "$appName" have to be in the path too?

    // icons
    final iconTempDir = Directory('${tempDir.path}/icons');

    for (final icon in specJson.icons) {
      final iconFile = File('${inputDir.path}/${icon.path}');
      if (!iconFile.existsSync()) {
        throw Exception('The icon file ${iconFile.path} does not exist.');
      }
      final iconSubdir = Directory('${iconTempDir.path}/${icon.type}');
      iconSubdir.createSync(recursive: true);
      iconFile.copySync('${iconSubdir.path}/$appId.${icon.fileExtension}');
    }

    // appdata file
    final origAppDataFile = File('${inputDir.path}/${specJson.appDataPath}');
    if (!origAppDataFile.existsSync()) {
      throw Exception(
          'The app data file does not exist under the specified path: ${origAppDataFile.path}');
    }

    final editedAppDataContent =
        AppDataModifier.replaceVersions(origAppDataFile.readAsStringSync(), specJson.releases);

    final editedAppDataFile = File('${tempDir.path}/$appId.appdata.xml');
    editedAppDataFile.writeAsStringSync(editedAppDataContent);

    // build files
    final bundlePath = platform == _Platform.aarch64
        ? specJson.linuxArmReleaseBundleDirPath
        : specJson.linuxReleaseBundleDirPath;
    final buildDir = Directory(bundlePath!);
    if (!buildDir.existsSync()) {
      throw Exception(
          'The linux build directory does not exist under the specified path: ${buildDir.path}');
    }
    final destDir = Directory('${tempDir.path}/bin');
    destDir.createSync();

    final platformSuffix = platform == _Platform.aarch64 ? 'aarch64' : 'x86_64';
    final packagePath =
        '${outputDir.absolute.path}/${specJson.lowercaseAppName}-linux-$platformSuffix.tar.gz';

    Process.runSync('cp', [
      '-r',
      '${buildDir.absolute.path}/.',
      destDir.absolute.path
    ]); //todo test with spaces in name
    Process.runSync('tar', ['-czvf', packagePath, '.'],
        workingDirectory: tempDir.absolute.path); //todo test with spaces in name

    print('Generated $packagePath');

    final preShasum = Process.runSync('shasum', ['-a', '256', packagePath]);

    if (platform == _Platform.aarch64) {
      sha256aarch64 = preShasum.stdout.toString().split(' ').first;
    } else {
      sha256x64 = preShasum.stdout.toString().split(' ').first;
    }

    tempDir.deleteSync(recursive: true);
  }
}

// updates releases in ${appName}.appdata.xml
class AppDataModifier {
  static String replaceVersions(String origAppDataContent, List<Release> versions) {
    final joinedReleases =
        versions.map((v) => '<release version="${v.version}" date="${v.date}">').join('\n');
    final releasesSection = '<releases>\n$joinedReleases\n</releases>';
    if (origAppDataContent.contains('<releases')) {
      return origAppDataContent.replaceFirst(
          RegExp('<releases.*</releases>', multiLine: true), releasesSection);
    } else {
      return origAppDataContent.replaceFirst('</component>', '$releasesSection\n</component>');
    }
  }
}

// ${appId}.json
class FlatpakManifestGenerator {
  final SpecJson specJson;

  FlatpakManifestGenerator(this.specJson);

  String getFlatpakManifest(String sha256x64, String? sha256aarch64) {
    final appName = specJson.lowercaseAppName;
    final appId = specJson.appId;
    const encoder = JsonEncoder.withIndent('     ');
    return encoder.convert({
      'app-id': appId,
      'runtime': 'org.freedesktop.Platform',
      'runtime-version': specJson.runtimeVersion,
      'sdk': 'org.freedesktop.Sdk',
      'command': appName,
      'separate-locales': false,
      'finish-args': specJson.finishArgs,
      'modules': [
        ...specJson.extraModules ?? [],
        {
          'name': appName,
          'buildsystem': 'simple',
          'build-commands': [
            'cp -R $appName/bin/ /app/$appName',
            'chmod +x /app/$appName/$appName',
            'mkdir /app/bin/',
            'mkdir /app/lib/',
            'ln -s /app/$appName/$appName /app/bin/$appName',
            ...specJson.flatpakCommandsAfterUnpack ?? [],
            ...specJson.icons.map((icon) =>
                'install -Dm644 $appName/icons/${icon.type}/$appId.${icon.fileExtension} /app/share/icons/hicolor/${icon.type}/apps/$appId.${icon.fileExtension}'), //TODO THIS DOES NOT ACCOUNT FOR THE symbolic icon name!!!
            'install -Dm644 $appName/$appId.desktop /app/share/applications/$appId.desktop',
            'install -Dm644 $appName/$appId.appdata.xml /app/share/applications/$appId.appdata.xml'
          ],
          'sources': [
            {
              'type': 'archive',
              'only-arches': ['x86_64'],
              'url':
                  'https://github.com/${specJson.githubReleaseOrganization}/${specJson.githubReleaseProject}/releases/download/${specJson.releases.first.version}/${specJson.lowercaseAppName}-linux-x86_64.tar.gz',
              'sha256': sha256x64,
              'dest': specJson.lowercaseAppName
            },
            if (specJson.linuxArmReleaseBundleDirPath != null)
              {
                'type': 'archive',
                'only-arches': ['aarch64'],
                'url':
                    'https://github.com/${specJson.githubReleaseOrganization}/${specJson.githubReleaseProject}/releases/download/${specJson.releases.first.version}/${specJson.lowercaseAppName}-linux-aarch64.tar.gz',
                'sha256': sha256aarch64,
                'dest': specJson.lowercaseAppName
              }
          ]
        }
      ]
    });
  }
}

// flathub.json
class FlathubJsonGenerator {
  static const String filename = 'flathub.json';

  static String generate() {
    const encoder = JsonEncoder.withIndent('     ');
    return encoder.convert({
      'only-arches': ['x86_64']
    });
  }
}

class Release {
  final String version;
  final String date;

  Release({required this.version, required this.date});
}

class Icon {
  final String type;
  final String path;
  late final String fileExtension;

  Icon({required this.type, required this.path}) {
    fileExtension = path.split('.').last;
  }
}

class SpecJson {
  //todo allow extra modules
  final String appId;
  final String lowercaseAppName;
  final List<Release> releases;
  final String runtimeVersion;
  final String linuxReleaseBundleDirPath;
  final String? linuxArmReleaseBundleDirPath;
  final String appDataPath;
  final String desktopPath;
  final List<Icon> icons;
  final List<String>? flatpakCommandsAfterUnpack;
  final List<dynamic>? extraModules;
  final List<String> finishArgs;
  final String githubReleaseOrganization;
  final String githubReleaseProject;

  SpecJson(
      {required this.appId,
      required this.lowercaseAppName,
      required this.releases,
      required this.runtimeVersion,
      required this.linuxReleaseBundleDirPath,
      this.linuxArmReleaseBundleDirPath,
      required this.appDataPath,
      required this.desktopPath,
      required this.icons,
      required this.flatpakCommandsAfterUnpack,
      this.extraModules,
      required this.finishArgs,
      required this.githubReleaseOrganization,
      required this.githubReleaseProject});

  static SpecJson fromJson(File jsonFile) {
    try {
      final json = jsonDecode(jsonFile.readAsStringSync());
      return SpecJson(
          appId: json['appId'],
          lowercaseAppName: json['lowercaseAppName'],
          releases: (json['releases'] as List).map((r) {
            final rMap = r as Map;
            return Release(version: rMap['version'], date: rMap['date']);
          }).toList(),
          runtimeVersion: json['runtimeVersion'],
          linuxReleaseBundleDirPath: json['linuxReleaseBundleDirPath'],
          appDataPath: json['appDataPath'],
          desktopPath: json['desktopPath'],
          icons: (json['icons'] as Map).entries.map((mapEntry) {
            return Icon(type: mapEntry.key as String, path: mapEntry.value as String);
          }).toList(),
          flatpakCommandsAfterUnpack:
              (json['buildCommandsAfterUnpack'] as List?)?.map((bc) => bc as String)?.toList(),
          linuxArmReleaseBundleDirPath: json['linuxArmReleaseBundleDirPath'] as String?,
          extraModules: json['extraModules'] as List?,
          finishArgs: (json['finishArgs'] as List).map((fa) => fa as String).toList(),
          githubReleaseOrganization: json['githubReleaseOrganization'],
          githubReleaseProject: json['githubReleaseProject']);
    } catch (e) {
      throw Exception('Could not parse JSON file, due to this error:\n$e');
    }
  }
}
