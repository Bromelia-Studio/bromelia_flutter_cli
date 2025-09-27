import 'package:flutter/material.dart';

import '../../../../core/theme/palette.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static const String route = '/';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Hello World! 🌺',
          style: TextStyle(
            color: context.palette.onBackground,
            fontSize: 24,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
