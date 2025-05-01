import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wger/l10n/generated/app_localizations.dart';

class EmailField extends StatelessWidget {
  final TextEditingController controller;
  final Function(String?) onSaved;

  const EmailField({
    required this.controller,
    required this.onSaved,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      key: const Key('inputEmail'),
      decoration: InputDecoration(
        labelText: AppLocalizations.of(context).email,
        errorMaxLines: 2,
        prefixIcon: const Icon(Icons.email),
      ),
      controller: controller,
      textInputAction: TextInputAction.next,
      keyboardType: TextInputType.emailAddress,
      // Email is not required
      validator: (value) {
        if (value!.isNotEmpty && !value.contains('@')) {
          return AppLocalizations.of(context).invalidEmail;
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
