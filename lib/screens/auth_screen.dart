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

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:wger/exceptions/http_exception.dart';
import 'package:wger/helpers/consts.dart';
import 'package:wger/helpers/misc.dart';
import 'package:wger/helpers/ui.dart';
import 'package:wger/screens/update_app_screen.dart';
import 'package:wger/theme/theme.dart';

import '../providers/auth.dart';

enum AuthMode {
  Signup,
  Login,
}

class AuthScreen extends StatelessWidget {
  const AuthScreen();
  static const routeName = '/auth';

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Stack(
        children: [
          Positioned(
            top: 0,
            right: 0,
            left: 0,
            child: Container(
              height: 0.55 * deviceSize.height,
              color: wgerPrimaryColor,
            ),
          ),
          SingleChildScrollView(
            child: SizedBox(
              height: deviceSize.height,
              width: deviceSize.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 0.15 * deviceSize.height),
                  const Image(
                    image: AssetImage('assets/images/logo-white.png'),
                    width: 85,
                  ),
                  Container(
                    margin: const EdgeInsets.only(bottom: 20.0),
                    padding: const EdgeInsets.symmetric(
                      vertical: 8.0,
                      horizontal: 94.0,
                    ),
                    child: const Text(
                      'wger',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: 0.025 * deviceSize.height),
                  const Flexible(child: AuthCard()),
                ],
              ),
            ),
          ),
          // Positioned(
          //   top: 0.4 * deviceSize.height,
          //   left: 15,
          //   right: 15,
          //   child: const ,
          // ),
        ],
      ),
    );
  }
}

class AuthCard extends StatefulWidget {
  const AuthCard();

  @override
  _AuthCardState createState() => _AuthCardState();
}

class _AuthCardState extends State<AuthCard> {
  bool isObscure = true;
  bool confirmIsObscure = true;

  final GlobalKey<FormState> _formKey = GlobalKey();
  bool _canRegister = true;
  AuthMode _authMode = AuthMode.Login;
  bool _hideCustomServer = true;
  final Map<String, String> _authData = {
    'username': '',
    'email': '',
    'password': '',
    'serverUrl': '',
  };
  var _isLoading = false;
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _password2Controller = TextEditingController();
  final _emailController = TextEditingController();
  final _serverUrlController = TextEditingController(
    text: kDebugMode ? DEFAULT_SERVER_TEST : DEFAULT_SERVER_PROD,
  );

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _password2Controller.dispose();
    _emailController.dispose();
    _serverUrlController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    context.read<AuthProvider>().getServerUrlFromPrefs().then((value) {
      _serverUrlController.text = value;
    });

