// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'palette.dart';

// **************************************************************************
// TailorAnnotationsGenerator
// **************************************************************************

mixin _$PaletteTailorMixin on ThemeExtension<Palette> {
  Color get background;
  Color get onBackground;

  @override
  Palette copyWith({Color? background, Color? onBackground}) {
    return Palette(
      background: background ?? this.background,
      onBackground: onBackground ?? this.onBackground,
    );
  }

  @override
  Palette lerp(covariant ThemeExtension<Palette>? other, double t) {
    if (other is! Palette) return this as Palette;
    return Palette(
      background: Color.lerp(background, other.background, t)!,
      onBackground: Color.lerp(onBackground, other.onBackground, t)!,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is Palette &&
            const DeepCollectionEquality().equals(
              background,
              other.background,
            ) &&
            const DeepCollectionEquality().equals(
              onBackground,
              other.onBackground,
            ));
  }

  @override
  int get hashCode {
    return Object.hash(
      runtimeType.hashCode,
      const DeepCollectionEquality().hash(background),
      const DeepCollectionEquality().hash(onBackground),
    );
  }
}

extension PaletteBuildContext on BuildContext {
  Palette get palette => Theme.of(this).extension<Palette>()!;
}
