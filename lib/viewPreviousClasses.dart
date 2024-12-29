import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'classDetailPage.dart';

class ViewPreviousClassesPage extends StatelessWidget {
  final String courseId;

  const ViewPreviousClassesPage({Key? key, required this.courseId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Previous Classes'),
        backgroundColor: Colors.blueAccent,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('classes')
            .where('courseId', isEqualTo: courseId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'No previous classes found.',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            );
          }

          final classes = snapshot.data!.docs;

          return ListView.builder(
            itemCount: classes.length,
            itemBuilder: (context, index) {
              final classData = classes[index];
              final Timestamp createdAt = classData['createdAt'];
              final classTitle = classData['classTitle'] ?? 'Untitled Class';
              final classDescription = classData['classDescription'] ?? 'No description provided';
              final classTime = classData['classTime'] ?? 'No time set';
              final maxStudents = (classData['maxStudents'] ?? 0).toString();
              final enrolledStudents = List<String>.from(classData['enrolledStudents'] ?? []);
              final formattedDate = _formatDate(createdAt);

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                elevation: 4,
                child: ListTile(
                  leading: const Icon(Icons.class_),
                  title: Text(classTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Description: $classDescription'),
                      Text('Time: $classTime'),
                      Text('Max Students: $maxStudents'),
                      Text('Enrolled: ${enrolledStudents.length} students'),
                      Text('Date: $formattedDate'),
                    ],
                  ),
                  onTap: () {
                    // Navigate to the ClassDetailsPage
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ClassDetailsPage(
                          classTitle: classTitle,
                          classDescription: classDescription,
                          classTime: classTime,
                          maxStudents: maxStudents,
                          enrolledStudents: enrolledStudents,
                          formattedDate: formattedDate,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _formatDate(Timestamp timestamp) {
    final DateTime date = timestamp.toDate();
    return "${date.day}/${date.month}/${date.year} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}";
  }
}
