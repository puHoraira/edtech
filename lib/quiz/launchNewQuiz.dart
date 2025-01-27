import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class LaunchNewQuizPage extends StatefulWidget {
  final String courseId;
  final String instructorId;

  const LaunchNewQuizPage({
    Key? key,
    required this.courseId,
    required this.instructorId
  }) : super(key: key);

  @override
  _LaunchNewQuizPageState createState() => _LaunchNewQuizPageState();
}

class _LaunchNewQuizPageState extends State<LaunchNewQuizPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _questionController = TextEditingController();
  final _optionControllers = List.generate(4, (_) => TextEditingController());
  final _correctAnswerController = TextEditingController();
  final List<Map<String, dynamic>> _questions = [];
  final String _quizId = const Uuid().v4();
  bool _isLoading = false;
  int _currentStep = 0;

  @override
  void dispose() {
    _titleController.dispose();
    _questionController.dispose();
    for (var controller in _optionControllers) {
      controller.dispose();
    }
    _correctAnswerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: const Text('Create New Quiz'),
        centerTitle: true,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stepper(
        currentStep: _currentStep,
        onStepContinue: () {
          setState(() {
            if (_currentStep < 2) _currentStep++;
          });
        },
        onStepCancel: () {
          setState(() {
            if (_currentStep > 0) _currentStep--;
          });
        },
        steps: [
          Step(
            title: const Text('Quiz Details'),
            content: _buildQuizDetailsStep(),
            isActive: _currentStep >= 0,
          ),
          Step(
            title: const Text('Add Questions'),
            content: _buildAddQuestionsStep(),
            isActive: _currentStep >= 1,
          ),
          Step(
            title: const Text('Review & Create'),
            content: _buildReviewStep(),
            isActive: _currentStep >= 2,
          ),
        ],
      ),
    );
  }

  Widget _buildQuizDetailsStep() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: _titleController,
            decoration: _buildInputDecoration('Quiz Title', Icons.title),
            validator: (value) =>
            value?.isEmpty ?? true ? 'Please enter a quiz title' : null,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Quiz Information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('Course ID: ${widget.courseId}'),
                  //Text('Quiz ID: $_quizId'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddQuestionsStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _questionController,
                  decoration: _buildInputDecoration(
                    'Question Text',
                    Icons.help_outline,
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                ...List.generate(4, (index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: TextFormField(
                      controller: _optionControllers[index],
                      decoration: _buildInputDecoration(
                        'Option ${index + 1}',
                        Icons.check_circle_outline,
                        suffix: Radio<int>(
                          value: index,
                          groupValue: int.tryParse(_correctAnswerController.text),
                          onChanged: (value) {
                            setState(() {
                              _correctAnswerController.text = value.toString();
                            });
                          },
                        ),
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _addQuestion,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Question'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 24,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_questions.isNotEmpty) ...[
          const SizedBox(height: 16),
          const Text(
            'Added Questions:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _questions.length,
            itemBuilder: (context, index) {
              final question = _questions[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 4),
                child: ListTile(
                  title: Text(
                    'Q${index + 1}: ${question['question']}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ...List.generate(4, (optionIndex) {
                        final isCorrect =
                            question['correctAnswer'] == optionIndex;
                        return Text(
                          '${String.fromCharCode(65 + optionIndex)}. ${question['options'][optionIndex]}',
                          style: TextStyle(
                            color: isCorrect ? Colors.green : null,
                            fontWeight: isCorrect ? FontWeight.bold : null,
                          ),
                        );
                      }),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _editQuestion(index),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _deleteQuestion(index),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ],
    );
  }

  Widget _buildReviewStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Quiz Title: ${_titleController.text}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text('Total Questions: ${_questions.length}'),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _questions.isEmpty ? null : _createQuiz,
                  icon: const Icon(Icons.check),
                  label: const Text('Create Quiz'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 24,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  InputDecoration _buildInputDecoration(String label, IconData icon,
      {Widget? suffix}) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      suffix: suffix,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: Theme.of(context).primaryColor,
          width: 2,
        ),
      ),
    );
  }

  void _addQuestion() {
    if (_questionController.text.isEmpty ||
        _optionControllers.any((controller) => controller.text.isEmpty) ||
        _correctAnswerController.text.isEmpty) {
      _showSnackBar('Please fill in all fields');
      return;
    }

    setState(() {
      _questions.add({
        'question': _questionController.text,
        'options': _optionControllers.map((c) => c.text).toList(),
        'correctAnswer': int.parse(_correctAnswerController.text),
      });
      _clearInputs();
    });

    _showSnackBar('Question added successfully');
  }

  void _editQuestion(int index) {
    final question = _questions[index];
    _questionController.text = question['question'];
    for (var i = 0; i < 4; i++) {
      _optionControllers[i].text = question['options'][i];
    }
    _correctAnswerController.text = question['correctAnswer'].toString();

    setState(() {
      _questions.removeAt(index);
    });

    _showSnackBar('Question loaded for editing');
  }

  void _deleteQuestion(int index) {
    setState(() {
      _questions.removeAt(index);
    });
    _showSnackBar('Question deleted');
  }

  void _clearInputs() {
    _questionController.clear();
    for (var controller in _optionControllers) {
      controller.clear();
    }
    _correctAnswerController.clear();
  }

  Future<void> _createQuiz() async {
    try {
      setState(() => _isLoading = true);

      await FirebaseFirestore.instance.collection('quizzes').doc(_quizId).set({
        'quizId': _quizId,
        'courseId': widget.courseId,
        'instructorId': widget.instructorId,
        'title': _titleController.text,
        'questions': _questions,
        'createdAt': FieldValue.serverTimestamp(),
        'totalQuestions': _questions.length,
        'status': 'active',
      });

      Navigator.pop(context);
    } catch (e) {
      _showSnackBar('Error creating quiz: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}