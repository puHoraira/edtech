import 'package:edtech/privacy_policy.dart';
import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'about_us.dart';
import 'login_screen.dart';
import 'welcome_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'edtech',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      // Set HomeScreen as the initial screen
      home: const HomeScreen(),
      // Define routes for navigation
      routes: {
        '/about': (context) => AboutUs(),
        '/login': (context) => const LoginScreen(),
        '/privacy': (context) => const PrivacyPolicy(), // New route for Privacy Policy
      },

    );
  }
}
