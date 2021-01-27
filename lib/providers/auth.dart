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

import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wger/models/http_exception.dart';

class Auth with ChangeNotifier {
  String token;
  String serverUrl;

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

  Future<void> _authenticate(String username, String password, String serverUrl) async {
    // The android emulator uses
    var url = '$serverUrl/api/v2/login/';
    //print(username);
    //print(password);

    try {
      final response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
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

      // _autoLogout();
      notifyListeners();

      // store login data in shared preferences
      final prefs = await SharedPreferences.getInstance();
      final userData = json.encode({
        'token': token,
        'serverUrl': this.serverUrl,
        // 'expiryDate': _expiryDate.toIso8601String(),
      });
      prefs.setString('userData', userData);
    } catch (error) {
      throw error;
    }
  }

  Future<void> signUp(String email, String password) async {
    return _authenticate(email, password, 'signUp');
  }

  Future<void> signIn(String username, String password, String serverUrl) async {
    return _authenticate(username, password, serverUrl);
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
