import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:uddoktapay/models/customer_model.dart';
import 'package:uddoktapay/models/request_response.dart';
import 'package:uddoktapay/uddoktapay.dart';

class CourseDetailPage extends StatelessWidget {
  final String courseId;
  final String title;
  final bool isStudent;
  final String userId;

  const CourseDetailPage({
    Key? key,
    required this.courseId,
    required this.title,
    required this.isStudent,
    required this.userId,
  }) : super(key: key);

  // Fetch instructor email using the instructorId (already an integer)
  Future<String?> _fetchInstructorEmail(int instructorId) async {
    try {
      // Fetch the user document based on the integer userId
      QuerySnapshot userQuery = await FirebaseFirestore.instance
          .collection('users')
          .where('userId', isEqualTo: instructorId) // 'userId' is an integer field in Firestore
          .get();

      // Check if the query result is not empty
      if (userQuery.docs.isNotEmpty) {
        // Fetching the first document in the query result (assuming the userId is unique)
        DocumentSnapshot userDoc = userQuery.docs.first;

        if (userDoc.exists && userDoc['email'] != null) {
          return userDoc['email'] as String?;
        }
      } else {
        print('Instructor with given ID not found');
      }
    } catch (e) {
      debugPrint('Error fetching instructor email: $e');
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.deepPurple,
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('courses').doc(courseId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Course not found.'));
          }

          final courseData = snapshot.data!;
          final instructorId = courseData['instructorId'] ?? '';
          final coursePrice = courseData['price'] ?? 'N/A';
          final courseFeatures = courseData['features'] ?? [];
          final courseTopics = courseData['topics'] ?? [];
          print(userId);
          return FutureBuilder<String?>(
            future: _fetchInstructorEmail(int.parse(instructorId)),
            builder: (context, emailSnapshot) {
              if (emailSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final instructorEmail = emailSnapshot.data ?? 'No email available';

              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: ListView(
                  children: [
                    // Title Section
                    Text(
                      courseData['title'] ?? 'Untitled Course',
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.deepPurple),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Price: \$${coursePrice}',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green),
                    ),
                    const SizedBox(height: 16),

                    // Description Section
                    Text(
                      courseData['description'] ?? 'No description provided',
                      style: const TextStyle(fontSize: 16, height: 1.5),
                    ),
                    const SizedBox(height: 16),

                    // Features Section
                    if (courseFeatures.isNotEmpty) ...[
                      const Text('Course Features:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      ...courseFeatures.map((feature) => ListTile(
                        leading: const Icon(Icons.check_circle, color: Colors.green),
                        title: Text(feature, style: const TextStyle(fontSize: 16)),
                      )),
                    ],
                    const SizedBox(height: 16),

                    // Topics Section
                    if (courseTopics.isNotEmpty) ...[
                      const Text('Course Topics:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      ...courseTopics.map((topic) => ListTile(
                        leading: const Icon(Icons.radio_button_checked, color: Colors.blue),
                        title: Text(topic, style: const TextStyle(fontSize: 16)),
                      )),
                    ],
                    const SizedBox(height: 16),

                    // Instructor Info Section
                    Text('Instructor Email: $instructorEmail', style: const TextStyle(fontSize: 16)),
                    const SizedBox(height: 24),

                    // Enroll Button
                    if (isStudent)
                      ElevatedButton(
                        onPressed: () async {
                          final enrolledCourses = await FirebaseFirestore.instance
                              .collection('enrollment')
                              .where('studentId', isEqualTo: userId)
                              .where('courseId', isEqualTo: courseId)
                              .get();

                          if (enrolledCourses.docs.isEmpty) {
                            // UddoktaPay payment logic
                            final response = await UddoktaPay.createPayment(
                              context: context,
                              customer: CustomerDetails(
                                fullName: 'Your Name', // Replace with actual user's name
                                email: 'youremail@example.com', // Replace with actual user's email
                              ),
                              amount: coursePrice.toString(), // Use the price fetched from Firestore
                            );

                            if (response.status == ResponseStatus.completed) {
                              print('Payment completed, Trx ID: ${response.transactionId}');
                              print(response.senderNumber);

                              // Enroll in the course upon successful payment
                              await FirebaseFirestore.instance.collection('enrollment').add({
                                'studentId': userId,
                                'courseId': courseId,
                                'title': title,
                                'enrolledAt': FieldValue.serverTimestamp(),
                              });

                              await FirebaseFirestore.instance.collection('courses').doc(courseId).update({
                                'enrolledStudents': FieldValue.arrayUnion([userId]),
                              });

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Enrolled successfully!')),
                              );
                              Navigator.pop(context);
                            } else if (response.status == ResponseStatus.canceled) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Payment canceled.')),
                              );
                            } else if (response.status == ResponseStatus.pending) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Payment pending. Please wait.')),
                              );
                            }
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Already enrolled in this course.')),
                            );
                          }
                        },
                        child: const Text('Enroll', style: TextStyle(fontSize: 18)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.lightBlueAccent,
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
