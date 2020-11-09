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
  List<Muscle> muscles = [];
  List<Muscle> musclesSecondary = [];
  List<Equipment> equipment = [];
  List<img.Image> images = [];
  List<Comment> tips = [];

  Exercise({
    @required this.id,
    @required this.uuid,
    @required this.creationDate,
    @required this.name,
    @required this.description,
    this.category,
    this.muscles,
    this.musclesSecondary,
    this.equipment,
    this.images,
    this.tips,
  });

  img.Image get getMainImage {
    return images.firstWhere((image) => image.isMain);
  }
}
