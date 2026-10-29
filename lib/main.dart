import 'package:flutter/material.dart';
import 'theme/robin_theme.dart';
import 'screens/login_screen.dart';
import 'widgets/app_zoom.dart';

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
      builder: (context, child) => AppZoom(
        child: child ?? const SizedBox.shrink(),
      ),
      home: const LoginScreen(),
    );
  }
}
