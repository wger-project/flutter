import 'package:flutter/foundation.dart';
import 'package:wger/models/exercises/category.dart' as cat;
import 'package:wger/models/exercises/comment.dart';
import 'package:wger/models/exercises/equipment.dart';
import 'package:wger/models/exercises/image.dart' as img;
import 'package:wger/models/exercises/muscle.dart';

class Exercise {
  final int id;
  final String uuid;
  final DateTime creationDate;
  final String name;
  final String description;
  final cat.Category category;
  final List<Muscle> muscles;
  final List<Muscle> musclesSecondary;
  final List<Equipment> equipment;
  final List<img.Image> images;
  final List<Comment> tips;

  Exercise({
    @required this.id,
    @required this.uuid,
    @required this.creationDate,
    @required this.name,
    @required this.description,
    @required this.category,
    @required this.muscles,
    this.musclesSecondary,
    @required this.equipment,
    this.images,
    this.tips,
  });
}
