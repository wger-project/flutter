import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wger/l10n/generated/app_localizations.dart';

/// Three dot-separated base64url segments: the standard JWT shape, which
/// covers the refresh tokens issued by `allauth.headless`. Permissive on
/// length so future format changes do not lock users out.
final RegExp _jwtShape = RegExp(r'^[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+$');

class RefreshTokenField extends StatefulWidget {
  final TextEditingController controller;
  final Function(String?) onSaved;

  const RefreshTokenField({required this.controller, required this.onSaved, super.key});

  @override
  State<RefreshTokenField> createState() => _RefreshTokenFieldState();
}

class _RefreshTokenFieldState extends State<RefreshTokenField> {
  bool isObscure = true;

  @override
  Widget build(BuildContext context) {
    final i18n = AppLocalizations.of(context);

    return TextFormField(
      key: const ValueKey('inputRefreshToken'),
      decoration: InputDecoration(
        labelText: i18n.refreshToken,
        helperText: i18n.refreshTokenHelperText,
        errorMaxLines: 2,
        helperMaxLines: 3,
        prefixIcon: const Icon(Icons.password),
        suffixIcon: IconButton(
          icon: Icon(isObscure ? Icons.visibility_off : Icons.visibility),
          onPressed: () {
            setState(() {
              isObscure = !isObscure;
            });
          },
        ),
      ),
      obscureText: isObscure,
      controller: widget.controller,
      textInputAction: TextInputAction.next,
      keyboardType: TextInputType.emailAddress,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return i18n.invalidRefreshToken;
        }
        if (!_jwtShape.hasMatch(value)) {
          return i18n.refreshTokenValidChars;
        }
        return null;
      },
      inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'\s'))],
      onSaved: widget.onSaved,
    );
  }
}
