import 'package:intl/intl.dart';

num toNum(String e) {
  return num.parse(e);
}

String toString(num e) {
  return e.toString();
}

/*
 * Converts a datetime to ISO8601 date format, but only the date.
 * Needed e.g. when the wger api only expects a date and no time information.
 */
String toDate(DateTime dateTime) {
  return DateFormat('yyyy-MM-dd').format(dateTime).toString();
}
