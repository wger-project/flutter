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
import 'package:provider/provider.dart';
import 'package:wger/exceptions/http_exception.dart';
import 'package:wger/helpers/consts.dart';
import 'package:wger/helpers/errors.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/screens/update_app_screen.dart';
import 'package:wger/theme/theme.dart';
import 'package:wger/widgets/auth/api_token_field.dart';
import 'package:wger/widgets/auth/email_field.dart';
import 'package:wger/widgets/auth/password_field.dart';
import 'package:wger/widgets/auth/server_field.dart';
import 'package:wger/widgets/auth/username_field.dart';

import '../providers/auth.dart';

enum AuthMode {
  Register,
  Login,
}

class AuthScreen extends StatelessWidget {
  const AuthScreen();

  static const routeName = '/auth';

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.sizeOf(context);
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
  Widget errorMessage = const SizedBox.shrink();

  final GlobalKey<FormState> _formKey = GlobalKey();
  AuthMode _authMode = AuthMode.Login;
  bool _hideCustomServer = true;
  bool _useUsernameAndPassword = true;
  final Map<String, String> _authData = {
    'username': '',
    'email': '',
    'password': '',
    'serverUrl': '',
    'apiToken': '',
  };
  var _isLoading = false;
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _password2Controller = TextEditingController();
  final _emailController = TextEditingController();
  final _serverUrlController = TextEditingController(
    text: kDebugMode ? DEFAULT_SERVER_TEST : DEFAULT_SERVER_PROD,
  );
  final _apiTokenController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _password2Controller.dispose();
    _emailController.dispose();
    _serverUrlController.dispose();
    _apiTokenController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    context.read<AuthProvider>().getServerUrlFromPrefs().then((value) {
      _serverUrlController.text = value;
    });

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
    _apiTokenController.clear();
  }

  void _submit(BuildContext context) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();
    setState(() {
      _isLoading = true;
    });

    try {
      // Login existing user
      late LoginActions res;
      if (_authMode == AuthMode.Login) {
        res = await context.read<AuthProvider>().login(
          _authData['username']!,
          _authData['password']!,
          _authData['serverUrl']!,
          _authData['apiToken'],
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
      if (res == LoginActions.update && mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const UpdateAppScreen()),
        );
        return;
      }
      if (context.mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } on WgerHttpException catch (error) {
      if (context.mounted) {
        setState(() {
          errorMessage = FormHttpErrorsWidget(error);
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _switchAuthMode() {
    if (_authMode == AuthMode.Login) {
      setState(() {
        _authMode = AuthMode.Register;
        _useUsernameAndPassword = true;
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
    final i18n = AppLocalizations.of(context);
    final deviceSize = MediaQuery.sizeOf(context);

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
                  errorMessage,
                  if (_useUsernameAndPassword)
                    UsernameField(
                      controller: _apiTokenController,
                      onSaved: (value) => _authData['username'] = value!,
                    ),
                  if (_authMode == AuthMode.Register)
                    EmailField(
                      controller: _emailController,
                      onSaved: (value) => _authData['email'] = value!,
                    ),
                  if (_useUsernameAndPassword)
                    PasswordField(
                      controller: _passwordController,
                      onSaved: (value) => _authData['password'] = value!,
                    ),

                  if (_authMode == AuthMode.Register)
                    StatefulBuilder(
                      builder: (context, updateState) {
                        return TextFormField(
                          key: const Key('inputPassword2'),
                          decoration: InputDecoration(
                            labelText: i18n.confirmPassword,
                            prefixIcon: const Icon(Icons.password),
                            suffixIcon: IconButton(
                              icon: Icon(
                                confirmIsObscure ? Icons.visibility_off : Icons.visibility,
                              ),
                              onPressed: () {
                                updateState(() {
                                  confirmIsObscure = !confirmIsObscure;
                                });
                              },
                            ),
                          ),
                          controller: _password2Controller,
                          enabled: _authMode == AuthMode.Register,
                          obscureText: confirmIsObscure,
                          validator: _authMode == AuthMode.Register
                              ? (value) {
                                  if (value != _passwordController.text) {
                                    return i18n.passwordsDontMatch;
                                  }
                                  return null;
                                }
                              : null,
                        );
                      },
                    ),

                  // Off-stage widgets are kept in the tree, otherwise the server URL
                  // would not be saved to _authData
                  if (_authMode == AuthMode.Login && !_useUsernameAndPassword)
                    ApiTokenField(
                      controller: _apiTokenController,
                      onSaved: (value) => _authData['apiToken'] = value!,
                    ),
                  Offstage(
                    offstage: _hideCustomServer,
                    child: ServerField(
                      controller: _serverUrlController,
                      onSaved: (value) {
                        // Remove any trailing slash
                        if (value!.lastIndexOf('/') == (value.length - 1)) {
                          value = value.substring(0, value.lastIndexOf('/'));
                        }
                        _authData['serverUrl'] = value;
                      },
                    ),
                  ),
                  if (!_hideCustomServer)
                    TextButton(
                      key: const ValueKey('toggleApiTokenButton'),
                      onPressed: _authMode == AuthMode.Login
                          ? () => setState(() => _useUsernameAndPassword = !_useUsernameAndPassword)
                          : null,
                      child: Text(
                        _useUsernameAndPassword ? i18n.useApiToken : i18n.useUsernameAndPassword,
                      ),
                    ),

                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 45,
                    child: ElevatedButton(
                      key: const Key('actionButton'),
                      onPressed: () {
                        if (!_isLoading) {
                          return _submit(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation(Colors.white),
                            )
                          : Text(
                              _authMode == AuthMode.Login ? i18n.login : i18n.register,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 20),
                  Builder(
                    key: const Key('toggleActionButton'),
                    builder: (context) {
                      final String text = _authMode != AuthMode.Register
                          ? i18n.registerInstead
                          : i18n.loginInstead;

                      return GestureDetector(
                        onTap: () => _switchAuthMode(),
                        child: Container(
                          color: Colors.transparent,
                          child: Column(
                            children: [
                              // TODO: i18n!
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
                  const SizedBox(height: 15),
                  TextButton(
                    key: const Key('toggleCustomServerButton'),
                    onPressed: () {
                      setState(() {
                        _hideCustomServer = !_hideCustomServer;
                        if (_hideCustomServer) {
                          _useUsernameAndPassword = true;
                        }
                      });
                    },
                    child: Text(
                      _hideCustomServer ? i18n.useCustomServer : i18n.useDefaultServer,
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
