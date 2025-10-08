import 'package:flutter/material.dart';
import 'package:wger/core/validators.dart';
import 'package:wger/l10n/generated/app_localizations.dart';

class ServerField extends StatelessWidget {
  final TextEditingController controller;
  final Function(String?) onSaved;

  const ServerField({required this.controller, required this.onSaved, super.key});

  @override
  Widget build(BuildContext context) {
    final i18n = AppLocalizations.of(context);

    return TextFormField(
      key: const Key('inputServer'),
      decoration: InputDecoration(
        labelText: i18n.customServerUrl,
        helperText: i18n.customServerHint,
        helperMaxLines: 4,
      ),
      controller: controller,
      validator: (value) => validateUrl(value, i18n, required: true),
      onSaved: onSaved,
    );
  }
}
