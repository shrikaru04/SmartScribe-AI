import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'screens/onboarding/onboarding_screen.dart';

void main() {
  runApp(const SmartScribeApp());
}

class SmartScribeApp extends StatelessWidget {
  const SmartScribeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SmartScribe AI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const OnboardingScreen(),
    );
  }
}
