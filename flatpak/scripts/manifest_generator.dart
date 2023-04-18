import 'dart:convert';
import 'dart:io';

import 'flatpak_shared.dart';

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

  final manifestGenerator = FlatpakManifestGenerator(meta);
  final manifestContent = await manifestGenerator.generateFlatpakManifest(fetchFromGithub);
  final manifestPath = '${outputDir.path}/${meta.appId}.json';
  final manifestFile = File(manifestPath);
  manifestFile.writeAsStringSync(manifestContent);
  print('Generated $manifestPath');

  final flathubJsonContent = await manifestGenerator.generateFlathubJson(fetchFromGithub);
  if (flathubJsonContent != null) {
    final flathubJsonPath = '${outputDir.path}/flathub.json';
    final flathubJsonFile = File(flathubJsonPath);
    flathubJsonFile.writeAsStringSync(flathubJsonContent);
    print('Generated $flathubJsonPath');
  }
}

// ${appId}.json
class FlatpakManifestGenerator {
  final FlatpakMeta meta;
  Map<CPUArchitecture, bool>? _githubArchSupport;
  Map<CPUArchitecture, bool>? _localArchSupport;

  FlatpakManifestGenerator(this.meta);

  Future<String> generateFlatpakManifest(bool fetchFromGithub) async {
    final appName = meta.lowercaseAppName;
    final appId = meta.appId;
    final assets = await meta.getReleaseAssets(fetchFromGithub);

    if (assets == null) {
      throw Exception('There are no associated assets.');
    }

    _lazyGenerateArchSupportMap(fetchFromGithub, assets);

    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert({
      'app-id': appId,
      'runtime': 'org.freedesktop.Platform',
      'runtime-version': meta.freedesktopRuntime,
      'sdk': 'org.freedesktop.Sdk',
      'command': appName,
      'separate-locales': false,
      'finish-args': meta.finishArgs,
      'modules': <dynamic>[
        ...meta.extraModules ?? <dynamic>[],
        {
          'name': appName,
          'buildsystem': 'simple',
          'build-commands': <dynamic>[
            'cp -R $appName/bin/ /app/$appName',
            'chmod +x /app/$appName/$appName',
            'mkdir -p /app/bin/',
            'mkdir -p /app/lib/',
            'ln -s /app/$appName/$appName /app/bin/$appName',
            ...meta.buildCommandsAfterUnpack ?? [],
            ...meta.icons.map((icon) =>
                'install -Dm644 $appName/icons/${icon.type}/${icon.getFilename(appId)} /app/share/icons/hicolor/${icon.type}/apps/${icon.getFilename(appId)}'),
            'install -Dm644 $appName/$appId.desktop /app/share/applications/$appId.desktop',
            'install -Dm644 $appName/$appId.appdata.xml /app/share/applications/$appId.appdata.xml'
          ],
          'sources': assets
              .map((a) => {
                    'type': 'archive',
                    'only-arches': [a.arch.flatpakArchCode],
                    (fetchFromGithub ? 'url' : 'path'): a.tarballUrlOrPath,
                    'sha256': a.tarballSha256,
                    'dest': meta.lowercaseAppName
                  })
              .toList()
        }
      ]
    });
  }

  Future<String?> generateFlathubJson(bool fetchFromGithub) async {
    final assets = await meta.getReleaseAssets(fetchFromGithub);

    if (assets == null) {
      throw Exception('There are no associated assets.');
    }

    _lazyGenerateArchSupportMap(fetchFromGithub, assets);

    const encoder = JsonEncoder.withIndent('  ');

    final onlyArchListInput = fetchFromGithub ? _githubArchSupport! : _localArchSupport!;

    final onlyArchList = List<String>.empty(growable: true);
    for (final e in onlyArchListInput.entries) {
      if (e.value == true) {
        onlyArchList.add(e.key.flatpakArchCode);
      }
    }

    if (onlyArchList.length == CPUArchitecture.values.length) {
      return null;
    } else {
      return encoder.convert({'only-arches': onlyArchList});
    }
  }

  void _lazyGenerateArchSupportMap(bool fetchFromGithub, List<ReleaseAsset> assets) {
    if (fetchFromGithub) {
      if (_githubArchSupport == null) {
        _githubArchSupport = <CPUArchitecture, bool>{
          for (final arch in CPUArchitecture.values) arch: false
        };
        for (final a in assets) {
          _githubArchSupport![a.arch] = true;
        }
      }
    } else {
      if (_localArchSupport == null) {
        _localArchSupport = <CPUArchitecture, bool>{
          for (final arch in CPUArchitecture.values) arch: false
        };
        for (final a in assets) {
          _localArchSupport![a.arch] = true;
        }
      }
    }
  }
}