    // Check if the API key is set
    //
    // If not, the user will not be able to register via the app
    try {
      final metadata = Provider.of<AuthProvider>(context, listen: false).metadata;
      if (metadata.containsKey(MANIFEST_KEY_API) && metadata[MANIFEST_KEY_API] == '') {
        _canRegister = false;
      }
    } on PlatformException {
      _canRegister = false;
    }
    _preFillTextfields();
  }

  void _preFillTextfields() {
    if (kDebugMode && _authMode == AuthMode.Login) {
      setState(() {
        _usernameController.text = TESTSERVER_USER_NAME;
        _passwordController.text = TESTSERVER_PASSWORD;
      });
    }
  }

  void _resetTextfields() {
    _usernameController.clear();
    _passwordController.clear();
  }

  void _submit(BuildContext context) async {
    if (!_formKey.currentState!.validate()) {
      // Invalid!
      return;
    }
    _formKey.currentState!.save();
    setState(() {
      _isLoading = true;
    });

    try {
      // Login existing user
      late Map<String, LoginActions> res;
      if (_authMode == AuthMode.Login) {
        res = await Provider.of<AuthProvider>(context, listen: false).login(
          _authData['username']!,
          _authData['password']!,
          _authData['serverUrl']!,
        );

        // Register new user
      } else {
        res = await Provider.of<AuthProvider>(context, listen: false).register(
          username: _authData['username']!,
          password: _authData['password']!,
          email: _authData['email']!,
          serverUrl: _authData['serverUrl']!,
          locale: Localizations.localeOf(context).languageCode,
        );
      }

      // Check if update is required else continue normally
      if (res.containsKey('action')) {
        if (res['action'] == LoginActions.update && mounted) {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const UpdateAppScreen()),
          );
          return;
        }
      }

      setState(() {
        _isLoading = false;
      });
    } on WgerHttpException catch (error) {
      if (mounted) {
        showHttpExceptionErrorDialog(error, context);
      }
      setState(() {
        _isLoading = false;
      });
    } catch (error) {
      if (mounted) {
        showErrorDialog(error, context);
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _switchAuthMode() {
    if (!_canRegister) {
      launchURL(DEFAULT_SERVER_PROD, context);
      return;
    }

    if (_authMode == AuthMode.Login) {
      setState(() {
        _authMode = AuthMode.Signup;
      });
      _resetTextfields();
    } else {
      setState(() {
        _authMode = AuthMode.Login;
      });
      _preFillTextfields();
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      elevation: 8.0,
      child: Container(
        width: deviceSize.width * 0.9,
        padding: EdgeInsets.symmetric(
          horizontal: 15.0,
          vertical: 0.025 * deviceSize.height,
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: AutofillGroup(
              child: Column(
                children: [
                  TextFormField(
                    key: const Key('inputUsername'),
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context).username,
                      errorMaxLines: 2,
                      prefixIcon: const Icon(Icons.account_circle),
                    ),
                    autofillHints: const [AutofillHints.username],
                    controller: _usernameController,
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppLocalizations.of(context).invalidUsername;
                      }
                      if (!RegExp(r'^[\w.@+-]+$').hasMatch(value)) {
                        return AppLocalizations.of(context).usernameValidChars;
                      }

                      return null;
                    },
                    inputFormatters: [
                      FilteringTextInputFormatter.deny(RegExp(r'\s\b|\b\s')),
                    ],
                    onSaved: (value) {
                      _authData['username'] = value!;
                    },
                  ),
                  if (_authMode == AuthMode.Signup)
                    TextFormField(
                      key: const Key('inputEmail'),
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context).email,
                        prefixIcon: const Icon(Icons.mail),
                      ),
                      autofillHints: const [AutofillHints.email],
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,

                      // Email is not required
                      validator: (value) {
                        if (value!.isNotEmpty && !value.contains('@')) {
                          return AppLocalizations.of(context).invalidEmail;
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _authData['email'] = value!;
                      },
                    ),
                  StatefulBuilder(builder: (context, updateState) {
                    return TextFormField(
                      key: const Key('inputPassword'),
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context).password,
                        prefixIcon: const Icon(Icons.password),
                        suffixIcon: IconButton(
                          icon: Icon(isObscure ? Icons.visibility_off : Icons.visibility),
                          onPressed: () {
                            isObscure = !isObscure;
                            updateState(() {});
                          },
                        ),
                      ),
                      autofillHints: const [AutofillHints.password],
                      obscureText: isObscure,
                      controller: _passwordController,
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value!.isEmpty || value.length < 8) {
                          return AppLocalizations.of(context).passwordTooShort;
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _authData['password'] = value!;
                      },
                    );
                  }),
                  if (_authMode == AuthMode.Signup)
                    StatefulBuilder(builder: (context, updateState) {
                      return TextFormField(
                        key: const Key('inputPassword2'),
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context).confirmPassword,
                          prefixIcon: const Icon(Icons.password),
                          suffixIcon: IconButton(
                            icon: Icon(confirmIsObscure ? Icons.visibility_off : Icons.visibility),
                            onPressed: () {
                              confirmIsObscure = !confirmIsObscure;
                              updateState(() {});
                            },
                          ),
                        ),
                        controller: _password2Controller,
                        enabled: _authMode == AuthMode.Signup,
                        obscureText: confirmIsObscure,
                        validator: _authMode == AuthMode.Signup
                            ? (value) {
                                if (value != _passwordController.text) {
                                  return AppLocalizations.of(context).passwordsDontMatch;
                                }
                                return null;
                              }
                            : null,
                      );
                    }),
                  // Off-stage widgets are kept in the tree, otherwise the server URL
                  // would not be saved to _authData
                  Offstage(
                    offstage: _hideCustomServer,
                    child: Row(
                      children: [
                        Flexible(
                          flex: 3,
                          child: TextFormField(
                            key: const Key('inputServer'),
                            decoration: InputDecoration(
                              labelText: AppLocalizations.of(context).customServerUrl,
                              helperText: AppLocalizations.of(context).customServerHint,
                              helperMaxLines: 4,
                            ),
                            controller: _serverUrlController,
                            validator: (value) {
                              if (Uri.tryParse(value!) == null) {
                                return AppLocalizations.of(context).invalidUrl;
                              }

                              if (value.isEmpty || !value.contains('http')) {
                                return AppLocalizations.of(context).invalidUrl;
                              }
                              return null;
                            },
                            onSaved: (value) {
                              // Remove any trailing slash
                              if (value!.lastIndexOf('/') == (value.length - 1)) {
                                value = value.substring(0, value.lastIndexOf('/'));
                              }
                              _authData['serverUrl'] = value;
                            },
                          ),
                        ),
                        const SizedBox(width: 20),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.undo),
                              onPressed: () {
                                _serverUrlController.text =
                                    kDebugMode ? DEFAULT_SERVER_TEST : DEFAULT_SERVER_PROD;
                              },
                            ),
                            Text(AppLocalizations.of(context).reset),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () {
                      if (!_isLoading) {
                        return _submit(context);
                      }
                    },
                    child: Container(
                      key: const Key('actionButton'),
                      width: double.infinity,
                      height: 0.065 * deviceSize.height,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30.0),
                        color: wgerPrimaryColor,
                      ),
                      child: Center(
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation(Colors.white),
                              )
                            : Text(
                                _authMode == AuthMode.Login
                                    ? AppLocalizations.of(context).login
                                    : AppLocalizations.of(context).register,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                  ),
                  SizedBox(height: 0.025 * deviceSize.height),
                  Builder(
                    key: const Key('toggleActionButton'),
                    builder: (context) {
                      final String text = _authMode != AuthMode.Signup
                          ? AppLocalizations.of(context).registerInstead
                          : AppLocalizations.of(context).loginInstead;

                      return GestureDetector(
                        onTap: () {
                          _switchAuthMode();
                        },
                        child: Container(
                          color: Colors.transparent,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                text.substring(0, text.lastIndexOf('?') + 1),
                              ),
                              Text(
                                text.substring(
                                  text.lastIndexOf('?') + 1,
                                  text.length,
                                ),
                                style: const TextStyle(
                                  //color: wgerPrimaryColor,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  TextButton(
                    key: const Key('toggleCustomServerButton'),
                    onPressed: () {
                      setState(() {
                        _hideCustomServer = !_hideCustomServer;
                      });
                    },
                    child: Text(
                      _hideCustomServer
                          ? AppLocalizations.of(context).useCustomServer
                          : AppLocalizations.of(context).useDefaultServer,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
