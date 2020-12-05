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

  String get newWorkout {
    return Intl.message(
      'New Workout',
      name: 'newWorkout',
      desc: 'Header when adding a new workout',
    );
  }

  String get newDay {
    return Intl.message(
      'New day',
      name: 'newDay',
      desc: 'Header when adding a new day to a workout',
    );
  }

  String get newSet {
    return Intl.message(
      'New set',
      name: 'newSet',
      desc: 'Header when adding a new set to a workout day',
    );
  }

  String get description {
    return Intl.message(
      'Description',
      name: 'description',
      desc: 'Description of a workout, nutritional plan, etc.',
    );
  }

  String get save {
    return Intl.message(
      'Save',
      name: 'save',
      desc: 'Saving a new entry in the DB',
    );
  }

  String get cancel {
    return Intl.message(
      'Cancel',
      name: 'cancel',
      desc: 'Cancelling an action',
    );
  }

  String get add {
    return Intl.message(
      'Add',
      name: 'add',
      desc: 'Label for a button etc.',
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

  String get anErrorOccurred {
    return Intl.message(
      'An Error Occurred!',
      name: 'anErrorOccurred',
      desc: 'Title for error popups',
    );
  }

  String get dismiss {
    return Intl.message(
      'Dismiss',
      name: 'dismiss',
      desc: 'Button to close a dialog',
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
