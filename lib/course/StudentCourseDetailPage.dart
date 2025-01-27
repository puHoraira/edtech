import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../document/StuCourseDoc.dart';
import '../class/classDetailPage.dart';
import '../leaderboard.dart';
import '../quiz/SQuizDetailPage.dart';

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
                  const SizedBox(height: 20),

                  // Available Classes Section
                  const Text(
                    'Available Classes',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 220,
                    child: _buildClassesList(),
                  ),
                  const SizedBox(height: 20),

                  // Available Quizzes Section
                  const Text(
                    'Quizzes',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _buildQuizzesList(),
                  const SizedBox(height: 12),
                  StudentCourseDocuments(courseId: courseId),
                  const SizedBox(height: 20),

                  // Leaderboard Button
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LeaderboardPage(courseId: courseId),
                        ),
                      ),
                      icon: const Icon(Icons.leaderboard, color: Colors.white),
                      label: const Text(
                        'Leaderboard',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.greenAccent,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                    ),
                  ),
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
        padding: const EdgeInsets.all(20.0),
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
            final classTime = classData['classTime'] ?? 'Time not set';

            return Card(
              elevation: 6,
              margin: const EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: const Icon(Icons.video_call, color: Colors.indigo, size: 36),
                title: Text(
                  classTitle,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  'Scheduled At: $classTime',
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                ),
                onTap: () {
                  // Navigate to class details page
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ClassDetailsPage(
                        classTitle: classTitle,
                        classDescription: classData['classDescription'],
                        classTime: classTime,
                        maxStudents: classData['maxStudents'].toString(),
                        enrolledStudents: List<String>.from(classData['enrolledStudents'] ?? []),
                        formattedDate: classData['createdAt'].toDate().toString(),
                        conferenceID: classData['conferenceID'],
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
              elevation: 6,
              margin: const EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: const Icon(Icons.quiz, color: Colors.indigo, size: 36),
                title: Text(
                  quiz['title'] ?? 'Quiz Title',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  'Created At: ${quiz['createdAt'].toDate()}',
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SQuizDetailPage(quizId: quiz.id, studentId: studentId, courseId: courseId),
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
