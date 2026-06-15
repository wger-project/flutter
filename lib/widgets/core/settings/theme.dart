import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/providers/app_settings_notifier.dart';

class SettingsTheme extends ConsumerWidget {
  const SettingsTheme({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final i18n = AppLocalizations.of(context);
    final currentMode = ref.watch(
      appSettingsProvider.select((s) => s.value?.themeMode ?? ThemeMode.system),
    );

    return ListTile(
      title: Text(i18n.themeMode),
      trailing: DropdownButton<ThemeMode>(
        key: const ValueKey('themeModeDropdown'),
        value: currentMode,
        onChanged: (ThemeMode? newValue) {
          if (newValue != null) {
            ref.read(appSettingsProvider.notifier).setThemeMode(newValue);
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
