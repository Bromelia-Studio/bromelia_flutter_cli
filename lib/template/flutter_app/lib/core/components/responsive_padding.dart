import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';

class ResponsivePadding extends StatelessWidget {
  final Widget child;

  const ResponsivePadding({super.key, required this.child});

  double _horizontalPadding(
    BuildContext context, {
    double quotient = 0.8,
    double mobilePadding = 0,
  }) {
    bool portrait = MediaQuery.of(context).orientation == Orientation.portrait;
    double constraintPadding =
        MediaQuery.of(context).size.width * (1 - quotient) / 2;
    return getValueForScreenType(
      context: context,
      mobile: mobilePadding,
      tablet: portrait ? mobilePadding : constraintPadding,
      desktop: constraintPadding,
      watch: mobilePadding,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: _horizontalPadding(context),
      ),
      child: child,
    );
  }
}
