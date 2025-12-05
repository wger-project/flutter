import 'package:flutter/material.dart';
import 'package:wger/l10n/generated/app_localizations.dart';

class PasswordField extends StatefulWidget {
  final TextEditingController controller;
  final Function(String?) onSaved;

  const PasswordField({
    required this.controller,
    required this.onSaved,
    super.key,
  });

  @override
  _PasswordFieldState createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool isObscure = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      key: const Key('inputPassword'),
      autofillHints: const [AutofillHints.password],
      decoration: InputDecoration(
        labelText: AppLocalizations.of(context).password,
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
      validator: (value) {
        if (value == null || value.isEmpty || value.length < 8) {
          return AppLocalizations.of(context).passwordTooShort;
        }
        return null;
      },
      onSaved: widget.onSaved,
    );
  }
}
