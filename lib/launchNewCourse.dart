import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LaunchNewCoursePage extends StatefulWidget {
  final String instructorId;

  const LaunchNewCoursePage({Key? key, required this.instructorId})
      : super(key: key);

  @override
  State<LaunchNewCoursePage> createState() => _LaunchNewCoursePageState();
}

class _LaunchNewCoursePageState extends State<LaunchNewCoursePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _topicController = TextEditingController();
  final List<String> _topics = [];
  final List<bool> _featuresSelected = [false, false, false, false];

  bool _isLoading = false;

  final List<String> _courseFeatures = [
    "Live Classes",
    "Downloadable Resources",
    "Certificate of Completion",
    "Lifetime Access",
  ];

  Future<void> _launchCourse() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Step 1: Fetch the most recent course document to get the last ID
        final querySnapshot = await FirebaseFirestore.instance
            .collection('courses')
            .orderBy('createdAt', descending: true)
            .limit(1)
            .get();

        String courseId;
        if (querySnapshot.docs.isEmpty) {
          // If no courses exist, start with a base ID like "course1"
          courseId = 'course1';
        } else {
          // Step 2: Get the last course ID and increment it
          final lastCourseId = querySnapshot.docs.first.id;
          final lastIdNumber = int.tryParse(lastCourseId.replaceAll(RegExp(r'[^0-9]'), ''));

          if (lastIdNumber != null) {
            // Increment the last course ID number
            courseId = 'course${lastIdNumber + 1}';
          } else {
            courseId = 'course1'; // Fallback if parsing fails
          }
        }

        // Step 3: Save the course with the generated courseId
        await FirebaseFirestore.instance.collection('courses').doc(courseId).set({
          'courseId': courseId,
          'title': _titleController.text.trim(),
          'description': _descriptionController.text.trim(),
          'price': double.parse(_priceController.text.trim()),
          'topics': _topics,
          'features': _courseFeatures
              .asMap()
              .entries
              .where((entry) => _featuresSelected[entry.key])
              .map((entry) => entry.value)
              .toList(),
          'instructorId': widget.instructorId,
          'createdAt': FieldValue.serverTimestamp(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Course launched successfully!")),
        );

        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to launch course: $e")),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _addTopic() {
    if (_topicController.text.trim().isNotEmpty) {
      setState(() {
        _topics.add(_topicController.text.trim());
        _topicController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Launch New Course"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Course Title
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: "Course Title",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter the course title";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Course Description
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: "Course Description",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter the course description";
                    }
                    return null;
                  },
                  maxLines: 4,
                ),
                const SizedBox(height: 16),
                // Course Price
                TextFormField(
                  controller: _priceController,
                  decoration: const InputDecoration(
                    labelText: "Course Price (\$)",
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter the course price";
                    }
                    if (double.tryParse(value) == null) {
                      return "Please enter a valid number";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Topics Covered
                Text(
                  "Topics Covered",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _topicController,
                        decoration: const InputDecoration(
                          hintText: "Add a topic",
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: _addTopic,
                      icon: const Icon(Icons.add_circle, color: Colors.indigo),
                    ),
                  ],
                ),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: _topics
                      .map(
                        (topic) => Chip(
                      label: Text(topic),
                      deleteIcon: const Icon(Icons.close),
                      onDeleted: () {
                        setState(() {
                          _topics.remove(topic);
                        });
                      },
                    ),
                  )
                      .toList(),
                ),
                const SizedBox(height: 16),
                // Course Features
                Text(
                  "Course Features",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Column(
                  children: _courseFeatures.asMap().entries.map((entry) {
                    final index = entry.key;
                    final feature = entry.value;
                    return CheckboxListTile(
                      title: Text(feature),
                      value: _featuresSelected[index],
                      onChanged: (value) {
                        setState(() {
                          _featuresSelected[index] = value ?? false;
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                // Launch Button
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                  onPressed: _launchCourse,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    backgroundColor: Colors.indigo,
                  ),
                  child: const Text("Launch Course"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
