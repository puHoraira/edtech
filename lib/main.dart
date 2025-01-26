import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import './screens/onboard/onboarding.dart';
import './homepage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EdTech',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: AuthHandler(), // Redirect logic based on user login status
    );
  }
}

class AuthHandler extends StatelessWidget {

  Future<Map<String, String>> getUserRoleAndId() async {
    User? user = FirebaseAuth.instance.currentUser;
    print(user);

    if (user != null) {
      // Fetch user details from Firestore
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        // Convert `userId` to String if stored as a number
        String role = userDoc['role'];
        String userId = userDoc['userId'].toString(); // Ensure `userId` is a String
        print("ekahnea achi ami2");
        print(role);
        print(userId);
        return {'role': role, 'userId': userId};
      }
    }

    return {}; // Return an empty map if no user is logged in
  }

  @override
  Widget build(BuildContext context) {
    print("ekio");
    return FutureBuilder<Map<String, String>>(
      future: getUserRoleAndId(),
      builder: (context, snapshot) {

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          final role = snapshot.data!['role']!;
          final userId = snapshot.data!['userId']!;
          print(role);
          print(userId);

          return HomePage(role: role, userId: userId); // Pass role and userId to HomePage
        } else {
          return OnboardingPage(); // Redirect to onboarding if no user is logged in
        }
      },
    );
  }
}
