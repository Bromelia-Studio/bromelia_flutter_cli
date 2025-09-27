import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/home/presentation/pages/home_page.dart';


final router = GoRouter(
  initialLocation: HomePage.route,
  routes: <RouteBase>[
    GoRoute(
      path: HomePage.route,
      builder: (BuildContext context, GoRouterState state) {
        return HomePage(key: state.pageKey);
      },
    ),
  ],
);
