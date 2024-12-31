import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class QuizDetailPage extends StatelessWidget {
  final String quizId;

  const QuizDetailPage({Key? key, required this.quizId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        title: const Text('Quiz Details'),
        centerTitle: true,
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('quizzes').doc(quizId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(
              child: Text('Quiz not found.', style: TextStyle(fontSize: 18, color: Colors.grey)),
            );
          }
          final quizData = snapshot.data!;
          final questions = quizData['questions'] as List<dynamic>?;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    quizData['title'] ?? 'Untitled Quiz',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Questions:',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  if (questions != null && questions.isNotEmpty)
                    ...questions.map((question) {
                      final options = question['options'] as List<dynamic>;
                      return Card(
                        elevation: 4,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Q: ${question['question']}',
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              ...List.generate(options.length, (index) {
                                return Text(
                                  '${index + 1}. ${options[index]}',
                                  style: const TextStyle(fontSize: 14),
                                );
                              }),
                              const SizedBox(height: 8),
                              Text(
                                'Correct Answer: Option ${question['correctAnswer']}',
                                style: const TextStyle(fontSize: 14, color: Colors.green),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList()
                  else
                    const Center(
                      child: Text(
                        'No questions available.',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
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
}
