import 'package:flutter/material.dart';
import 'package:wger/l10n/generated/app_localizations.dart';

class ServerField extends StatelessWidget {
  final TextEditingController controller;
  final Function(String?) onSaved;

  const ServerField({
    required this.controller,
    required this.onSaved,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      key: const Key('inputServer'),
      decoration: InputDecoration(
        labelText: AppLocalizations.of(context).customServerUrl,
        helperText: AppLocalizations.of(context).customServerHint,
        helperMaxLines: 4,
      ),
      controller: controller,
      validator: (value) {
        if (Uri.tryParse(value!) == null) {
          return AppLocalizations.of(context).invalidUrl;
        }

        if (value.isEmpty || !value.contains('http')) {
          return AppLocalizations.of(context).invalidUrl;
        }
        return null;
      },
      onSaved: onSaved,
    );
  }
}
