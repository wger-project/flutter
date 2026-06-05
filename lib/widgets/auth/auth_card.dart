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

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wger/core/error_dialogs.dart';
import 'package:wger/core/exceptions/http_exception.dart';
import 'package:wger/core/exceptions/mfa_required_exception.dart';
import 'package:wger/helpers/consts.dart';
import 'package:wger/helpers/errors.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/providers/app_link_router.dart';
import 'package:wger/providers/auth_notifier.dart';
import 'package:wger/providers/auth_state.dart';
import 'package:wger/providers/network_provider.dart';
import 'package:wger/screens/mfa_challenge_screen.dart';
import 'package:wger/widgets/auth/advanced_sheet.dart';
import 'package:wger/widgets/core/server_config_warning_dialog.dart';

import 'advanced_footer.dart';
import 'auth_mode_switch_link.dart';
import 'confirm_password_field.dart';
import 'email_field.dart';
import 'password_field.dart';
import 'refresh_token_field.dart';
import 'username_field.dart';
import 'web_handoff_link.dart';

enum AuthMode {
  register,
  login,
}

class AuthCard extends ConsumerStatefulWidget {
  const AuthCard();

  @override
  _AuthCardState createState() => _AuthCardState();
}

class _AuthCardState extends ConsumerState<AuthCard> {
  WgerHttpException? _httpError;
  final GlobalKey<FormState> _formKey = GlobalKey();

  AuthMode _authMode = AuthMode.login;

  bool _showNetworkError = false;
  // Live validation is suppressed until the user taps submit at least once.
  // Otherwise programmatic controller writes (debug prefill, _resetTextfields
  // on mode switch) trip the FormFields' "interacted by user" flag and
  // immediately surface error messages on a form the user hasn't touched.
  bool _autoValidate = false;
  bool _hideCustomServer = true;
  bool _useUsernameAndPassword = true;
  var _isLoading = false;

  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _password2Controller = TextEditingController();
  final _emailController = TextEditingController();
  final _serverUrlController = TextEditingController(
    text: kDebugMode ? DEFAULT_SERVER_TEST : DEFAULT_SERVER_PROD,
  );
  final _refreshTokenController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _password2Controller.dispose();
    _emailController.dispose();
    _serverUrlController.dispose();
    _refreshTokenController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    AuthNotifier.getServerUrlFromPrefs().then((value) {
      if (mounted) {
        _serverUrlController.text = value;
      }
    });

