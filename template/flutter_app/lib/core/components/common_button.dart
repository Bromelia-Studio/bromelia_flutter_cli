import 'package:flutter/material.dart';

import '../theme/palette.dart';

class CommonButton extends StatelessWidget {
  const CommonButton({
    super.key,
    required this.onPressed,
    required this.titleText,
  });

  final VoidCallback? onPressed;
  final String titleText;

  @override
  Widget build(BuildContext context) {
    return FilledButton.tonal(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: context.palette.onBackground.withAlpha(15),
      ),
      child: Text(
        titleText,
        style: TextStyle(
          color: context.palette.onBackground,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
