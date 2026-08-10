/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (c) 2026 wger Team
 *
 * wger Workout Manager is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

/// A short date format (`DateFormat.yMd`) bound to the current locale's
/// language. Chain further patterns (e.g. `.add_Hm()`) as needed.
DateFormat localizedDate(BuildContext context) =>
    DateFormat.yMd(Localizations.localeOf(context).languageCode);

/// A decimal number format bound to the current locale.
NumberFormat localizedNumberFormat(BuildContext context) =>
    NumberFormat.decimalPattern(Localizations.localeOf(context).toString());
