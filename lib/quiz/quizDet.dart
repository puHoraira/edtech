import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class QuizDetailsPage extends StatelessWidget {
  final String quizId;

  const QuizDetailsPage({Key? key, required this.quizId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Quiz Details',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.indigo,
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
              child: Text(
                'Quiz not found.',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
            );
          }

          final quizData = snapshot.data!;
          final questions = quizData['questions'] as List<dynamic>? ?? [];

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Display quiz title
                  Card(
                    elevation: 6,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            quizData['title'] ?? 'Untitled Quiz',
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.indigo,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Created At: ${_formatDate(quizData['createdAt'] as Timestamp?)}',
                            style: const TextStyle(fontSize: 16, color: Colors.black54),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Display questions with options and correct answer
                  if (questions.isNotEmpty)
                    const Text(
                      'Questions:',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  const SizedBox(height: 8),

                  ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: questions.length,
                    itemBuilder: (context, index) {
                      final questionData = questions[index];
                      final questionText = questionData['question'] ?? 'No question text';
                      final options = questionData['options'] as List<dynamic>? ?? [];
                      final correctOptionIndex = questionData['correctAnswer'] as int? ?? -1;

                      return Card(
                        elevation: 3,
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Q${index + 1}: $questionText',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 12),

                              // Display options with the correct one highlighted
                              ...List.generate(options.length, (optionIndex) {
                                final option = options[optionIndex];
                                final isCorrect = optionIndex == correctOptionIndex;

                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                                  child: Text(
                                    option,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: isCorrect ? Colors.green : Colors.black87,
                                      fontWeight: isCorrect ? FontWeight.bold : FontWeight.normal,
                                    ),
                                  ),
                                );
                              }),
                            ],
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
      ),
    );
  }

  String _formatDate(Timestamp? timestamp) {
    if (timestamp == null) return 'Unknown date';
    final DateTime date = timestamp.toDate();
    return "${date.day}/${date.month}/${date.year}";
  }
}
