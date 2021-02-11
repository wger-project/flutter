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

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wger/helpers/ui.dart';
import 'package:wger/models/http_exception.dart';

import '../providers/auth.dart';

enum AuthMode {
  Signup,
  Login,
}

class AuthScreen extends StatelessWidget {
  static const routeName = '/auth';

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    // final transformConfig = Matrix4.rotationZ(-8 * pi / 180);
    // transformConfig.translate(-10.0);
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Stack(
        children: <Widget>[
          SingleChildScrollView(
            child: Container(
              height: deviceSize.height,
              width: deviceSize.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Padding(padding: EdgeInsets.symmetric(vertical: 20)),
                  Image(
                    image: AssetImage('assets/images/logo-white.png'),
                    width: 120,
                  ),
                  Container(
                    margin: EdgeInsets.only(bottom: 20.0),
                    padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 94.0),
                    // ..translate(-10.0),
                    child: Text(
                      'WGER',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 50,
                        fontFamily: 'OpenSansBold',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Flexible(
                    //flex: deviceSize.width > 600 ? 2 : 1,
                    child: AuthCard(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AuthCard extends StatefulWidget {
  const AuthCard({
    Key key,
  }) : super(key: key);

  @override
  _AuthCardState createState() => _AuthCardState();
}

class _AuthCardState extends State<AuthCard> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  AuthMode _authMode = AuthMode.Login;
  Map<String, String> _authData = {
    'username': '',
    'email': '',
    'password': '',
    'serverUrl': '',
  };
  var _isLoading = false;
  final _usernameController = TextEditingController(text: 'admin');
  final _passwordController = TextEditingController(text: 'adminadmin');
  final _password2Controller = TextEditingController();
  final _emailController = TextEditingController();
  final _serverUrlController = TextEditingController(text: 'http://10.0.2.2:8000');

  void _submit() async {
    if (!_formKey.currentState.validate()) {
      // Invalid!
      return;
    }
    _formKey.currentState.save();
    setState(() {
      _isLoading = true;
    });
    try {
      // Login existing user
      if (_authMode == AuthMode.Login) {
        await Provider.of<Auth>(context, listen: false).login(
          _authData['username'],
          _authData['password'],
          _authData['serverUrl'],
        );

        // Register new user
      } else {
        await Provider.of<Auth>(context, listen: false).register(
          username: _authData['username'],
          password: _authData['password'],
          email: _authData['email'],
          serverUrl: _authData['serverUrl'],
        );
      }
    } on WgerHttpException catch (error) {
      showHttpExceptionErrorDialog(error, context);
    } catch (error) {
      showErrorDialog(error, context);
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _switchAuthMode() {
    if (_authMode == AuthMode.Login) {
      setState(() {
        _authMode = AuthMode.Signup;
      });
    } else {
      setState(() {
        _authMode = AuthMode.Login;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      elevation: 8.0,
      child: Container(
        //decoration: BoxDecoration(color: Colors.black12),
        //height: _authMode == AuthMode.Signup ? 450 : 320,
        //constraints:
        //    BoxConstraints(minHeight: _authMode == AuthMode.Signup ? 450 : 320),
        width: deviceSize.width * 0.75,
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                TextFormField(
                  key: Key('inputUsername'),
                  decoration: InputDecoration(labelText: 'Username'),
                  autofillHints: [AutofillHints.username],
                  controller: _usernameController,
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Invalid Username!';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _authData['username'] = value;
                  },
                ),
                if (_authMode == AuthMode.Signup)
                  TextFormField(
                    key: Key('inputEmail'),
                    decoration: InputDecoration(labelText: 'E-Mail'),
                    autofillHints: [AutofillHints.email],
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,

                    // Email is not required
                    validator: (value) {
                      if (value.isNotEmpty && !value.contains('@')) {
                        return 'Invalid email!';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _authData['email'] = value;
                    },
                  ),
                TextFormField(
                  key: Key('inputPassword'),
                  decoration: InputDecoration(labelText: 'Password'),
                  autofillHints: [AutofillHints.password],
                  obscureText: true,
                  controller: _passwordController,
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    /*
                    if (value.isEmpty || value.length < 8) {
                      return 'Password is too short!';
                    }
                     */
                    return null;
                  },
                  onSaved: (value) {
                    _authData['password'] = value;
                  },
                ),
                if (_authMode == AuthMode.Signup)
                  TextFormField(
                    key: Key('inputPassword2'),
                    decoration: InputDecoration(labelText: 'Confirm Password'),
                    controller: _password2Controller,
                    enabled: _authMode == AuthMode.Signup,
                    obscureText: true,
                    validator: _authMode == AuthMode.Signup
                        ? (value) {
                            if (value != _passwordController.text) {
                              return 'Passwords do not match!';
                            }
                            return null;
                          }
                        : null,
                  ),
                TextFormField(
                  key: Key('inputServer'),
                  decoration: InputDecoration(labelText: 'Server URL'),
                  controller: _serverUrlController,
                  validator: (value) {
                    if (value.isEmpty || !value.contains('http')) {
                      return 'Invalid URL!';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _authData['serverUrl'] = value;
                  },
                ),
                SizedBox(
                  height: 20,
                ),
                if (_isLoading)
                  CircularProgressIndicator()
                else
                  ElevatedButton(
                    key: Key('actionButton'),
                    child: Text(_authMode == AuthMode.Login ? 'LOGIN' : 'REGISTER'),
                    onPressed: _submit,
                  ),
                TextButton(
                  key: Key('toggleActionButton'),
                  child: Text('${_authMode == AuthMode.Login ? 'REGISTER' : 'LOGIN'} INSTEAD'),
                  onPressed: _switchAuthMode,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
