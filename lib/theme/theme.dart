import 'package:flutter/material.dart';

const Color wgerPrimaryColor = Color(0xff2a4c7d);
const Color wgerSecondaryColor = Color(0xffe63946);

final ThemeData wgerTheme = ThemeData(
  primaryColor: wgerPrimaryColor,
  accentColor: wgerSecondaryColor,
  //fontFamily: 'OpenSansLight',
  // This makes the visual density adapt to the platform that you run
  // the app on. For desktop platforms, the controls will be smaller and
  // closer together (more dense) than on mobile platforms.
  visualDensity: VisualDensity.adaptivePlatformDensity,
);
