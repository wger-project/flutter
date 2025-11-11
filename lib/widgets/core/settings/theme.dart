import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/providers/user.dart';

class SettingsTheme extends StatelessWidget {
  const SettingsTheme({super.key});

  @override
  Widget build(BuildContext context) {
    final i18n = AppLocalizations.of(context);
    final userProvider = Provider.of<UserProvider>(context);

    return ListTile(
      title: Text(i18n.themeMode),
      trailing: DropdownButton<ThemeMode>(
        key: const ValueKey('themeModeDropdown'),
        value: userProvider.themeMode,
        onChanged: (ThemeMode? newValue) {
          if (newValue != null) {
            userProvider.setThemeMode(newValue);
          }
        },
        items: ThemeMode.values.map<DropdownMenuItem<ThemeMode>>((ThemeMode value) {
          final label = (() {
            switch (value) {
              case ThemeMode.system:
                return i18n.systemMode;
              case ThemeMode.light:
                return i18n.lightMode;
              case ThemeMode.dark:
                return i18n.darkMode;
            }
          })();

          return DropdownMenuItem<ThemeMode>(value: value, child: Text(label));
        }).toList(),
      ),
    );
  }
}
