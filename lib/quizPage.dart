// quiz_creation_page.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CreateQuizPage extends StatefulWidget {
  final String courseId;
  final String instructorId;

  const CreateQuizPage({
    Key? key,
    required this.courseId,
    required this.instructorId,
  }) : super(key: key);

  @override
  CreateQuizPageState createState() => CreateQuizPageState();
}

class CreateQuizPageState extends State<CreateQuizPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  List<QuestionData> questions = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Quiz'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveQuiz,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Quiz Title',
                border: OutlineInputBorder(),
              ),
              validator: (value) =>
              value?.isEmpty ?? true ? 'Please enter a title' : null,
            ),
            const SizedBox(height: 16),
            ...questions.asMap().entries.map((entry) {
              final index = entry.key;
              final question = entry.value;
              return QuestionCard(
                question: question,
                onDelete: () {
                  setState(() {
                    questions.removeAt(index);
                  });
                },
                onUpdate: (updatedQuestion) {
                  setState(() {
                    questions[index] = updatedQuestion;
                  });
                },
              );
            }),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  questions.add(QuestionData(
                    question: '',
                    options: List.filled(4, ''),
                    correctOptionIndex: 0,
                  ));
                });
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Question'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveQuiz() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        await FirebaseFirestore.instance.collection('quizzes').add({
          'title': _titleController.text,
          'courseId': widget.courseId,
          'instructorId': widget.instructorId,
          'questions': questions.map((q) => q.toMap()).toList(),
          'createdAt': FieldValue.serverTimestamp(),
        });

        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating quiz: $e')),
        );
      }
    }
  }
}

class QuestionCard extends StatefulWidget {
  final QuestionData question;
  final VoidCallback onDelete;
  final Function(QuestionData) onUpdate;

  const QuestionCard({
    Key? key,
    required this.question,
    required this.onDelete,
    required this.onUpdate,
  }) : super(key: key);

  @override
  QuestionCardState createState() => QuestionCardState();
}

class QuestionCardState extends State<QuestionCard> {
  late TextEditingController questionController;
  late List<TextEditingController> optionControllers;
  late int correctOptionIndex;

  @override
  void initState() {
    super.initState();
    questionController = TextEditingController(text: widget.question.question);
    optionControllers = widget.question.options
        .map((option) => TextEditingController(text: option))
        .toList();
    correctOptionIndex = widget.question.correctOptionIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: questionController,
                    decoration: const InputDecoration(
                      labelText: 'Question',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) => _updateQuestion(), // Fixed here
                    validator: (value) =>
                    value?.isEmpty ?? true ? 'Required' : null,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: widget.onDelete,
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...List.generate(
              optionControllers.length,
                  (index) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Radio<int>(
                      value: index,
                      groupValue: correctOptionIndex,
                      onChanged: (value) {
                        setState(() {
                          correctOptionIndex = value!;
                          _updateQuestion();
                        });
                      },
                    ),
                    Expanded(
                      child: TextFormField(
                        controller: optionControllers[index],
                        decoration: InputDecoration(
                          labelText: 'Option ${index + 1}',
                          border: const OutlineInputBorder(),
                        ),
                        onChanged: (value) => _updateQuestion(), // Fixed here
                        validator: (value) =>
                        value?.isEmpty ?? true ? 'Required' : null,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _updateQuestion() {
    widget.onUpdate(
      QuestionData(
        question: questionController.text,
        options: optionControllers.map((c) => c.text).toList(),
        correctOptionIndex: correctOptionIndex,
      ),
    );
  }

  @override
  void dispose() {
    questionController.dispose();
    for (var controller in optionControllers) {
      controller.dispose();
    }
    super.dispose();
  }
}

class QuestionData {
  String question;
  List<String> options;
  int correctOptionIndex;

  QuestionData({
    required this.question,
    required this.options,
    required this.correctOptionIndex,
  });

  Map<String, dynamic> toMap() {
    return {
      'question': question,
      'options': options,
      'correctOptionIndex': correctOptionIndex,
    };
  }
}

// Added QuizDetailsPage
class QuizDetailsPage extends StatelessWidget {
  final String quizId;
  final String courseId;

  const QuizDetailsPage({
    Key? key,
    required this.quizId,
    required this.courseId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('quizzes')
                .doc(quizId)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Text('Loading...');
              return Text(snapshot.data!['title']);
            },
          ),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Questions'),
              Tab(text: 'Results'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            QuestionsTab(quizId: quizId),
            ResultsTab(quizId: quizId, courseId: courseId),
          ],
        ),
      ),
    );
  }
}

class QuestionsTab extends StatelessWidget {
  final String quizId;

  const QuestionsTab({Key? key, required this.quizId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('quizzes')
          .doc(quizId)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final quizData = snapshot.data!.data() as Map<String, dynamic>;
        final questions = List<Map<String, dynamic>>.from(quizData['questions']);

        return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: questions.length,
          itemBuilder: (context, index) {
            final question = questions[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 16.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Question ${index + 1}: ${question['question']}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    ...List.generate(
                      question['options'].length,
                          (optionIndex) => ListTile(
                        leading: Text('${String.fromCharCode(65 + optionIndex)}.'),
                        title: Text(question['options'][optionIndex]),
                        trailing: optionIndex == question['correctOptionIndex']
                            ? const Icon(Icons.check_circle, color: Colors.green)
                            : null,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class ResultsTab extends StatelessWidget {
  final String quizId;
  final String courseId;

  const ResultsTab({
    Key? key,
    required this.quizId,
    required this.courseId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('quiz_attempts')
          .where('quizId', isEqualTo: quizId)
          .orderBy('score', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final attempts = snapshot.data!.docs;

        if (attempts.isEmpty) {
          return const Center(child: Text('No attempts yet'));
        }

        return ListView.builder(
          itemCount: attempts.length,
          itemBuilder: (context, index) {
            final attempt = attempts[index];
            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .doc(attempt['userId'])
                  .get(),
              builder: (context, userSnapshot) {
                if (!userSnapshot.hasData) {
                  return const ListTile(title: Text('Loading...'));
                }

                final userData = userSnapshot.data!.data() as Map<String, dynamic>;

                return ListTile(
                  leading: CircleAvatar(
                    child: Text(userData['name'][0].toUpperCase()),
                  ),
                  title: Text(userData['name']),
                  subtitle: Text('Attempted: ${attempt['submittedAt'].toDate().toString().split(' ')[0]}'),
                  trailing: Text(
                    '${attempt['score']}%',
                    style: Theme.of(context).textTheme.titleMedium,
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