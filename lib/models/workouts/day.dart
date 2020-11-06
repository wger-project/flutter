import 'package:flutter/foundation.dart';

class Muscle {
  final int id;
  final String description;
  final List<int> daysOfWeek;

  Muscle({
    @required this.id,
    @required this.description,
    @required this.daysOfWeek,
  });
}
