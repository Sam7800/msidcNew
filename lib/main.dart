import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'utils/constants.dart';
import 'presentation/screens/splash_screen.dart';

void main() {
  runApp(const MSIDCApp());
}

class MSIDCApp extends StatelessWidget {
  const MSIDCApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: Constants.appFullName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}
