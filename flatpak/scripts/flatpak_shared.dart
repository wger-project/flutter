import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

class Release {
  final String version;
  final String date; //todo add resources

  Release({required this.version, required this.date});
}

enum CPUArchitecture {
  x86_64('x86_64', 'x64'),
  aarch64('aarch64', 'aarch64');

  final String flatpakArchCode;
  final String flutterDirName;

  const CPUArchitecture(this.flatpakArchCode, this.flutterDirName);
}

class ReleaseAsset {
  final CPUArchitecture arch;
  final String tarballUrlOrPath;
  final bool isRelativeLocalPath;
  final String tarballSha256;

  ReleaseAsset(
      {required this.arch,
      required this.tarballUrlOrPath,
      required this.isRelativeLocalPath,
      required this.tarballSha256});
}

class Icon {
  static const _symbolicType = 'symbolic';
  final String type;
  final String path;
  late final String _fileExtension;

  Icon({required this.type, required this.path}) {
    _fileExtension = path.split('.').last;
  }

  String getFilename(String appId) =>
      (type == _symbolicType) ? '$appId-symbolic.$_fileExtension' : '$appId.$_fileExtension';
}

class GithubReleases {
  final String githubReleaseOrganization;
  final String githubReleaseProject;
  List<Release>? _releases;
  List<ReleaseAsset>? _latestReleaseAssets;

  GithubReleases(this.githubReleaseOrganization, this.githubReleaseProject) {}

  Future<List<Release>> getReleases() async {
    if (_releases == null) {
      await _fetchReleasesAndAssets();
    }
    return _releases!;
  }

  Future<List<ReleaseAsset>?> getLatestReleaseAssets() async {
    if (_releases == null) {
      await _fetchReleasesAndAssets();
    }
    return _latestReleaseAssets;
  }

  Future<void> _fetchReleasesAndAssets() async {
    final releaseJsonContent = (await http.get(Uri(
            scheme: 'https',
            host: 'api.github.com',
            path: '/repos/$githubReleaseOrganization/$githubReleaseProject/releases')))
        .body;
    final decodedJson = jsonDecode(releaseJsonContent) as List;

    DateTime? latestReleaseAssetDate = null;

    final releases = List<Release>.empty(growable: true);

    await Future.forEach<dynamic>(decodedJson, (dynamic releaseDynamic) async {
      final releaseMap = releaseDynamic as Map;

      final releaseDateAndTime = DateTime.parse((releaseMap['published_at'] as String));
      final releaseDateString = releaseDateAndTime.toIso8601String().split('T').first;

      if (latestReleaseAssetDate == null ||
          (latestReleaseAssetDate?.compareTo(releaseDateAndTime) == -1)) {
        final assets = await _parseReleaseAssets(releaseMap['assets'] as List);
        if (assets != null) {
          _latestReleaseAssets = assets;
          latestReleaseAssetDate = releaseDateAndTime;
        }
      }

      releases.add(Release(version: releaseMap['name'] as String, date: releaseDateString));
    });

    if (releases.isNotEmpty) {
      _releases = releases;
    }
  }

  Future<List<ReleaseAsset>?> _parseReleaseAssets(List assetMaps) async {
    String? x64TarballUrl;
    String? x64Sha;
    String? aarch64TarballUrl;
    String? aarch64Sha;
    for (final am in assetMaps) {
      final amMap = am as Map;

      final downloadUrl = amMap['browser_download_url'] as String;
      final filename = amMap['name'] as String;
      final fileExtension = filename.substring(filename.indexOf('.') + 1);
      final filenameWithoutExtension = filename.substring(0, filename.indexOf('.'));

      final arch = filenameWithoutExtension.endsWith('aarch64')
          ? CPUArchitecture.aarch64
          : CPUArchitecture.x86_64;

      switch (fileExtension) {
        case 'sha256':
          if (arch == CPUArchitecture.aarch64) {
            aarch64Sha = await _readSha(downloadUrl);
          } else {
            x64Sha = await _readSha(downloadUrl);
          }
          break;
        case 'tar':
        case 'tar.gz':
        case 'tgz':
        case 'tar.xz':
        case 'txz':
        case 'tar.bz2':
        case 'tbz2':
        case 'zip':
        case '7z':
          if (arch == CPUArchitecture.aarch64) {
            aarch64TarballUrl = downloadUrl;
          } else {
            x64TarballUrl = downloadUrl;
          }
          break;
        default:
          break;
      }
    }
    final res = List<ReleaseAsset>.empty(growable: true);
    if (x64TarballUrl != null && x64Sha != null) {
      res.add(ReleaseAsset(
          arch: CPUArchitecture.x86_64,
          tarballUrlOrPath: x64TarballUrl,
          isRelativeLocalPath: false,
          tarballSha256: x64Sha));
    }
    if (aarch64TarballUrl != null && aarch64Sha != null) {
      res.add(ReleaseAsset(
          arch: CPUArchitecture.aarch64,
          tarballUrlOrPath: aarch64TarballUrl,
          isRelativeLocalPath: false,
          tarballSha256: aarch64Sha));
    }
    return res.isEmpty ? null : res;
  }

