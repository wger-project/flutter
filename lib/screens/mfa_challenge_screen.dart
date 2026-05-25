/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (c) 2026 - 2026 wger Team
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

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wger/core/error_dialogs.dart';
import 'package:wger/core/exceptions/http_exception.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/providers/auth_notifier.dart';
import 'package:wger/providers/auth_state.dart';
import 'package:wger/screens/update_app_screen.dart';
import 'package:wger/screens/update_server_screen.dart';

/// Screen shown when `auth/login` reports a pending second-factor challenge.
/// Collects either a TOTP code or one of the user's recovery codes and
/// calls [AuthNotifier.completeMfa]; on success the auth state flips to
/// loggedIn and the app routes back to the main UI.
class MfaChallengeScreen extends ConsumerStatefulWidget {
  final String sessionToken;
  final String serverUrl;
  final List<String> availableFactors;

  const MfaChallengeScreen({
    super.key,
    required this.sessionToken,
    required this.serverUrl,
    required this.availableFactors,
  });

  static const routeName = '/mfa-challenge';

  @override
  ConsumerState<MfaChallengeScreen> createState() => _MfaChallengeScreenState();
}

class _MfaChallengeScreenState extends ConsumerState<MfaChallengeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  bool _isRecoveryMode = false;
  bool _isLoading = false;
  Widget _errorMessage = const SizedBox.shrink();

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  bool get _supportsTotp => widget.availableFactors.contains('totp');
  bool get _supportsRecovery => widget.availableFactors.contains('recovery_codes');
  bool get _canChallengeLocally => _supportsTotp || _supportsRecovery;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() {
      _isLoading = true;
      _errorMessage = const SizedBox.shrink();
    });
    try {
      final res = await ref
          .read(authProvider.notifier)
          .completeMfa(
            sessionToken: widget.sessionToken,
            code: _codeController.text.trim(),
            serverUrl: widget.serverUrl,
          );

      if (res == LoginActions.update && mounted) {
        final status = ref.read(authProvider).value?.status;
        if (status == AuthStatus.appUpdateRequired) {
          await Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const UpdateAppScreen()),
          );
          return;
        } else if (status == AuthStatus.serverUpdateRequired) {
          await Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const UpdateServerScreen()),
          );
          return;
        }
      }

      // Happy path: pop back to the auth screen, which itself unmounts
      // once the auth state flips to loggedIn.
      if (mounted) {
        Navigator.of(context).pop();
      }
    } on WgerHttpException catch (error) {
      if (mounted) {
        setState(() {
          _errorMessage = FormHttpErrorsWidget(error);
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final i18n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(i18n.mfaChallengeTitle)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: _canChallengeLocally
              ? _buildChallengeForm(context, i18n)
              : _buildUnsupportedFallback(context, i18n),
        ),
      ),
    );
  }

  Widget _buildChallengeForm(BuildContext context, AppLocalizations i18n) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            _isRecoveryMode ? i18n.mfaChallengeRecoveryPrompt : i18n.mfaChallengeTotpPrompt,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 16),
          TextFormField(
            key: const ValueKey('inputMfaCode'),
            controller: _codeController,
            autofocus: true,
            decoration: InputDecoration(
              labelText: i18n.mfaCodeLabel,
              prefixIcon: const Icon(Icons.lock_outline),
            ),
            keyboardType: _isRecoveryMode ? TextInputType.text : TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'\s'))],
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _submit(),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return i18n.mfaInvalidCode;
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          _errorMessage,
          const SizedBox(height: 16),
          ElevatedButton(
            key: const Key('mfaSubmitButton'),
            onPressed: _isLoading ? null : _submit,
            child: _isLoading
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(i18n.mfaSubmit),
          ),
          if (_supportsTotp && _supportsRecovery) ...[
            const SizedBox(height: 8),
            TextButton(
              key: const Key('mfaToggleModeButton'),
              onPressed: _isLoading
                  ? null
                  : () => setState(() {
                      _isRecoveryMode = !_isRecoveryMode;
                      _codeController.clear();
                    }),
              child: Text(_isRecoveryMode ? i18n.mfaUseTotpCode : i18n.mfaUseRecoveryCode),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildUnsupportedFallback(BuildContext context, AppLocalizations i18n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Icon(Icons.lock_outline, size: 48, color: Theme.of(context).colorScheme.error),
        const SizedBox(height: 16),
        Text(i18n.mfaUnsupportedFactor, style: Theme.of(context).textTheme.bodyLarge),
      ],
    );
  }
}
