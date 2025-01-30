import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../course/StudentCourseDetailPage.dart';

class SQuizDetailPage extends StatelessWidget {
  final String quizId;
  final String studentId;
  final String courseId;

  const SQuizDetailPage({
    Key? key,
    required this.quizId,
    required this.studentId,
    required this.courseId,
  }) : super(key: key);

  Future<Map<String, dynamic>?> _getQuizAttemptStatus() async {
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
      print('Error getting quiz attempt status: $e');
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
        future: _getQuizAttemptStatus(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final attemptData = snapshot.data;

          if (attemptData != null) {
            return _buildAttemptedQuizView(attemptData);
          } else {
            return _buildStartQuizButton(context);
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
            'Your Answers',
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
                              print(optionIndex);
                              print(correctAnswerIndex);

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

  Widget _buildStartQuizButton(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'You haven\'t attempted this quiz yet',
            style: TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => InteractiveQuizPage(
                    quizId: quizId,
                    studentId: studentId,
                    courseId: courseId,
                  ),
                ),
              );
            },
            child: const Text(
              'Start Quiz',
              style: TextStyle(fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }
}

class InteractiveQuizPage extends StatefulWidget {
  final String quizId;
  final String studentId;
  final String courseId;

  const InteractiveQuizPage({
    Key? key,
    required this.quizId,
    required this.studentId,
    required this.courseId,
  }) : super(key: key);

  @override
  _InteractiveQuizPageState createState() => _InteractiveQuizPageState();
}

class _InteractiveQuizPageState extends State<InteractiveQuizPage> {
  List<dynamic>? questions;
  Map<String, String> answers = {};
  int currentQuestionIndex = 0;
  bool isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _fetchQuizData();
  }

  Future<void> _fetchQuizData() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('quizzes')
          .doc(widget.quizId)
          .get();

      if (doc.exists) {
        setState(() {
          questions = doc.data()?['questions'] as List<dynamic>;
        });
      }
    } catch (e) {
      print('Error fetching quiz data: $e');
    }
  }

  Future<void> _submitQuiz() async {
    if (isSubmitting) return;

    setState(() {
      isSubmitting = true;
    });

    try {
      // Calculate score
      int score = 0;
      questions!.asMap().forEach((index, question) {
        final userAnswer = int.tryParse(answers[index.toString()] ?? '') ?? -1;
        if (userAnswer - 1 == question['correctAnswer']) {
          score++;
        }
      });

      // Get enrollment document
      final querySnapshot = await FirebaseFirestore.instance
          .collection('enrollment')
          .where('courseId', isEqualTo: widget.courseId)
          .where('studentId', isEqualTo: widget.studentId)
          .get();

      if (querySnapshot.docs.isEmpty) {
        throw Exception('Enrollment not found');
      }

      final enrollmentDoc = querySnapshot.docs.first;

      // Get existing quizzes data or create new map if it doesn't exist
      Map<String, dynamic> existingQuizzes =
          (enrollmentDoc.data()['quizzes'] as Map<String, dynamic>?) ?? {};

      // Add new quiz attempt
      existingQuizzes[widget.quizId] = {
        'score': score,
        'totalQuestions': questions!.length,
        'answers': answers,
        'submittedAt': FieldValue.serverTimestamp(),
      };

      // Update enrollment document with the new quizzes map
      await enrollmentDoc.reference.update({
        'quizzes': existingQuizzes,
      });

      if (!mounted) return;

      // Show result dialog
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('Quiz Submitted'),
          content: Text('Your score: $score out of ${questions!.length}'),
          actions: [
            TextButton(
              onPressed: () {
                // First pop the dialog
                Navigator.pop(context);
                // Then pop the InteractiveQuizPage
                Navigator.pop(context);
                // Finally, replace the original quiz detail page with a new one
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SQuizDetailPage(
                      quizId: widget.quizId,
                      studentId: widget.studentId,
                      courseId: widget.courseId,
                    ),
                  ),
                );
              },
              child: const Text('OK'),
            ),          ],
        ),
      );
    } catch (e) {
      print('Error submitting quiz: $e');
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to submit quiz. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isSubmitting = false;
        });
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    if (questions == null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blueAccent,
          title: const Text('Quiz'),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final currentQuestion = questions![currentQuestionIndex];
    final options = currentQuestion['options'] as List<dynamic>;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: const Text('Quiz'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LinearProgressIndicator(
              value: (currentQuestionIndex + 1) / questions!.length,
              backgroundColor: Colors.grey[200],
              color: Colors.blueAccent,
            ),
            const SizedBox(height: 16),
            Text(
              'Question ${currentQuestionIndex + 1} of ${questions!.length}',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              currentQuestion['question'],
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView.builder(
                itemCount: options.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: RadioListTile<String>(
                      title: Text(options[index]),
                      value: (index + 1).toString(),
                      groupValue: answers[currentQuestionIndex.toString()],
                      onChanged: (value) {
                        setState(() {
                          answers[currentQuestionIndex.toString()] = value!;
                        });
                      },
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (currentQuestionIndex > 0)
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        currentQuestionIndex--;
                      });
                    },
                    child: const Text('Previous'),
                  ),
                if (currentQuestionIndex < questions!.length - 1)
                  ElevatedButton(
                    onPressed: answers[currentQuestionIndex.toString()] != null
                        ? () {
                      setState(() {
                        currentQuestionIndex++;
                      });
                    }
                        : null,
                    child: const Text('Next'),
                  ),
                if (currentQuestionIndex == questions!.length - 1)
                  ElevatedButton(
                    onPressed: answers[currentQuestionIndex.toString()] != null &&
                        !isSubmitting
                        ? _submitQuiz
                        : null,
                    child: isSubmitting
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                        : const Text('Submit'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}