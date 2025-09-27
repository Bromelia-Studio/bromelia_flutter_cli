import 'package:theme_tailor_annotation/theme_tailor_annotation.dart';
import 'package:flutter/material.dart';

part 'palette.tailor.dart';

@TailorMixin(themeGetter: ThemeGetter.onBuildContext)
final class Palette extends ThemeExtension<Palette> with _$PaletteTailorMixin {
  Palette({
    required this.background,
    required this.onBackground,
  });

  @override
  final Color background;
  @override
  final Color onBackground;

  static final Palette light = Palette(
    background: Colors.white,
    onBackground: Colors.black,
  );
  static final Palette dark = Palette(
    background: Colors.black,
    onBackground: Colors.white,
  );
}
