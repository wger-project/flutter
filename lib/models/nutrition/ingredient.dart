import 'package:flutter/foundation.dart';

class Ingredient {
  final int id;
  final String name;
  final DateTime creationDate;
  final int energy;
  final double carbohydrates;
  final double carbohydrates_sugar;
  final double fat;
  final double fat_saturated;
  final double fibres;

  Ingredient({
    @required this.id,
    @required this.name,
    @required this.creationDate,
    @required this.energy,
    @required this.carbohydrates,
    @required this.carbohydrates_sugar,
    @required this.fat,
    @required this.fat_saturated,
    @required this.fibres,
  });
}
