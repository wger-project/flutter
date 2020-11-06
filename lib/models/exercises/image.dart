import 'package:flutter/foundation.dart';

class Image {
  final int id;
  final String url;
  final String author;
  final bool isMain;

  Image({
    @required this.id,
    @required this.url,
    @required this.isMain,
    @required this.author,
  });
}
