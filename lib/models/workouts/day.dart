import 'package:flutter/foundation.dart';

class Day {
  final int id;
  final String description;
  List<int> daysOfWeek = [];

  Day({
    @required this.id,
    @required this.description,
    this.daysOfWeek,
  });
}
