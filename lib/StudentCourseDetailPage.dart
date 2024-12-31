import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:edtech/ClassesListPage.dart';

import 'QuizDetailPage.dart';
import 'StuCourseDoc.dart';
import 'classDetailPage.dart';

class StudentCourseDetailPage extends StatelessWidget {
  final String courseId;
  final String studentId;

  const StudentCourseDetailPage({
    Key? key,
    required this.courseId,
    required this.studentId,
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

                  // Available Classes Section
                  const Text(
                    'Available Classes',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  // Use a Container with a fixed height or make it scrollable
                  SizedBox(
                    height: 200, // Adjust height as necessary
                    child: _buildClassesList(),
                  ),
                  const SizedBox(height: 16),

                  // Available Quizzes Section
                  const Text(
                    'Quizzes',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  _buildQuizzesList(),
                  const SizedBox(height: 8),
                  StudentCourseDocuments(courseId: courseId)
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
  Widget _buildClassesList() {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance
          .collection('classes')
          .where('courseId', isEqualTo: courseId)
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text(
              'No classes scheduled.',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          );
        }

        final classes = snapshot.data!.docs;
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: classes.length,
          itemBuilder: (context, index) {
            final classData = classes[index];
            final classTitle = classData['classTitle'] ?? 'Class Title';
            final classDescription = classData['classDescription'] ?? 'Description not available';
            final classTime = classData['classTime'] ?? 'Time not set';
            final maxStudents = classData['maxStudents'].toString() ?? 'No limit';
            final enrolledStudents = List<String>.from(classData['enrolledStudents'] ?? []);
            final formattedDate = classData['createdAt'].toDate().toString();

            return Card(
              elevation: 4,
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                leading: const Icon(Icons.video_call, color: Colors.indigo),
                title: Text(
                  classTitle,
                  style: const TextStyle(fontSize: 18),
                ),
                subtitle: Text(
                  'Scheduled At: ${classData['classTime']}',
                  style: const TextStyle(color: Colors.grey),
                ),
                onTap: () {
                  // Navigate to class details page
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ClassDetailsPage(
                        classTitle: classTitle,
                        classDescription: classDescription,
                        classTime: classTime,
                        maxStudents: maxStudents,
                        enrolledStudents: enrolledStudents,
                        formattedDate: formattedDate,
                      ),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildQuizzesList() {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance
          .collection('quizzes')
          .where('courseId', isEqualTo: courseId)
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text(
              'No quizzes available.',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          );
        }

        final quizzes = snapshot.data!.docs;
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: quizzes.length,
          itemBuilder: (context, index) {
            final quiz = quizzes[index];
            return Card(
              elevation: 4,
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                leading: const Icon(Icons.quiz, color: Colors.indigo),
                title: Text(
                  quiz['title'] ?? 'Quiz Title',
                  style: const TextStyle(fontSize: 18),
                ),
                subtitle: Text(
                  'Created At: ${quiz['createdAt'].toDate()}',
                  style: const TextStyle(color: Colors.grey),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => QuizDetailPage(quizId: quiz.id),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }


}



