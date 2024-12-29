import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class LaunchNewQuizPage extends StatefulWidget {
  final String courseId;
  final String instructorId;

  const LaunchNewQuizPage({Key? key, required this.courseId, required this.instructorId}) : super(key: key);

  @override
  _LaunchNewQuizPageState createState() => _LaunchNewQuizPageState();
}

class _LaunchNewQuizPageState extends State<LaunchNewQuizPage> {
  final _titleController = TextEditingController();
  final _questionController = TextEditingController();
  final _optionController1 = TextEditingController();
  final _optionController2 = TextEditingController();
  final _optionController3 = TextEditingController();
  final _optionController4 = TextEditingController();
  final _correctAnswerController = TextEditingController();
  final List<Map<String, dynamic>> _questions = [];
  final String _quizId = const Uuid().v4();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: const Text('Launch New Quiz'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Quiz Title Input
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Quiz Title',
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blueAccent, width: 2),
                  ),
                ),
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 16),
              const Text(
                'Add Questions',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              // Question Input
              TextField(
                controller: _questionController,
                decoration: const InputDecoration(
                  labelText: 'Question',
                  border: OutlineInputBorder(),
                ),
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              // Option Inputs
              TextField(
                controller: _optionController1,
                decoration: const InputDecoration(
                  labelText: 'Option 1',
                  border: OutlineInputBorder(),
                ),
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _optionController2,
                decoration: const InputDecoration(
                  labelText: 'Option 2',
                  border: OutlineInputBorder(),
                ),
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _optionController3,
                decoration: const InputDecoration(
                  labelText: 'Option 3',
                  border: OutlineInputBorder(),
                ),
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _optionController4,
                decoration: const InputDecoration(
                  labelText: 'Option 4',
                  border: OutlineInputBorder(),
                ),
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              // Correct Answer Input
              TextField(
                controller: _correctAnswerController,
                decoration: const InputDecoration(
                  labelText: 'Correct Answer (1-4)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              // Add Question Button
              ElevatedButton(
                onPressed: () {
                  // Validation: Ensure all fields are filled before adding a question
                  if (_questionController.text.isEmpty ||
                      _optionController1.text.isEmpty ||
                      _optionController2.text.isEmpty ||
                      _optionController3.text.isEmpty ||
                      _optionController4.text.isEmpty ||
                      _correctAnswerController.text.isEmpty) {
                    _showErrorDialog('All fields must be filled before adding a question.');
                  } else {
                    setState(() {
                      _questions.add({
                        'question': _questionController.text,
                        'options': [
                          _optionController1.text,
                          _optionController2.text,
                          _optionController3.text,
                          _optionController4.text,
                        ],
                        'correctAnswer': int.tryParse(_correctAnswerController.text),
                      });
                      _clearInputs();
                    });
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'Add Question',
                  style: TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(height: 16),
              if (_questions.isNotEmpty)
                const Text(
                  'Questions Added:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              const SizedBox(height: 8),
              // Displaying added questions
              ..._questions.asMap().entries.map((entry) {
                int index = entry.key;
                Map<String, dynamic> question = entry.value;

                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(vertical: 8),
                  title: Text(question['question'], style: const TextStyle(fontSize: 16)),
                  subtitle: Text('Options: ${question['options'].join(', ')}\nCorrect Answer: Option ${question['correctAnswer']}'),
                  leading: const Icon(Icons.question_answer),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () {
                      _editQuestion(index);
                    },
                  ),
                );
              }).toList(),
              const SizedBox(height: 16),
              // Create Quiz Button
              ElevatedButton(
                onPressed: () async {
                  // Validation: Ensure quiz title is filled and at least one question is added
                  if (_titleController.text.isEmpty || _questions.isEmpty) {
                    _showErrorDialog('Please provide a title and add at least one question before creating the quiz.');
                  } else {
                    // Confirm quiz creation
                    bool? confirm = await _showConfirmationDialog(context);
                    if (confirm == true) {
                      FirebaseFirestore.instance.collection('quizzes').doc(_quizId).set({
                        'quizId': _quizId,
                        'courseId': widget.courseId,
                        'instructorId': widget.instructorId,
                        'title': _titleController.text,
                        'questions': _questions,
                        'createdAt': FieldValue.serverTimestamp(),
                      }).then((_) {
                        Navigator.pop(context);
                      });
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'Create Quiz',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _clearInputs() {
    _questionController.clear();
    _optionController1.clear();
    _optionController2.clear();
    _optionController3.clear();
    _optionController4.clear();
    _correctAnswerController.clear();
  }

  void _editQuestion(int index) {
    Map<String, dynamic> question = _questions[index];
    _questionController.text = question['question'];
    _optionController1.text = question['options'][0];
    _optionController2.text = question['options'][1];
    _optionController3.text = question['options'][2];
    _optionController4.text = question['options'][3];
    _correctAnswerController.text = question['correctAnswer'].toString();

    // Remove the question temporarily to allow editing
    setState(() {
      _questions.removeAt(index);
    });
  }

  // Error dialog for validation
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // Confirmation dialog before creating the quiz
  Future<bool?> _showConfirmationDialog(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Quiz Creation'),
          content: const Text('Are you sure you want to create this quiz?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }
}
