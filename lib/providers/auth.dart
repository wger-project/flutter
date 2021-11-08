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
import 'package:package_info/package_info.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:version/version.dart';
import 'package:wger/exceptions/http_exception.dart';
import 'package:wger/helpers/consts.dart';

import 'helpers.dart';

class AuthProvider with ChangeNotifier {
  String? token;
  String? serverUrl;
  String? serverVersion;
  PackageInfo? applicationVersion;
  Map<String, String>? metadata = {};

  late http.Client client;

  AuthProvider([http.Client? client]) {
    this.client = client ?? http.Client();

    try {
      AndroidMetadata.metaDataAsMap.then((value) => metadata = value);
    } on PlatformException {
      throw Exception('An error occurred reading the metadata from AndroidManifest');
    }
  }

  /// flag to indicate that the application has successfully loaded all initial data
  bool dataInit = false;

  bool get isAuth {
    return token != null;
  }

  /// Server application version
  Future<void> setServerVersion() async {
    final response = await client.get(makeUri(serverUrl!, 'version'));
    final responseData = json.decode(response.body);
    serverVersion = responseData;
  }

  /// (flutter) Application version
  Future<void> setApplicationVersion() async {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    applicationVersion = packageInfo;
  }

  /// Checking if there is a new version of the application.
  Future<bool> applicationUpdateRequired([String? version]) async {
    if (metadata!.containsKey('wger.check_min_app_version') ||
        metadata!['wger.check_min_app_version'] == 'false') {
      return false;
    }

    final applicationCurrentVersion = version ?? applicationVersion!.version;

    final response = await client.get(makeUri(serverUrl!, 'min-app-version'));
    final currentVersion = Version.parse(applicationCurrentVersion);

    final requiredAppVersion = Version.parse(response.body);
    return requiredAppVersion >= currentVersion;
  }

  /// Registers a new user
  Future<void> register(
      {required String username,
      required String password,
      required String email,
      required String serverUrl}) async {
    final uri = Uri.parse('$serverUrl/api/v2/register/');

    // Register
    try {
      final Map<String, String> data = {'username': username, 'password': password};
      if (email != '') {
        data['email'] = email;
      }
      final response = await client.post(
        uri,
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
          HttpHeaders.authorizationHeader: 'Token ${metadata![MANIFEST_KEY_API]}'
        },
        body: json.encode(data),
      );
      final responseData = json.decode(response.body);

      if (response.statusCode >= 400) {
        throw WgerHttpException(responseData);
      }

      login(username, password, serverUrl);
    } catch (error) {
      rethrow;
    }
  }

  /// Authenticates a user
  Future<void> login(String username, String password, String serverUrl) async {
    final uri = Uri.parse('$serverUrl/api/v2/login/');
    await logout(shouldNotify: false);

    try {
      final response = await client.post(
        uri,
        headers: <String, String>{
          HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
        },
        body: json.encode({'username': username, 'password': password}),
      );
      final responseData = json.decode(response.body);

      if (response.statusCode >= 400) {
        throw WgerHttpException(responseData);
      }

      // Log user in
      this.serverUrl = serverUrl;
      token = responseData['token'];

      notifyListeners();

      // store login data in shared preferences
      final prefs = await SharedPreferences.getInstance();
      final userData = json.encode({
        'token': token,
        'serverUrl': this.serverUrl,
      });
      final serverData = json.encode({
        'serverUrl': this.serverUrl,
      });

      await setServerVersion();
      await setApplicationVersion();
      prefs.setString('userData', userData);
      prefs.setString('lastServer', serverData);
    } catch (error) {
      rethrow;
    }
  }

  /// Loads the last server URL from which the user successfully logged in
  Future<String> getServerUrlFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('lastServer')) {
      return DEFAULT_SERVER;
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
      out = '${applicationVersion!.version} '
          '(${applicationVersion!.packageName}; '
          'build: ${applicationVersion!.buildNumber})';
    }
    return 'wger App/$out';
  }
}
