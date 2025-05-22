import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wger/l10n/generated/app_localizations.dart';

class UsernameField extends StatelessWidget {
  final TextEditingController controller;
  final Function(String?) onSaved;

  const UsernameField({
    required this.controller,
    required this.onSaved,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      key: const Key('inputUsername'),
      decoration: InputDecoration(
        labelText: AppLocalizations.of(context).username,
        errorMaxLines: 2,
        prefixIcon: const Icon(Icons.account_circle),
      ),
      autofillHints: const [AutofillHints.username],
      controller: controller,
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
      onSaved: onSaved,
    );
  }
}
