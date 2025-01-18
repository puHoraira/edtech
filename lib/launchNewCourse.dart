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
        final querySnapshot = await FirebaseFirestore.instance
            .collection('courses')
            .orderBy('createdAt', descending: true)
            .limit(1)
            .get();

        String courseId;
        if (querySnapshot.docs.isEmpty) {
          courseId = 'course1';
        } else {
          final lastCourseId = querySnapshot.docs.first.id;
          final lastIdNumber = int.tryParse(
              lastCourseId.replaceAll(RegExp(r'[^0-9]'), ''));

          if (lastIdNumber != null) {
            courseId = 'course${lastIdNumber + 1}';
          } else {
            courseId = 'course1';
          }
        }
        print("------------");
        print(FieldValue.serverTimestamp());
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
        centerTitle: true,
        backgroundColor: Colors.indigo,
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
                _buildSectionTitle("Course Title"),
                _buildTextField(
                  controller: _titleController,
                  hint: "Enter course title",
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter the course title";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Course Description
                _buildSectionTitle("Course Description"),
                _buildTextField(
                  controller: _descriptionController,
                  hint: "Enter course description",
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
                _buildSectionTitle("Course Price (\$)"),
                _buildTextField(
                  controller: _priceController,
                  hint: "Enter course price",
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
                _buildSectionTitle("Topics Covered"),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _topicController,
                        hint: "Add a topic",
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
                _buildSectionTitle("Course Features"),
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
                    : SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _launchCourse,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.lightGreen,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      "Launch Course",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.indigo,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.indigo),
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      validator: validator,
    );
  }
}
