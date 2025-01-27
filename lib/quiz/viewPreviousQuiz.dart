import 'package:edtech/quiz/quizDet.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ViewPreviousQuizzesPage extends StatelessWidget {
  final String courseId;

  const ViewPreviousQuizzesPage({Key? key, required this.courseId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Previous Quizzes',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.indigo,
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('quizzes')
            .where('courseId', isEqualTo: courseId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'No previous quizzes found.',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
            );
          }

          final quizzes = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: quizzes.length,
            itemBuilder: (context, index) {
              final quizData = quizzes[index];
              final quizTitle = quizData['title'] ?? 'Untitled Quiz';
              final createdAt = quizData['createdAt'] as Timestamp?;

              return Card(
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.indigo,
                    child: const Icon(Icons.quiz, color: Colors.white),
                  ),
                  title: Text(
                    quizTitle,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    'Created: ${_formatDate(createdAt)}',
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => QuizDetailsPage(quizId: quizData.id),
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

  String _formatDate(Timestamp? timestamp) {
    if (timestamp == null) return 'Unknown date';
    final DateTime date = timestamp.toDate();
    return "${date.day}/${date.month}/${date.year}";
  }
}
