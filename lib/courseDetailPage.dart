import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'launchNewClass.dart';
import 'launchNewQuiz.dart';
import 'viewPreviousClasses.dart';
import 'viewPreviousQuiz.dart';

class CourseDetailPage extends StatelessWidget {
  final String courseId;
  final String instructorId;

  const CourseDetailPage({
    Key? key,
    required this.courseId,
    required this.instructorId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        title: const Text(
          'Course Details',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('courses').doc(courseId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(
              child: Text(
                'Course not found.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          final courseData = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Course Details Card
                  _buildCourseCard(courseData),
                  const SizedBox(height: 16),

                  // Total Enrollments Section
                  _buildEnrollmentsSection(context),
                  const SizedBox(height: 16),

                  // Actions Grid
                  _buildActionGrid(context),

                  const SizedBox(height: 16),

                  // Enrolled Students Section
                  const Text(
                    'Enrolled Students',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  _buildEnrolledStudentsList(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCourseCard(DocumentSnapshot courseData) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              courseData['title'] ?? 'Untitled Course',
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.indigo,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              courseData['description'] ?? 'No description available.',
              style: const TextStyle(fontSize: 18, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnrollmentsSection(BuildContext context) {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance
          .collection('enrollment')
          .where('courseId', isEqualTo: courseId)
          .get(),
      builder: (context, enrollmentSnapshot) {
        if (enrollmentSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!enrollmentSnapshot.hasData || enrollmentSnapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text(
              'Total Enrollments: 0',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          );
        }

        final totalEnrollments = enrollmentSnapshot.data!.docs.length;
        return Text(
          'Total Enrollments: $totalEnrollments',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.indigo,
          ),
        );
      },
    );
  }

  Widget _buildActionGrid(BuildContext context) {
    final actions = [
      {
        'icon': Icons.video_call,
        'label': 'New Class',
        'page': LaunchNewClassPage(courseId: courseId, instructorId: instructorId),
      },
      {
        'icon': Icons.quiz,
        'label': 'New Quiz',
        'page': LaunchNewQuizPage(courseId: courseId, instructorId: instructorId),
      },
      {
        'icon': Icons.class_,
        'label': 'Previous Classes',
        'page': ViewPreviousClassesPage(courseId: courseId),
      },
      {
        'icon': Icons.history,
        'label': 'Previous Quizzes',
        'page': ViewPreviousQuizzesPage(courseId: courseId),
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
      ),
      itemCount: actions.length,
      itemBuilder: (context, index) {
        final action = actions[index];
        return ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.indigo,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            padding: const EdgeInsets.all(16),
          ),
          icon: Icon(action['icon'] as IconData, size: 36, color: Colors.white),
          label: Text(
            action['label'] as String,
            style: const TextStyle(fontSize: 16, color: Colors.white),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => action['page'] as Widget),
            );
          },
        );
      },
    );
  }

  Widget _buildEnrolledStudentsList() {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance
          .collection('enrollment')
          .where('courseId', isEqualTo: courseId)
          .get(),
      builder: (context, studentSnapshot) {
        if (studentSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!studentSnapshot.hasData || studentSnapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text(
              'No students enrolled.',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          );
        }

        final enrolledStudents = studentSnapshot.data!.docs;
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: enrolledStudents.length,
          itemBuilder: (context, index) {
            final student = enrolledStudents[index];
            final studentId = student['studentId'];

            return FutureBuilder<QuerySnapshot>(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .where('userId', isEqualTo: int.parse(studentId))
                  .get(),
              builder: (context, userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!userSnapshot.hasData || userSnapshot.data!.docs.isEmpty) {
                  return ListTile(
                    title: const Text('Unknown Student'),
                    subtitle: Text('Enrolled on: ${student['enrolledAt'].toDate()}'),
                  );
                }

                final userData = userSnapshot.data!.docs.first;
                final studentName = userData['displayName'] ?? 'Unknown Student';

                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text(
                        studentName[0].toUpperCase(),
                        style: const TextStyle(color: Colors.white),
                      ),
                      backgroundColor: Colors.indigo,
                    ),
                    title: Text(studentName, style: const TextStyle(fontSize: 18)),
                    subtitle: Text('Enrolled on: ${student['enrolledAt'].toDate()}'),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
