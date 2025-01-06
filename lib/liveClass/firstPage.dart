import 'package:flutter/material.dart';
import 'instructor.dart';  // Import InstructorPage
import 'student.dart';     // Import StudentPage

class FirstPage extends StatelessWidget {
  const FirstPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Video Conference")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                // Navigate to the Instructor Page
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const InstructorPage()),
                );
              },
              child: const Text("Instructor"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Navigate to the Student Page
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const StudentPage()),
                );
              },
              child: const Text("Student"),
            ),
          ],
        ),
      ),
    );
  }
}
