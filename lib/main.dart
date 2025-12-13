import 'package:flutter/material.dart';

import 'navigation/main_navigation.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const LoginScreen(),
      routes: {
        MainNavigation.routeName: (_) => const MainNavigation(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
