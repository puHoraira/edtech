
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EnrolledCoursesPage extends StatelessWidget {
  final String studentId; // Pass the student's ID

  const EnrolledCoursesPage({Key? key, required this.studentId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enrolled Courses'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('enrollment')
            .where('studentId', isEqualTo: studentId)
            .orderBy('enrolledAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No courses enrolled yet.'));
          }

          final enrolledCourses = snapshot.data!.docs;

          return ListView.builder(
            itemCount: enrolledCourses.length,
            itemBuilder: (context, index) {
              final course = enrolledCourses[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  title: Text(course['title'] ?? 'Untitled Course'),
                  subtitle: Text('Enrolled on: ${course['enrolledAt']?.toDate() ?? 'Unknown date'}'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