    _preFillTextFields();
  }

  /// Opens the server's web-handoff page in the system browser. The user
  /// authenticates there (password, social, SSO, …) and the server redirects
  /// back via `wger://app-auth#token=…`, which the app_link_router picks up
  /// and feeds into the existing refresh-token login path.
  Future<void> _launchWebHandoff() async {
    var serverUrl = _serverUrlController.text.trim();
    if (serverUrl.endsWith('/')) {
      serverUrl = serverUrl.substring(0, serverUrl.length - 1);
    }
    if (serverUrl.isEmpty) {
      serverUrl = kDebugMode ? DEFAULT_SERVER_TEST : DEFAULT_SERVER_PROD;
    }
    final state = await issueAppAuthState(serverUrl);
    await launchUrl(
      Uri.parse('$serverUrl/user/app-auth/?state=$state'),
      mode: LaunchMode.externalApplication,
    );
  }

  void _preFillTextFields() {
    if (kDebugMode && _authMode == AuthMode.login) {
      setState(() {
        _usernameController.text = TESTSERVER_USER_NAME;
        _passwordController.text = TESTSERVER_PASSWORD;
      });
    }
  }

  void _resetTextFields() {
    _usernameController.clear();
    _passwordController.clear();
    _refreshTokenController.clear();
  }

  Future<void> _submit(BuildContext context) async {
    // From the first submit attempt on, validators run live as the user fixes
    // each field — but not before.
    setState(() {
      _autoValidate = true;
    });
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() {
      _isLoading = true;
    });

    var serverUrl = _serverUrlController.text;
    if (serverUrl.endsWith('/')) {
      serverUrl = serverUrl.substring(0, serverUrl.length - 1);
    }

    try {
      final authNotifier = ref.read(authProvider.notifier);
      // Login existing user
      late LoginActions res;
      if (_authMode == AuthMode.login) {
        res = await authNotifier.login(
          _usernameController.text,
          _passwordController.text,
          serverUrl,
          _refreshTokenController.text,
        );

        // Register new user
      } else {
        res = await authNotifier.register(
          username: _usernameController.text,
          password: _passwordController.text,
          email: _emailController.text,
          serverUrl: serverUrl,
          locale: Localizations.localeOf(context).languageCode,
        );
      }

      // The "update required" screens are handled reactively by main.dart's
      // _getHomeScreen, which swaps the home screen on the auth status.
      if (context.mounted && res == LoginActions.proceed) {
        final showWarning = ref.read(authProvider).value?.serverConfigWarning ?? false;
        if (showWarning && context.mounted) {
          showServerConfigWarning(context);
          ref.read(authProvider.notifier).clearServerConfigWarning();
        }
      }
    } on MfaRequiredException catch (e) {
      if (context.mounted) {
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => MfaChallengeScreen(
              sessionToken: e.sessionToken,
              serverUrl: serverUrl,
              availableFactors: e.availableFactors,
            ),
          ),
        );
      }
    } on WgerHttpException catch (error) {
      if (context.mounted) {
        setState(() {
          _httpError = error;
          _showNetworkError = false;
        });
      }
    } catch (error) {
      // Login is inherently online, but surface an unreachable server as a
      // friendly message instead of crashing to the red error screen.
      if (isNetworkError(error) && context.mounted) {
        setState(() {
          _showNetworkError = true;
          _httpError = null;
        });
      } else {
        rethrow;
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _switchAuthMode() {
    if (_authMode == AuthMode.login) {
      setState(() {
        _authMode = AuthMode.register;
        _useUsernameAndPassword = true;
        _autoValidate = false;
      });
      _resetTextFields();
    } else {
      setState(() {
        _authMode = AuthMode.login;
        _autoValidate = false;
      });
      _preFillTextFields();
    }
  }

  /// Opens the advanced bottom sheet (server + sign-in-method selection).
  void _showAdvancedSheet() {
    showAdvancedSheet(
      context: context,
      initialHideCustomServer: _hideCustomServer,
      initialUsePassword: _useUsernameAndPassword,
      loginMode: _authMode == AuthMode.login,
      serverUrlController: _serverUrlController,
      onChanged: (hideCustomServer, usePassword) {
        setState(() {
          _hideCustomServer = hideCustomServer;
          _useUsernameAndPassword = usePassword;
        });
      },
    ).then((_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final i18n = AppLocalizations.of(context);
    final deviceSize = MediaQuery.sizeOf(context);
    // Login/registration both need the server, so disable the action while
    // there is no connectivity.
    final isOnline = ref.watch(networkStatusProvider);

    Widget errorMessage = const SizedBox.shrink();
    if (_httpError != null) {
      errorMessage = FormHttpErrorsWidget(_httpError!);
    } else if (_showNetworkError) {
      errorMessage = Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(
          i18n.errorCouldNotConnectToServer,
          textAlign: TextAlign.center,
          style: TextStyle(color: Theme.of(context).colorScheme.error),
        ),
      );
    }

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
          autovalidateMode: _autoValidate
              ? AutovalidateMode.onUserInteraction
              : AutovalidateMode.disabled,
          child: SingleChildScrollView(
            child: AutofillGroup(
              child: Column(
                children: [
                  errorMessage,
                  if (_useUsernameAndPassword) UsernameField(controller: _usernameController),
                  if (_authMode == AuthMode.register) EmailField(controller: _emailController),
                  if (_useUsernameAndPassword)
                    PasswordField(
                      controller: _passwordController,
                      enforceMinLength: _authMode == AuthMode.register,
                    ),

                  if (_authMode == AuthMode.register)
                    ConfirmPasswordField(
                      controller: _password2Controller,
                      passwordController: _passwordController,
                    ),

                  if (_authMode == AuthMode.login && !_useUsernameAndPassword)
                    RefreshTokenField(controller: _refreshTokenController),

                  if (_authMode == AuthMode.login)
                    WebHandoffLink(
                      onTap: _isLoading ? null : _launchWebHandoff,
                    ),

                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 45,
                    child: ElevatedButton(
                      key: const Key('actionButton'),
                      onPressed: isOnline
                          ? () {
                              if (!_isLoading) {
                                _submit(context);
                              }
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation(Colors.white),
                            )
                          : Text(
                              _authMode == AuthMode.register
                                  ? i18n.register
                                  : (_useUsernameAndPassword ? i18n.login : i18n.signInWithToken),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 12),
                  AuthModeSwitchLink(
                    isLogin: _authMode == AuthMode.login,
                    onTap: _switchAuthMode,
                  ),
                  const SizedBox(height: 4),
                  AdvancedFooter(
                    isCustomServer: !_hideCustomServer,
                    isTokenMode: _authMode == AuthMode.login && !_useUsernameAndPassword,
                    serverUrl: _serverUrlController.text,
                    onTap: _showAdvancedSheet,
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
