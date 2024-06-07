/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (C) 2020, 2021 wger Team
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

import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:android_metadata/android_metadata.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:version/version.dart';
import 'package:wger/exceptions/http_exception.dart';
import 'package:wger/helpers/consts.dart';

import 'helpers.dart';

enum LoginActions {
  update,
  proceed,
}

class AuthProvider with ChangeNotifier {
  String? token;
  String? serverUrl;
  String? serverVersion;
  PackageInfo? applicationVersion;
  Map<String, String> metadata = {};

  static const MIN_APP_VERSION_URL = 'min-app-version';
  static const SERVER_VERSION_URL = 'version';
  static const REGISTRATION_URL = 'register';
  static const LOGIN_URL = 'login';

  late http.Client client;

  AuthProvider([http.Client? client, bool? checkMetadata]) {
    this.client = client ?? http.Client();

    // TODO: this is a workaround since AndroidMetadata doesn't work while running tests
    if (checkMetadata ?? true) {
      try {
        if (Platform.isAndroid) {
          AndroidMetadata.metaDataAsMap.then((value) => metadata = value!);
        } else if (Platform.isLinux || Platform.isMacOS) {
          metadata = {
            MANIFEST_KEY_CHECK_UPDATE: Platform.environment[MANIFEST_KEY_CHECK_UPDATE] ?? '',
            MANIFEST_KEY_API: Platform.environment[MANIFEST_KEY_API] ?? '',
          };
        }
      } on PlatformException {
        throw Exception(
          'An error occurred reading the metadata from AndroidManifest',
        );
      } catch (error) {}
    }
  }

  /// flag to indicate that the application has successfully loaded all initial data
  bool dataInit = false;

  bool get isAuth {
    return token != null;
  }

  /// Server application version
  Future<void> setServerVersion() async {
    final response = await client.get(makeUri(serverUrl!, SERVER_VERSION_URL));
    serverVersion = json.decode(response.body);
  }

  Future<void> initData(String serverUrl) async {
    this.serverUrl = serverUrl;
    await setApplicationVersion();
    await setServerVersion();
  }

  /// (flutter) Application version
  Future<void> setApplicationVersion() async {
    applicationVersion = await PackageInfo.fromPlatform();
  }

  /// Checking if there is a new version of the application.
  Future<bool> applicationUpdateRequired([
    String? version,
    Map<String, String>? metadata,
  ]) async {
    metadata ??= this.metadata;
    if (!metadata.containsKey(MANIFEST_KEY_CHECK_UPDATE) ||
        metadata[MANIFEST_KEY_CHECK_UPDATE] == 'false') {
      return false;
    }

    final applicationCurrentVersion = version ?? applicationVersion!.version;
    final response = await client.get(makeUri(serverUrl!, MIN_APP_VERSION_URL));
    final currentVersion = Version.parse(applicationCurrentVersion);
    final requiredAppVersion = Version.parse(jsonDecode(response.body));

    return requiredAppVersion > currentVersion;
  }

  /// Registers a new user
  Future<Map<String, LoginActions>> register({
    required String username,
    required String password,
    required String email,
    required String serverUrl,
    String locale = 'en',
  }) async {
    // Register
    final Map<String, String> data = {
      'username': username,
      'password': password,
    };
    if (email != '') {
      data['email'] = email;
    }
    final response = await client.post(
      makeUri(serverUrl, REGISTRATION_URL),
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
        HttpHeaders.authorizationHeader: 'Token ${metadata[MANIFEST_KEY_API]}',
        HttpHeaders.userAgentHeader: getAppNameHeader(),
        HttpHeaders.acceptLanguageHeader: locale,
      },
      body: json.encode(data),
    );

    if (response.statusCode >= 400) {
      throw WgerHttpException(response.body);
    }

    // If update is required don't log in user
    if (await applicationUpdateRequired()) {
      return {'action': LoginActions.update};
    }

    return login(username, password, serverUrl);
  }

  /// Authenticates a user
  Future<Map<String, LoginActions>> login(
    String username,
    String password,
    String serverUrl,
  ) async {
    await logout(shouldNotify: false);

    final response = await client.post(
      makeUri(serverUrl, LOGIN_URL),
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
        HttpHeaders.userAgentHeader: getAppNameHeader(),
      },
      body: json.encode({'username': username, 'password': password}),
    );
    final responseData = json.decode(response.body);

    if (response.statusCode >= 400) {
      throw WgerHttpException(response.body);
    }

    await initData(serverUrl);

    // If update is required don't log in user
    if (await applicationUpdateRequired()) {
      return {'action': LoginActions.update};
    }

    // Log user in
    token = responseData['token'];
    notifyListeners();

    // store login data in shared preferences
    final prefs = await SharedPreferences.getInstance();
    final userData = json.encode({
      'token': token,
      'serverUrl': this.serverUrl,
    });
    final serverData = json.encode({'serverUrl': this.serverUrl});

    prefs.setString('userData', userData);
    prefs.setString('lastServer', serverData);
    return {'action': LoginActions.proceed};
  }

  /// Loads the last server URL from which the user successfully logged in
  Future<String> getServerUrlFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('lastServer')) {
      return DEFAULT_SERVER_PROD;
    }

    final userData = json.decode(prefs.getString('lastServer')!);
    return userData['serverUrl'] as String;
  }

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) {
      log('autologin failed');
      return false;
    }
    final extractedUserData = json.decode(prefs.getString('userData')!);

    token = extractedUserData['token'];
    serverUrl = extractedUserData['serverUrl'];

    log('autologin successful');
    setApplicationVersion();
    setServerVersion();
    notifyListeners();
    //_autoLogout();
    return true;
  }

  Future<void> logout({bool shouldNotify = true}) async {
    log('logging out');
    token = null;
    serverUrl = null;
    dataInit = false;

    if (shouldNotify) {
      notifyListeners();
    }

    final prefs = await SharedPreferences.getInstance();
    prefs.remove('userData');
  }

  /// Returns the application name and version
  ///
  /// This is used in the headers when talking to the API
  String getAppNameHeader() {
    String out = '';
    if (applicationVersion != null) {
      out = '/${applicationVersion!.version} '
          '(${applicationVersion!.packageName}; '
          'build: ${applicationVersion!.buildNumber})';
    }
    return 'wger App$out';
  }
}
