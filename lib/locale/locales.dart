/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (C) 2020 wger Team
 *
 * wger Workout Manager is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * wger Workout Manager is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

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

  String get successfullyDeleted {
    return Intl.message(
      'Successfully deleted',
      name: 'successfullyDeleted',
      desc: 'Message when an item was successfully deleted',
    );
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

  String get addMeal {
    return Intl.message(
      'Add meal',
      name: 'addMeal',
      desc: 'Header for form or label for button',
    );
  }

  String get labelWorkoutPlan {
    return Intl.message(
      'Workout plan',
      name: 'labelWorkoutPlan',
      desc: 'Title for screen workout plan',
    );
  }

  String get nutritionalPlan {
    return Intl.message(
      'Nutritional plan',
      name: 'nutritionalPlan',
      desc: 'Title for screen nutritional plan',
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

  String get weight {
    return Intl.message(
      'Weight',
      name: 'weight',
      desc: 'The weight of a workout log or body weight entry',
    );
  }

  String get date {
    return Intl.message(
      'Date',
      name: 'date',
      desc: 'The date of a workout log or body weight entry',
    );
  }

  String get time {
    return Intl.message(
      'Time',
      name: 'time',
      desc: 'The time of a meal or workout',
    );
  }

  String get ingredient {
    return Intl.message(
      'Ingredient',
      name: 'ingredient',
      desc: 'An ingredient',
    );
  }

  String get energy {
    return Intl.message(
      'Energy',
      name: 'energy',
      desc: 'Energy in a meal, e.g. in kJ',
    );
  }

  String get protein {
    return Intl.message(
      'Protein',
      name: 'protein',
      desc: 'Protein content',
    );
  }

  String get carbohydrates {
    return Intl.message(
      'Carbohydrates',
      name: 'carbohydrates',
      desc: 'Carbohydrates content',
    );
  }

  String get sugars {
    return Intl.message(
      'Sugars',
      name: 'sugars',
      desc: 'sugar content (out of the carbohydrates)',
    );
  }

  String get fat {
    return Intl.message(
      'Fat',
      name: 'fat',
      desc: 'Fat content',
    );
  }

  String get saturatedFat {
    return Intl.message(
      'Saturated fat',
      name: 'saturatedFat',
      desc: 'Saturated fat content (out of the fat)',
    );
  }

  String get amount {
    return Intl.message(
      'Amount',
      name: 'amount',
      desc: 'The amount (e.g. in grams) of an ingredient in a meal',
    );
  }

  String get newEntry {
    return Intl.message(
      'New entry',
      name: 'newEntry',
      desc: 'Header when adding a new entry such as a weight or log entry',
    );
  }

  String get newNutritionalPlan {
    return Intl.message(
      'New nutritional plan',
      name: 'newNutritionalPlan',
      desc: 'Header when adding a new nutritional plan',
    );
  }

  String get toggleDetails {
    return Intl.message(
      'Toggle details',
      name: 'toggleDetails',
      desc: 'Switch to toggle detail / overview',
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
