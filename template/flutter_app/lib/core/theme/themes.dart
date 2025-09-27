import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'palette.dart';

final class Themes {
  static final ThemeData light = ThemeData(
    extensions: [Palette.light],
    brightness: Brightness.light,
    cupertinoOverrideTheme: CupertinoThemeData(
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: Palette.light.background,
  );
  static final ThemeData dark = ThemeData(
    extensions: [Palette.dark],
    brightness: Brightness.dark,
    cupertinoOverrideTheme: CupertinoThemeData(
      brightness: Brightness.dark,
    ),
    scaffoldBackgroundColor: Palette.dark.background,
  );
}
