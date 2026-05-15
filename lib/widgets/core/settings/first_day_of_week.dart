import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/providers/user.dart';

class SettingsFirstDayOfWeek extends StatelessWidget {
  const SettingsFirstDayOfWeek({super.key});

  @override
  Widget build(BuildContext context) {
    final i18n = AppLocalizations.of(context);
    final userProvider = Provider.of<UserProvider>(context);

    return ListTile(
      title: Text(i18n.firstDayOfWeek),
      trailing: DropdownButton<StartingDayOfWeek>(
        key: const ValueKey('firstDayOfWeekDropdown'),
        value: userProvider.firstDayOfWeek,
        onChanged: (StartingDayOfWeek? newValue) {
          if (newValue != null) {
            userProvider.setFirstDayOfWeek(newValue);
          }
        },
        items:
            [
              StartingDayOfWeek.monday,
              StartingDayOfWeek.sunday,
              StartingDayOfWeek.saturday,
            ].map<DropdownMenuItem<StartingDayOfWeek>>((StartingDayOfWeek value) {
              final label = _getDayLabel(value, i18n);
              return DropdownMenuItem<StartingDayOfWeek>(value: value, child: Text(label));
            }).toList(),
      ),
    );
  }

  String _getDayLabel(StartingDayOfWeek day, AppLocalizations i18n) {
    switch (day) {
      case StartingDayOfWeek.monday:
        return i18n.monday;
      case StartingDayOfWeek.sunday:
        return i18n.sunday;
      case StartingDayOfWeek.saturday:
        return i18n.saturday;
      default:
        return i18n.monday;
    }
  }
}
