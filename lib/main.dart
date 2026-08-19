import 'package:flutter/material.dart';
import 'theme/robin_theme.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const RobinPortalApp());
}

class RobinPortalApp extends StatelessWidget {
  const RobinPortalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ROBIN 대리점 포털',
      debugShowCheckedModeBanner: false,
      theme: RobinTheme.theme,
      home: const LoginScreen(),
    );
  }
}
