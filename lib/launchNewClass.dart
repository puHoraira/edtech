import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LaunchNewClassPage extends StatefulWidget {
  final String courseId;
  final String instructorId;

  const LaunchNewClassPage({Key? key, required this.courseId, required this.instructorId}) : super(key: key);

  @override
  _LaunchNewClassPageState createState() => _LaunchNewClassPageState();
}

class _LaunchNewClassPageState extends State<LaunchNewClassPage> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _timeController = TextEditingController();
  final _maxStudentsController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Launch New Class'),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Class Title Input
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Class Title',
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blueAccent, width: 2),
                  ),
                ),
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),

              // Class Description Input
              TextField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Class Description',
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blueAccent, width: 2),
                  ),
                ),
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),

              // Class Time Input
              TextField(
                controller: _timeController,
                decoration: const InputDecoration(
                  labelText: 'Class Time (e.g., 10:00 AM)',
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blueAccent, width: 2),
                  ),
                ),
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),

              // Maximum Students Input
              TextField(
                controller: _maxStudentsController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Maximum Students',
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blueAccent, width: 2),
                  ),
                ),
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),

              // Create Class Button
              ElevatedButton(
                onPressed: () {
                  if (_titleController.text.isNotEmpty &&
                      _descriptionController.text.isNotEmpty &&
                      _timeController.text.isNotEmpty &&
                      _maxStudentsController.text.isNotEmpty) {
                    int? maxStudents = int.tryParse(_maxStudentsController.text);
                    if (maxStudents == null || maxStudents <= 0) {
                      _showErrorDialog('Please enter a valid number of students.');
                    } else {
                      FirebaseFirestore.instance.collection('classes').add({
                        'courseId': widget.courseId,
                        'instructorId': widget.instructorId,
                        'classTitle': _titleController.text,
                        'classDescription': _descriptionController.text,
                        'classTime': _timeController.text,
                        'maxStudents': maxStudents,
                        'enrolledStudents': [], // Will be filled later
                        'createdAt': FieldValue.serverTimestamp(),
                      }).then((_) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Class created successfully!'))
                        );
                        Navigator.pop(context);
                      }).catchError((e) {
                        _showErrorDialog('Failed to create class. Try again later.');
                      });
                    }
                  } else {
                    _showErrorDialog('Please fill all fields before creating the class.');
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
                  'Create Class',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Error Dialog for validation
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
}
