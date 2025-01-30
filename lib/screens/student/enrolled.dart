import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../course/StudentCourseDetailPage.dart';

class EnrolledCoursesPage extends StatelessWidget {
  final String studentId; // Pass the student's ID

  const EnrolledCoursesPage({Key? key, required this.studentId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print(studentId);
    print("-------");
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enrolled Courses', style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.indigo,
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
            return const Center(child: Text('No courses enrolled yet.', style: TextStyle(fontSize: 18, color: Colors.grey)));
          }

          final enrolledCourses = snapshot.data!.docs;

          return ListView.builder(
            itemCount: enrolledCourses.length,
            itemBuilder: (context, index) {
              final course = enrolledCourses[index];
              return Card(
                elevation: 8,
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: Icon(Icons.book, color: Colors.indigo, size: 40), // Custom Icon
                  title: Text(
                    course['title'] ?? 'Untitled Course',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo,
                    ),
                  ),
                  subtitle: Text(
                    'Enrolled on: ${course['enrolledAt']?.toDate() ?? 'Unknown date'}',
                    style: const TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, color: Colors.indigo), // Arrow to indicate navigation
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => StudentCourseDetailPage(
                          courseId: course['courseId'], // Pass the course ID
                          studentId: studentId,          // Pass the student ID
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
