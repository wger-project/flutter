import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/http_exception.dart';

class Auth with ChangeNotifier {
  String _token;
  String _serverUrl;
  // DateTime _expiryDate;
  // String _userId;
  // Timer _authTimer;

  bool get isAuth {
    return token != null;
  }

  String get token {
    // if (_expiryDate != null &&
    // _expiryDate.isAfter(DateTime.now()) &&
    // _token != null) {
    return _token;
    // }
    // return null;
  }

  String get serverUrl {
    return _serverUrl;
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
      //print(response.statusCode);
      //print(responseData);

      if (response.statusCode >= 400) {
        throw HttpException(json.decode(responseData) as Map<String, dynamic>);
      }

      // Log user in
      _serverUrl = serverUrl;
      _token = responseData['token'];

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
        'token': _token,
        'serverUrl': _serverUrl,
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
      return false;
    }

    final extractedUserData = json.decode(prefs.getString('userData')) as Map<String, Object>;
    // final expiryDate = DateTime.parse(extractedUserData['expiryDate']);

    // if (expiryDate.isBefore(DateTime.now())) {
    //   return false;
    // }

    _token = extractedUserData['token'];
    _serverUrl = extractedUserData['serverUrl'];
    // _userId = extractedUserData['userId'];
    // _expiryDate = expiryDate;

    notifyListeners();
    //_autoLogout();
    return true;
  }

  Future<void> logout() async {
    _token = null;
    _serverUrl = null;
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

  void setLoginServer(String serverUrl) {
    _serverUrl = serverUrl;
  }
}
