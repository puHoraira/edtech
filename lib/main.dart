import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import './screens/onboard/onboarding.dart';
import 'firebase_options.dart';
import 'homepage.dart';
import 'screens/roleSelection/roleSelection.dart';
import 'screens/student/registration.dart';
import 'screens/instructor/registration.dart';
import 'screens/instructor/login.dart';
import 'screens/student/login.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();

    print('Initializing Firebase...'); // Debug print
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('Firebase initialized successfully'); // Debug print

    // Configure Firebase Storage without await
    FirebaseStorage.instance.setMaxUploadRetryTime(const Duration(seconds: 5));
    print('Firebase Storage configured'); // Debug print
    print("Stat");
    runApp(MyApp());
  } catch (e) {
    print('Error in initialization: $e'); // Debug print
  }
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
      debugShowCheckedModeBanner: false, // Removes the debug banner
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
    );
  }
}