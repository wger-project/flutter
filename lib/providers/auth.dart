/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (C) 2020 wger Team
 *
 * wger Workout Manager is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * wger Workout Manager is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>.
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
import 'package:wger/models/http_exception.dart';

import 'helpers.dart';

final DEFAULT_SERVER = 'https://wger.rge.uber.space';

class Auth with ChangeNotifier {
  String token;
  String serverUrl;
  String serverVersion;
  PackageInfo applicationVersion;

  /// flag to indicate that the application has successfully loaded all initial data
  bool dataInit = false;

  // DateTime _expiryDate;
  // String _userId;
  // Timer _authTimer;

  bool get isAuth {
    return token != null;
  }

  String get token2 {
    // if (_expiryDate != null &&
    // _expiryDate.isAfter(DateTime.now()) &&
    // _token != null) {
    return token;
    // }
    // return null;
  }

  // String get userId {
  //   return _userId;
  // }

  /// Server application version
  Future<void> setServerVersion() async {
    final response = await http.get(makeUri(serverUrl, 'version'));
    final responseData = json.decode(response.body);
    serverVersion = responseData;
  }

  /// (flutter) Application version
  Future<void> setApplicationVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    applicationVersion = packageInfo;
  }

  /// Registers a new user
  Future<void> register({String username, String password, String email, String serverUrl}) async {
    final uri = Uri.parse(serverUrl + '/api/v2/register/');
    Map<String, String> metadata = Map();

    // Read the api key from the manifest file
    try {
      metadata = await AndroidMetadata.metaDataAsMap;
    } on PlatformException {
      throw Exception('An error occurred reading the API key');
    }

    // Register
    try {
      Map<String, String> data = {'username': username, 'password': password};
      if (email != '') {
        data['email'] = email;
      }
      final response = await http.post(
        uri,
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
          HttpHeaders.authorizationHeader: "Token ${metadata['wger.api_key']}"
        },
        body: json.encode(data),
      );
      final responseData = json.decode(response.body);

      if (response.statusCode >= 400) {
        throw WgerHttpException(responseData);
      }

      login(username, password, serverUrl);
    } catch (error) {
      throw error;
    }
  }

  /// Authenticates a user
  Future<void> login(String username, String password, String serverUrl) async {
    final uri = Uri.parse(serverUrl + '/api/v2/login/');
    await logout();

    try {
      final response = await http.post(
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
      this.serverUrl = serverUrl ?? '';
      token = responseData['token'];

      // _userId = responseData['localId'];
      // _expiryDate = DateTime.now().add(
      //   Duration(
      //     seconds: int.parse(responseData['expiresIn']),
      //   ),
      // );

      notifyListeners();

      // store login data in shared preferences
      final prefs = await SharedPreferences.getInstance();
      final userData = json.encode({
        'token': token,
        'serverUrl': this.serverUrl,
        // 'expiryDate': _expiryDate.toIso8601String(),
      });
      final serverData = json.encode({
        'serverUrl': this.serverUrl,
      });

      await setServerVersion();
      await setApplicationVersion();
      prefs.setString('userData', userData);
      prefs.setString('lastServer', serverData);
    } catch (error) {
      throw error;
    }
  }

  /// Loads the last server URL from which the user successfully logged in
  Future<String> getServerUrlFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('lastServer')) {
      return DEFAULT_SERVER;
    }

    final userData = json.decode(prefs.getString('lastServer')) as Map<String, Object>;
    return userData['serverUrl'];
  }

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) {
      log('autologin failed');
      return false;
    }

    final extractedUserData = json.decode(prefs.getString('userData')) as Map<String, Object>;
    // final expiryDate = DateTime.parse(extractedUserData['expiryDate']);

    // if (expiryDate.isBefore(DateTime.now())) {
    //   return false;
    // }

    token = extractedUserData['token'];
    serverUrl = extractedUserData['serverUrl'];
    // _userId = extractedUserData['userId'];
    // _expiryDate = expiryDate;

    log('autologin successful');
    setApplicationVersion();
    setServerVersion();
    notifyListeners();
    //_autoLogout();
    return true;
  }

  Future<void> logout() async {
    log('logging out');
    token = null;
    serverUrl = null;
    // _userId = null;
    // _expiryDate = null;
    // if (_authTimer != null) {
    //   _authTimer.cancel();
    //   _authTimer = null;
    // }

    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('userData');
  }

  // void _autoLogout() {
  //   if (_authTimer != null) {
  //     _authTimer.cancel();
  //   }
  //   final timeToExpiry = _expiryDate.difference(DateTime.now()).inSeconds;
  //   _authTimer = Timer(Duration(seconds: timeToExpiry), logout);
  // }

}
