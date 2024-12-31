import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'courseDetail.dart';

class CoursesPage extends StatefulWidget {
  final String userId; // userId is a String
  final bool isInstructor;

  const CoursesPage({
    Key? key,
    required this.userId,
    required this.isInstructor,
  }) : super(key: key);

  @override
  State<CoursesPage> createState() => _CoursesPageState();
}

class _CoursesPageState extends State<CoursesPage> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Courses'),
        backgroundColor: Colors.blueAccent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_alt),
            onPressed: () {
              // Implement filter functionality if needed
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildSearchBar(),
            const SizedBox(height: 16),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('courses').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return _buildLoading();
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return _buildNoCourses();
                  }

                  final courses = snapshot.data!.docs.where((doc) {
                    final title = doc['title']?.toString().toLowerCase() ?? '';
                    if (widget.isInstructor && doc['instructorId'] == widget.userId) {
                      return false; // Exclude instructor's own courses
                    }
                    return title.contains(_searchQuery.toLowerCase());
                  }).toList();

                  if (courses.isEmpty) {
                    return _buildNoMatchingCourses();
                  }

                  return _buildCourseList(courses);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Search courses by title...',
        prefixIcon: const Icon(Icons.search, color: Colors.blueAccent),
        suffixIcon: _searchQuery.isNotEmpty
            ? IconButton(
          icon: const Icon(Icons.clear, color: Colors.blueAccent),
          onPressed: () {
            setState(() {
              _searchQuery = '';
            });
          },
        )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.blueAccent),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.blueAccent, width: 2),
        ),
        filled: true,
        fillColor: Colors.blueAccent.withOpacity(0.1),
        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      ),
      onChanged: (value) {
        setState(() {
          _searchQuery = value.trim();
        });
      },
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildNoCourses() {
    return const Center(
      child: Text(
        'No courses available.',
        style: TextStyle(fontSize: 16, color: Colors.grey),
      ),
    );
  }

  Widget _buildNoMatchingCourses() {
    return const Center(
      child: Text(
        'No matching courses found.',
        style: TextStyle(fontSize: 16, color: Colors.grey),
      ),
    );
  }

  Widget _buildCourseList(List<QueryDocumentSnapshot> courses) {
    return ListView.builder(
      itemCount: courses.length,
      itemBuilder: (context, index) {
        final course = courses[index];
        final courseId = course.id;
        final title = course['title'] ?? 'Untitled Course';
        final description = course['description'] ?? 'No description provided';
        final instructorId = course['instructorId'].toString();

        return FutureBuilder<Map<String, dynamic>>(
          future: _getInstructorDetails(instructorId),
          builder: (context, instructorSnapshot) {
            if (instructorSnapshot.connectionState == ConnectionState.waiting) {
              return _buildLoading();
            }

            if (instructorSnapshot.hasData) {
              final instructorName = instructorSnapshot.data!['displayName'] ?? 'Unknown Instructor';

              return FutureBuilder<int>(
                future: _getEnrolledStudentCount(courseId),
                builder: (context, enrollmentSnapshot) {
                  if (enrollmentSnapshot.connectionState == ConnectionState.waiting) {
                    return _buildLoading();
                  }

                  if (enrollmentSnapshot.hasData) {
                    final enrolledCount = enrollmentSnapshot.data!;
                    return _buildCourseCard(
                      title: title,
                      instructorName: instructorName,
                      description: description,
                      enrolledCount: enrolledCount,
                      courseId: courseId,
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
  }

  Widget _buildCourseCard({
    required String title,
    required String instructorName,
    required String description,
    required int enrolledCount,
    required String courseId,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 12),
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: Colors.white,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: Colors.blueAccent,
          radius: 30,
          child: const Icon(Icons.book, size: 40, color: Colors.white),
        ),
        title: Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text('Instructor: $instructorName', style: TextStyle(fontSize: 14, color: Colors.grey[700])),
            const SizedBox(height: 4),
            Text(
              description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text('$enrolledCount students enrolled', style: const TextStyle(fontSize: 14, color: Colors.green)),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CourseDetailPage(
                courseId: courseId,
                title: title,
                isStudent: !widget.isInstructor,
                userId: widget.userId,
              ),
            ),
          );
        },
      ),
    );
  }

  Future<Map<String, dynamic>> _getInstructorDetails(String instructorId) async {
    try {
      final instructorSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('userId', isEqualTo: instructorId)
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
