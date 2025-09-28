import 'package:flutter/material.dart';

import '../../../../core/components/responsive_padding.dart';
import '../../../../core/localization/generated/l10n.dart';
import '../../../../core/theme/palette.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static const String route = 'home';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ResponsivePadding(
        child: Center(
          child: Text(
            S.of(context).helloWorld,
            style: TextStyle(
              color: context.palette.onBackground,
              fontSize: 18,
            ),
          ),
        ),
      ),
    );
  }
}
