import 'package:flutter/widgets.dart';


void runAfterFrame(VoidCallback callback) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    callback();
  });
}