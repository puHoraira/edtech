import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TeacherQuizDetailPage extends StatelessWidget {
  final String quizId;
  final String studentId;
  final String courseId;

  const TeacherQuizDetailPage({
    Key? key,
    required this.quizId,
    required this.studentId,
    required this.courseId,
  }) : super(key: key);

  Future<Map<String, dynamic>?> _fetchStudentQuizData() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('enrollment')
          .where('courseId', isEqualTo: courseId)
          .where('studentId', isEqualTo: studentId)
          .get();

      if (querySnapshot.docs.isEmpty) return null;

      final enrollmentDoc = querySnapshot.docs.first;
      final data = enrollmentDoc.data();

      if (data.containsKey('quizzes')) {
        final quizzes = data['quizzes'] as Map<String, dynamic>;
        return quizzes[quizId] as Map<String, dynamic>?;
      }
      return null;
    } catch (e) {
      print('Error fetching student quiz data: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('quizzes')
              .doc(quizId)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const Text('Quiz Details');
            return Text(snapshot.data?['title'] ?? 'Quiz Details', style: TextStyle(color: Colors.white),);
          },
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _fetchStudentQuizData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final attemptData = snapshot.data;

          if (attemptData != null) {
            return _buildAttemptedQuizView(attemptData);
          } else {
            return const Center(
              child: Text(
                'No attempt found for this student.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildAttemptedQuizView(Map<String, dynamic> attemptData) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Quiz Result',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Score: ${attemptData['score']} / ${attemptData['totalQuestions']}',
                    style: const TextStyle(fontSize: 20),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Attempted on: ${(attemptData['submittedAt'] as Timestamp).toDate().toString()}',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Student\'s Answers',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('quizzes')
                  .doc(quizId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final quizData = snapshot.data!.data() as Map<String, dynamic>;
                final questions = quizData['questions'] as List<dynamic>;
                final answers = attemptData['answers'] as Map<String, dynamic>;

                return ListView.builder(
                  itemCount: questions.length,
                  itemBuilder: (context, index) {
                    final question = questions[index];
                    final options = question['options'] as List<dynamic>;
                    final correctAnswerIndex = question['correctAnswer'] as int;
                    final userAnswerIndex = int.tryParse(answers[index.toString()] ?? '') ?? -1;

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Q${index + 1}: ${question['question']}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ...options.asMap().entries.map((entry) {
                              final optionIndex = entry.key;
                              final optionText = entry.value;
                              final isCorrect = optionIndex == correctAnswerIndex;
                              final isSelected = optionIndex == userAnswerIndex - 1;

                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                child: Row(
                                  children: [
                                    Icon(
                                      isSelected
                                          ? (isCorrect
                                          ? Icons.check_circle
                                          : Icons.cancel)
                                          : (isCorrect
                                          ? Icons.check_circle_outline
                                          : null),
                                      color: isSelected
                                          ? (isCorrect ? Colors.green : Colors.red)
                                          : (isCorrect ? Colors.green : null),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        optionText,
                                        style: TextStyle(
                                          color: isSelected
                                              ? (isCorrect
                                              ? Colors.green
                                              : Colors.red)
                                              : null,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
