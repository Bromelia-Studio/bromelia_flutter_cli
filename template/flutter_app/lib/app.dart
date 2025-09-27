import 'package:flutter/material.dart';

import 'core/navigation/router.dart';
import 'core/theme/themes.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: router,
      theme: Themes.light,
      darkTheme: Themes.dark,
    );
  }
}
