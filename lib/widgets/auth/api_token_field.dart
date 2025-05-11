import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wger/l10n/generated/app_localizations.dart';

class ApiTokenField extends StatefulWidget {
  final TextEditingController controller;
  final Function(String?) onSaved;

  const ApiTokenField({
    required this.controller,
    required this.onSaved,
    super.key,
  });

  @override
  State<ApiTokenField> createState() => _ApiTokenFieldState();
}

class _ApiTokenFieldState extends State<ApiTokenField> {
  bool isObscure = true;

  @override
  Widget build(BuildContext context) {
    final i18n = AppLocalizations.of(context);

    return TextFormField(
      key: const ValueKey('inputApiToken'),
      decoration: InputDecoration(
        labelText: i18n.apiToken,
        helperText:
            'Only needed when using an authentication proxy for the backend, please consult the documentation',
        errorMaxLines: 2,
        helperMaxLines: 2,
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
          return i18n.invalidApiToken;
        }
        if (!RegExp(r'^[a-f0-9]{40}$').hasMatch(value)) {
          return i18n.apiTokenValidChars;
        }
        return null;
      },
      inputFormatters: [
        FilteringTextInputFormatter.deny(RegExp(r'\s\b|\b\s')),
      ],
      onSaved: widget.onSaved,
    );
  }
}
