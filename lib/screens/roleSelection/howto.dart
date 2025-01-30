import 'package:flutter/material.dart';

class HowToUsePage extends StatelessWidget {
  const HowToUsePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('How to Use', style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            const Text(
              'Welcome to EdTech! Here\'s how to get started:',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            _buildSectionTitle('1. Registration'),
            const Text(
              'To start using the app, you need to register. Simply enter your email address and create a password. You can register as a student or an instructor depending on your role.',
            ),
            const SizedBox(height: 20),
            _buildSectionTitle('2. Browse and Enroll in Courses'),
            const Text(
              'Explore the wide range of courses offered by our instructors. You can browse courses by category and enroll in those you are interested in.',
            ),
            const SizedBox(height: 20),
            _buildSectionTitle('3. Join Live Classes'),
            const Text(
              'Once enrolled, you can join live classes hosted by your instructors. Make sure to be on time for the sessions.',
            ),
            const SizedBox(height: 20),
            _buildSectionTitle('4. Participate in Quizzes'),
            const Text(
              'Teachers will launch quizzes in each course section. Make sure to check the course details to stay updated on the quiz schedule.',
            ),
            const SizedBox(height: 20),
            _buildSectionTitle('5. View Leaderboard'),
            const Text(
              'After completing quizzes, check the leaderboard to see how you rank compared to other students.',
            ),
            const SizedBox(height: 20),
            _buildSectionTitle('6. Chat with Instructors and Students'),
            const Text(
              'You can communicate with instructors and fellow students through the chat feature to ask questions and discuss course materials.',
            ),
            const SizedBox(height: 20),
            _buildSectionTitle('7. Access Course Materials'),
            const Text(
              'You will have access to course materials, including lecture notes, recordings, and additional resources shared by instructors.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.blue,
      ),
    );
  }
}
