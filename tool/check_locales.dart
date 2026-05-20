/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (c)  2026 wger Team
 *
 * wger Workout Manager is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

library;

import 'dart:io';

import 'package:collection/collection.dart';
import 'package:wger/l10n/language_native_names.dart';
import 'package:xml/xml.dart';

const _listEq = ListEquality<String>();

const _arbDir = 'lib/l10n';
const _iosPlist = 'ios/Runner/Info.plist';
const _androidXml = 'android/app/src/main/res/xml/locales_config.xml';

/// Verifies that every place which enumerates the app's supported locales
/// agrees with the canonical list derived from `lib/l10n/app_*.arb` filenames.
///
/// Checks:
///   - `ios/Runner/Info.plist`
///   - `android/app/src/main/res/xml/locales_config.xml`
///   - `languageNativeNames` in `lib/l10n/language_native_names.dart`
///
/// Run `dart run tool/check_locales.dart` to check,
/// or `dart run tool/check_locales.dart --fix` to rewrite the iOS/Android lists
/// in place. The native-name map stays manual.
void main(List<String> args) {
  final fix = args.contains('--fix');

  final canonical = _readArbLocales();
  if (canonical.isEmpty) {
    stderr.writeln('No app_*.arb files found in $_arbDir');
    exit(2);
  }

  // Dash form for iOS/Android, underscore form for Dart.
  final dashForm = canonical.map((c) => c.replaceAll('_', '-')).toList()..sort();
  final underscoreForm = [...canonical]..sort();

  var drift = false;

  drift |= _checkPlist(dashForm, fix: fix);
  drift |= _checkAndroidXml(dashForm, fix: fix);
  drift |= _checkLanguageDartCoverage(underscoreForm);

  if (drift) {
    if (fix) {
      stdout.writeln('\nFixed drifted files. Re-run without --fix to verify.');
    } else {
      stderr.writeln('\nLocale lists are out of sync. Re-run with --fix to update.');
      exit(1);
    }
  } else {
    stdout.writeln('\nAll locale lists match (${canonical.length} locales).');
  }
}

/// Canonical locale list from `app_<tag>.arb` filenames. Returns tags in
/// underscore form (e.g. `pt_BR`, `zh_Hant`).
List<String> _readArbLocales() {
  final dir = Directory(_arbDir);
  if (!dir.existsSync()) {
    return const [];
  }
  final tags = <String>[];
  for (final entity in dir.listSync()) {
    if (entity is! File) {
      continue;
    }
    final name = entity.uri.pathSegments.last;
    final match = RegExp(r'^app_(.+)\.arb$').firstMatch(name);
    if (match != null) {
      tags.add(match.group(1)!);
    }
  }
  tags.sort();
  return tags;
}

bool _checkPlist(List<String> expectedDash, {required bool fix}) {
  final file = File(_iosPlist);
  if (!file.existsSync()) {
    stderr.writeln('[ios] $_iosPlist not found');
    return false;
  }
  final content = file.readAsStringSync();
  final doc = XmlDocument.parse(content);

  // Plist structure: <plist><dict><key>foo</key><value/>...</dict></plist>.
  // Find the <key>CFBundleLocalizations</key> and take its following sibling.
  final dict = doc.rootElement.findElements('dict').firstOrNull;
  final keyNode = dict
      ?.findElements('key')
      .firstWhereOrNull(
        (k) => k.innerText == 'CFBundleLocalizations',
      );
  final array = keyNode?.nextElementSibling;
  if (array == null || array.name.local != 'array') {
    stderr.writeln('[ios] CFBundleLocalizations <array> not found in $_iosPlist');
    return true;
  }

  final actual = array.findElements('string').map((e) => e.innerText).toList()..sort();

  if (_listEq.equals(actual, expectedDash)) {
    stdout.writeln('[ios] OK (${actual.length} locales)');
    return false;
  }

  _reportDiff('ios', actual, expectedDash);

  if (fix) {
    // Mutate only the <array>'s children
    array.children.clear();
    array.children.add(XmlText('\n\t\t\t'));
    for (final tag in expectedDash) {
      array.children.add(XmlElement(XmlName('string'), [], [XmlText(tag)]));
      array.children.add(XmlText('\n\t\t\t'));
    }
    // Trim the trailing inter-child indent and replace with the closing one.
    array.children.removeLast();
    array.children.add(XmlText('\n\t\t'));
    file.writeAsStringSync(doc.toXmlString());
    stdout.writeln('[ios] rewrote $_iosPlist');
  }
  return true;
}

bool _checkAndroidXml(List<String> expectedDash, {required bool fix}) {
  final file = File(_androidXml);
  if (!file.existsSync()) {
    stderr.writeln('[android] $_androidXml not found');
    return false;
  }
  final doc = XmlDocument.parse(file.readAsStringSync());

  final actual = doc.rootElement
      .findElements('locale')
      .map((e) => e.getAttribute('android:name')!)
      .toList();

  // Convention: `en` first (matches `preferred-supported-locales: [en]` in
  // l10n.yaml), then alphabetical.
  final expectedOrdered = _enFirst(expectedDash);

  if (_listEq.equals(actual, expectedOrdered)) {
    stdout.writeln('[android] OK (${actual.length} locales)');
    return false;
  }

  _reportDiff('android', actual..sort(), expectedOrdered.toList()..sort());

  if (fix) {
    final builder = XmlBuilder();
    builder.processing('xml', 'version="1.0" encoding="utf-8"');
    builder.element(
      'locale-config',
      namespaces: {'http://schemas.android.com/apk/res/android': 'android'},
      nest: () {
        for (final tag in expectedOrdered) {
          builder.element('locale', attributes: {'android:name': tag});
        }
      },
    );
    file.writeAsStringSync(
      builder.buildDocument().toXmlString(pretty: true, indent: '    '),
    );
    stdout.writeln('[android] rewrote $_androidXml');
  }
  return true;
}

/// Returns the list with `en` first (if present), the rest alphabetically.
List<String> _enFirst(List<String> tags) {
  final rest = [...tags.where((t) => t != 'en')]..sort();
  return tags.contains('en') ? ['en', ...rest] : rest;
}

/// The native-name map is hand-curated, since this script doesn't know how
/// to spell `Українська`, we can only check coverage, not auto-fix it.
bool _checkLanguageDartCoverage(List<String> expectedUnderscore) {
  final actual = languageNativeNames.keys.toSet();
  final expected = expectedUnderscore.toSet();

  final missing = expected.difference(actual).toList()..sort();
  final extra = actual.difference(expected).toList()..sort();

  if (missing.isEmpty && extra.isEmpty) {
    stdout.writeln('[dart] OK (${actual.length} entries)');
    return false;
  }

  if (missing.isNotEmpty) {
    stderr.writeln('[dart] missing native-name entries: ${missing.join(', ')}');
    stderr.writeln('       add them by hand to lib/l10n/language_native_names.dart');
  }
  if (extra.isNotEmpty) {
    stderr.writeln('[dart] stale native-name entries (no matching .arb): ${extra.join(', ')}');
  }
  return true;
}

void _reportDiff(String label, List<String> actual, List<String> expected) {
  final actualSet = actual.toSet();
  final expectedSet = expected.toSet();
  final missing = expectedSet.difference(actualSet).toList()..sort();
  final extra = actualSet.difference(expectedSet).toList()..sort();
  if (missing.isNotEmpty) {
    stderr.writeln('[$label] missing: ${missing.join(', ')}');
  }
  if (extra.isNotEmpty) {
    stderr.writeln('[$label] extra:   ${extra.join(', ')}');
  }
}
