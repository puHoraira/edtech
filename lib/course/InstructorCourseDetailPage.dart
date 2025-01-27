import 'package:edtech/leaderboard.dart';
import 'package:edtech/quiz/teacherSeeStudentQuiz.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../document/CourseDocumentsSection.dart';
import '../class/launchNewClass.dart';
import '../quiz/launchNewQuiz.dart';
import '../class/viewPreviousClasses.dart';
import '../quiz/viewPreviousQuiz.dart';
import 'chat.dart';

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


                  // Add the documents section here
                  CourseDocumentsSection(courseId: courseId),
                  const SizedBox(height: 16),

                  // Enrolled Students Section
                  const Text(
                    'Enrolled Students',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  _buildEnrolledStudentsList(),
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LeaderboardPage(courseId: courseId),
                        ),
                      ),
                      icon: Icon(Icons.leaderboard, color: Colors.white),
                      label: Text(
                        'Leaderboard',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.greenAccent,
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
    return FutureBuilder(
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

            return FutureBuilder(
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
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.chat, color: Colors.indigo),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChatPage(
                                  studentId: studentId,
                                  teacherId: instructorId,
                                  studentName: studentName,
                                ),
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.arrow_forward_ios),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => QuizAttemptsPage(
                                  studentId: studentId,
                                  courseId: courseId,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }}

class QuizAttemptsPage extends StatelessWidget {
  final String studentId;
  final String courseId;

  const QuizAttemptsPage({Key? key, required this.studentId, required this.courseId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Attempts'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance
            .collection('enrollment')
            .where('courseId', isEqualTo: courseId)
            .where('studentId', isEqualTo: studentId)
            .get(),
        builder: (context, enrollmentSnapshot) {
          if (enrollmentSnapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingPlaceholder();
          }

          if (!enrollmentSnapshot.hasData || enrollmentSnapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No enrollment record found.'));
          }

          final enrollmentDoc = enrollmentSnapshot.data!.docs.first;
          final enrollmentData = enrollmentDoc.data() as Map<String, dynamic>;
          final quizzesMap = enrollmentData['quizzes'] as Map<String, dynamic>?;

          if (quizzesMap == null || quizzesMap.isEmpty) {
            return const Center(child: Text('No quizzes attempted.'));
          }

          final quizIds = quizzesMap.keys.toList();

          return FutureBuilder<QuerySnapshot>(
            future: FirebaseFirestore.instance
                .collection('quizzes')
                .where(FieldPath.documentId, whereIn: quizIds)
                .get(),
            builder: (context, quizzesSnapshot) {
              if (quizzesSnapshot.connectionState == ConnectionState.waiting) {
                return _buildLoadingPlaceholder();
              }

              if (!quizzesSnapshot.hasData || quizzesSnapshot.data!.docs.isEmpty) {
                return const Center(child: Text('No quiz details found.'));
              }

              final quizDocs = quizzesSnapshot.data!.docs;

              return ListView.builder(
                padding: const EdgeInsets.all(10),
                itemCount: quizDocs.length,
                itemBuilder: (context, index) {
                  final quiz = quizDocs[index];
                  final quizId = quiz.id;
                  final quizTitle = quiz['title']; // Assuming 'title' field exists in 'quizzes' collection

                  return Card(
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                      leading: Icon(Icons.quiz, size: 40, color: Colors.blueAccent),
                      title: Text(
                        quizTitle,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey),
                      onTap: () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (context, animation, secondaryAnimation) =>
                                TeacherQuizDetailPage(
                                  courseId: courseId,
                                  quizId: quizId,
                                  studentId: studentId,
                                ),
                            transitionsBuilder: (context, animation, secondaryAnimation, child) {
                              return SlideTransition(
                                position: Tween<Offset>(
                                  begin: const Offset(1, 0),
                                  end: Offset.zero,
                                ).animate(animation),
                                child: child,
                              );
                            },
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildLoadingPlaceholder() {
    return ListView.builder(
      padding: const EdgeInsets.all(10),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            title: Container(
              height: 20,
              color: Colors.grey.shade300,
            ),
            trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey),
          ),
        );
      },
    );
  }
}