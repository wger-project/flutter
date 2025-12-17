/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (c) 2020 - 2025 wger Team
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
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:version/version.dart';
import 'package:wger/core/exceptions/http_exception.dart';
import 'package:wger/helpers/consts.dart';
import 'package:wger/helpers/shared_preferences.dart';

import 'helpers.dart';

enum LoginActions {
  update,
  proceed,
}

enum AuthState {
  updateRequired,
  loggedIn,
  loggedOut,
}

class AuthProvider with ChangeNotifier {
  final _logger = Logger('AuthProvider');

  String? token;
  String? serverUrl;
  String? serverVersion;
  PackageInfo? applicationVersion;
  Map<String, String> metadata = {};
  AuthState state = AuthState.loggedOut;

  static const MIN_APP_VERSION_URL = 'min-app-version';
  static const SERVER_VERSION_URL = 'version';
  static const REGISTRATION_URL = 'register';
  static const LOGIN_URL = 'login';
  static const TEST_URL = 'userprofile';

  late http.Client client;

  AuthProvider([http.Client? client]) {
    this.client = client ?? http.Client();
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

  /// (flutter) Application version
  Future<void> setApplicationVersion() async {
    applicationVersion = await PackageInfo.fromPlatform();
  }

  Future<void> initVersions(String serverUrl) async {
    this.serverUrl = serverUrl;
    await setApplicationVersion();
    await setServerVersion();
  }

  /// Checking if there is a new version of the application.
  Future<bool> applicationUpdateRequired([String? version]) async {
    final applicationCurrentVersion = version ?? applicationVersion!.version;
    final response = await client.get(makeUri(serverUrl!, MIN_APP_VERSION_URL));
    final currentVersion = Version.parse(applicationCurrentVersion);
    final requiredAppVersion = Version.parse(jsonDecode(response.body));

    final needUpdate = requiredAppVersion > currentVersion;
    if (needUpdate) {
      _logger.fine('Application update required: $requiredAppVersion > $currentVersion');
    }

    return needUpdate;
  }

  /// Registers a new user
  Future<LoginActions> register({
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
        HttpHeaders.userAgentHeader: getAppNameHeader(),
        HttpHeaders.acceptLanguageHeader: locale,
      },
      body: json.encode(data),
    );

    if (response.statusCode >= 400) {
      throw WgerHttpException(response);
    }

    return login(username, password, serverUrl, null);
  }

  /// Authenticates a user
  Future<LoginActions> login(
    String username,
    String password,
    String serverUrl,
    String? apiToken,
  ) async {
    await logout(shouldNotify: false);

    // Login using the API token
    if (apiToken != null && apiToken.isNotEmpty) {
      final response = await client.get(
        makeUri(serverUrl, TEST_URL),
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
          HttpHeaders.userAgentHeader: getAppNameHeader(),
          HttpHeaders.authorizationHeader: 'Token $apiToken',
        },
      );

      if (response.statusCode >= 400) {
        throw WgerHttpException(response);
      }

      token = apiToken;

      // Login using password
    } else {
      final response = await client.post(
        makeUri(serverUrl, LOGIN_URL),
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json; charset=utf-8',
          HttpHeaders.userAgentHeader: getAppNameHeader(),
        },
        body: json.encode({'username': username, 'password': password}),
      );

      if (response.statusCode >= 400) {
        throw WgerHttpException(response);
      }

      final responseData = json.decode(response.body);

      token = responseData['token'];
    }

    await initVersions(serverUrl);

    // If update is required don't log in user
    if (await applicationUpdateRequired()) {
      state = AuthState.updateRequired;
      return LoginActions.update;
    }

    // Log user in
    state = AuthState.loggedIn;
    notifyListeners();

    // store login data in shared preferences
    final prefs = PreferenceHelper.asyncPref;
    final userData = json.encode({
      'token': token,
      'serverUrl': this.serverUrl,
    });
    final serverData = json.encode({'serverUrl': this.serverUrl});

    prefs.setString(PREFS_USER, userData);
    prefs.setString(PREFS_LAST_SERVER, serverData);
    return LoginActions.proceed;
  }

  /// Loads the last server URL from which the user successfully logged in
  Future<String> getServerUrlFromPrefs() async {
    final prefs = PreferenceHelper.asyncPref;
    if (!(await prefs.containsKey(PREFS_LAST_SERVER))) {
      return DEFAULT_SERVER_PROD;
    }

    final userData = json.decode((await prefs.getString(PREFS_LAST_SERVER))!);
    return userData['serverUrl'] as String;
  }

  /// Tries to auto-login the user with the stored token
  Future<void> tryAutoLogin() async {
    final prefs = PreferenceHelper.asyncPref;
    if (!(await prefs.containsKey(PREFS_USER))) {
      _logger.info('autologin failed, no saved user data');
      state = AuthState.loggedOut;
      return;
    }

    final userData = json.decode((await prefs.getString(PREFS_USER))!);

    if (!userData.containsKey('token') || !userData.containsKey('serverUrl')) {
      _logger.info('autologin failed, no token or serverUrl');
      state = AuthState.loggedOut;
      return;
    }

    token = userData['token'];
    serverUrl = userData['serverUrl'];

    if (token == null || serverUrl == null) {
      _logger.info('autologin failed, token or serverUrl is null');
      state = AuthState.loggedOut;
      return;
    }

    // // Try to talk to a URL using the token, if this doesn't work, log out
    final response = await client.head(
      makeUri(serverUrl!, 'routine'),
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
        HttpHeaders.userAgentHeader: getAppNameHeader(),
        HttpHeaders.authorizationHeader: 'Token $token',
      },
    );
    if (response.statusCode != 200) {
      _logger.info('autologin failed, statusCode: ${response.statusCode}');
      await logout();
      return;
    }

    await initVersions(serverUrl!);

    // If update is required don't log in user
    if (await applicationUpdateRequired()) {
      state = AuthState.updateRequired;
    } else {
      state = AuthState.loggedIn;
      _logger.info('autologin successful');
    }

    notifyListeners();
  }

  Future<void> logout({bool shouldNotify = true}) async {
    _logger.fine('logging out');
    token = null;
    serverUrl = null;
    dataInit = false;
    state = AuthState.loggedOut;

    if (shouldNotify) {
      notifyListeners();
    }

    final prefs = PreferenceHelper.asyncPref;
    prefs.remove(PREFS_USER);
  }

  /// Returns the application name and version
  ///
  /// This is used in the headers when talking to the API
  String getAppNameHeader() {
    String out = '';
    if (applicationVersion != null) {
      out =
          '/${applicationVersion!.version} '
          '(${applicationVersion!.packageName}; '
          'build: ${applicationVersion!.buildNumber})'
          ' - https://github.com/wger-project';
    }
    return 'wger App$out';
  }
}
