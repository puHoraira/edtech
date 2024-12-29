import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'courseDetail.dart';

class CoursesPage extends StatelessWidget {
  final String userId; // userId is a String
  final bool isInstructor;

  const CoursesPage({
    Key? key,
    required this.userId,
    required this.isInstructor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Courses'),
        backgroundColor: Colors.blueAccent,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('courses').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No courses available.'));
          }

          // If the user is an instructor, filter out their own courses
          final courses = snapshot.data!.docs.where((doc) {
            if (isInstructor) {
              return doc['instructorId'] != userId; // Compare strings directly
            }
            return true;
          }).toList();

          return ListView.builder(
            itemCount: courses.length,
            itemBuilder: (context, index) {
              final course = courses[index];
              final courseId = course.id;
              final title = course['title'] ?? 'Untitled Course';
              final description = course['description'] ?? 'No description provided';
              final instructorId = course['instructorId'].toString(); // Ensure it's a string

              return FutureBuilder<Map<String, dynamic>>(
                future: _getInstructorDetails(instructorId),
                builder: (context, instructorSnapshot) {
                  if (instructorSnapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (instructorSnapshot.hasData) {
                    final instructorName = instructorSnapshot.data!['displayName'] ?? 'Unknown Instructor';

                    return FutureBuilder<int>(
                      future: _getEnrolledStudentCount(courseId),
                      builder: (context, enrollmentSnapshot) {
                        if (enrollmentSnapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        if (enrollmentSnapshot.hasData) {
                          final enrolledCount = enrollmentSnapshot.data!;
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(16),
                              leading: const Icon(Icons.book, size: 60, color: Colors.blueAccent),
                              title: Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Instructor: $instructorName', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                                  Text(description, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 14, color: Colors.grey)),
                                  const SizedBox(height: 8),
                                  Text('$enrolledCount students enrolled', style: TextStyle(fontSize: 14, color: Colors.green)),
                                ],
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CourseDetailPage(
                                      courseId: courseId,
                                      title: title,
                                      isStudent: !isInstructor,
                                      userId: userId,
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        }

                        return Container();
                      },
                    );
                  }

                  return Container();
                },
              );
            },
          );
        },
      ),
    );
  }

  Future<Map<String, dynamic>> _getInstructorDetails(String instructorId) async {
    try {
      // Convert the instructorId to a number before querying
      final int numericId = int.parse(instructorId);
      final instructorSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('userId', isEqualTo: numericId)
          .limit(1)
          .get();

      if (instructorSnapshot.docs.isNotEmpty) {
        return instructorSnapshot.docs.first.data();
      }
      return {};
    } catch (e) {
      print('Error fetching instructor details: $e');
      return {};
    }
  }

  Future<int> _getEnrolledStudentCount(String courseId) async {
    final enrolledCoursesSnapshot = await FirebaseFirestore.instance
        .collection('enrollment')
        .where('courseId', isEqualTo: courseId)
        .get();

    return enrolledCoursesSnapshot.docs.length;
  }
}