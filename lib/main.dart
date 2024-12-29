import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_core/firebase_core.dart';
import './screens/onboard/onboarding.dart';
import 'homepage.dart';
import 'screens/roleSelection/roleSelection.dart';
import 'screens/student/registration.dart';
import 'screens/instructor/registration.dart';
import 'screens/instructor/login.dart';
import 'screens/student/login.dart';

// Initialize Firebase
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final GoRouter _router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => OnboardingPage(),
      ),
      GoRoute(
        path: '/role-selection',
        builder: (context, state) => RoleSelectionPage(),
        routes: [
          GoRoute(
            path: 'student',
            builder: (context, state) => StudentLoginPage(),
            routes: [
              GoRoute(
                path: 'registration',
                builder: (context, state) => StudentRegisterPage(),
              ),
              GoRoute(
                path: 'home',
                builder: (context, state) => HomePage(role: "student"),
              ),
            ],
          ),
          GoRoute(
            path: 'instructor',
            builder: (context, state) => InstructorLoginPage(),
            routes: [
              GoRoute(
                path: 'registration',
                builder: (context, state) => InstructorRegisterPage(),
              ),
              GoRoute(
                path: 'home',
                builder: (context, state) => HomePage(role: "instructor"),
              ),
            ],
          ),
        ],
      ),
    ],
  );
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Study App',
      routerConfig: _router,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
    );
  }
}

