import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wger/l10n/messages_all.dart';

class AppLocalizations {
  static Future<AppLocalizations> load(Locale locale) {
    final String name = locale.countryCode.isEmpty ? locale.languageCode : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);

    return initializeMessages(localeName).then((bool _) {
      Intl.defaultLocale = localeName;
      return AppLocalizations();
    });
  }

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  String get labelWorkoutPlans {
    return Intl.message(
      'Workout plans',
      name: 'labelWorkoutPlans',
      desc: 'Title for screen workout plans',
    );
  }

  String get labelWorkoutPlan {
    return Intl.message(
      'Workout plan',
      name: 'labelWorkoutPlan',
      desc: 'Title for screen workout plan',
    );
  }

  String get labelDashboard {
    return Intl.message(
      'Dashboard',
      name: 'labelDashboard',
      desc: 'Title for screen dashboard',
    );
  }
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'de'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) {
    return AppLocalizations.load(locale);
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) {
    return false;
  }
}