  Future<String> _readSha(String shaUrl) async {
    final urlSplitByScheme = shaUrl.split('://');
    final urlWithoutScheme = urlSplitByScheme.last;
    final firstSlashIndex = urlWithoutScheme.indexOf('/');
    return (await http.get(Uri(
            scheme: urlSplitByScheme.first,
            host: urlWithoutScheme.substring(0, firstSlashIndex),
            path: urlWithoutScheme.substring(firstSlashIndex))))
        .body
        .split(' ')
        .first;
  }
}

class FlatpakMeta {
  final String appId;
  final String lowercaseAppName;
  final String appDataPath;
  final String desktopPath;
  final List<Icon> icons;

  // Flatpak manifest releated properties
  final String freedesktopRuntime;
  final List<String>? buildCommandsAfterUnpack;
  final List<dynamic>? extraModules;
  final List<String> finishArgs;

  // Properties relevant only for local releases
  final List<Release>? _localReleases;
  final List<ReleaseAsset>? _localReleaseAssets;
  final String localLinuxBuildDir;

  // Properties relevant only for releases fetched from Github
  final String? githubReleaseOrganization;
  final String? githubReleaseProject;
  late final GithubReleases? _githubReleases;

  FlatpakMeta(
      {required this.appId,
      required this.lowercaseAppName,
      required this.githubReleaseOrganization,
      required this.githubReleaseProject,
      required List<Release>? localReleases,
      required List<ReleaseAsset>? localReleaseAssets,
      required this.localLinuxBuildDir,
      required this.appDataPath,
      required this.desktopPath,
      required this.icons,
      required this.freedesktopRuntime,
      required this.buildCommandsAfterUnpack,
      required this.extraModules,
      required this.finishArgs})
      : _localReleases = localReleases,
        _localReleaseAssets = localReleaseAssets {
    if (githubReleaseOrganization != null && githubReleaseProject != null) {
      _githubReleases = GithubReleases(githubReleaseOrganization!, githubReleaseProject!);
    }
  }

  Future<List<Release>> getReleases(bool fetchReleasesFromGithub) async {
    if (fetchReleasesFromGithub) {
      if (_githubReleases == null) {
        throw Exception(
            'Metadata must include Github repository info if fetching releases from Github.');
      }
      return await _githubReleases!.getReleases();
    } else {
      if (_localReleases == null) {
        throw Exception('Metadata must include releases if not fetching releases from Github.');
      }
      return _localReleases!;
    }
  }

  Future<List<ReleaseAsset>?> getReleaseAssets(bool fetchReleasesFromGithub) async {
    if (fetchReleasesFromGithub) {
      if (_githubReleases == null) {
        throw Exception(
            'Metadata must include Github repository info if fetching releases from Github.');
      }
      return await _githubReleases!.getLatestReleaseAssets();
    } else {
      if (_localReleases == null) {
        throw Exception('Metadata must include releases if not fetching releases from Github.');
      }
      return _localReleaseAssets;
    }
  }

  static FlatpakMeta fromJson(File jsonFile) {
    try {
      final dynamic json = jsonDecode(jsonFile.readAsStringSync());
      return FlatpakMeta(
          appId: json['appId'] as String,
          lowercaseAppName: json['lowercaseAppName'] as String,
          githubReleaseOrganization: json['githubReleaseOrganization'] as String?,
          githubReleaseProject: json['githubReleaseProject'] as String?,
          localReleases: (json['localReleases'] as List?)?.map((dynamic r) {
            final rMap = r as Map;
            return Release(version: rMap['version'] as String, date: rMap['date'] as String);
          }).toList(),
          localReleaseAssets: (json['localReleaseAssets'] as List?)?.map((dynamic ra) {
            final raMap = ra as Map;
            final archString = raMap['arch'] as String;
            final arch = (archString == CPUArchitecture.x86_64.flatpakArchCode)
                ? CPUArchitecture.x86_64
                : (archString == CPUArchitecture.aarch64.flatpakArchCode)
                    ? CPUArchitecture.aarch64
                    : null;
            if (arch == null) {
              throw Exception(
                  'Architecture must be either "${CPUArchitecture.x86_64.flatpakArchCode}" or "${CPUArchitecture.aarch64.flatpakArchCode}"');
            }
            final tarballPath = '${jsonFile.parent.path}/${raMap['tarballPath'] as String}';
            final preShasum = Process.runSync('shasum', ['-a', '256', tarballPath]);
            final shasum = preShasum.stdout.toString().split(' ').first;
            if (preShasum.exitCode != 0) {
              throw Exception(preShasum.stderr);
            }
            return ReleaseAsset(
                arch: arch,
                tarballUrlOrPath: tarballPath,
                isRelativeLocalPath: true,
                tarballSha256: shasum);
          }).toList(),
          localLinuxBuildDir: json['localLinuxBuildDir'] as String,
          appDataPath: json['appDataPath'] as String,
          desktopPath: json['desktopPath'] as String,
          icons: (json['icons'] as Map).entries.map((mapEntry) {
            return Icon(type: mapEntry.key as String, path: mapEntry.value as String);
          }).toList(),
          freedesktopRuntime: json['freedesktopRuntime'] as String,
          buildCommandsAfterUnpack: (json['buildCommandsAfterUnpack'] as List?)
              ?.map((dynamic bc) => bc as String)
              .toList(),
          extraModules: json['extraModules'] as List?,
          finishArgs: (json['finishArgs'] as List).map((dynamic fa) => fa as String).toList());
    } catch (e) {
      throw Exception('Could not parse JSON file, due to this error:\n$e');
    }
  }
}
