import 'package:flutter/foundation.dart';

class Exercise with ChangeNotifier {
  final int id;
  final String uuid;
  final DateTime creation_date;
  final String name;
  final String description;
  final String category;
  final List<String> muscles;
  final List<String> muscles_secondary;
  final List<String> equipment;

  Exercise({
    this.id,
    this.uuid,
    this.creation_date,
    this.name,
    this.description,
    this.category,
    this.muscles,
    this.muscles_secondary,
    this.equipment,
  });
}
