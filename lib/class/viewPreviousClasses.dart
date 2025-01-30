import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edtech/liveClass/utils.dart';
import 'package:flutter/material.dart';
import 'package:zego_uikit_prebuilt_video_conference/zego_uikit_prebuilt_video_conference.dart';

import 'classDetailPage.dart';

class ViewPreviousClassesPage extends StatelessWidget {
  final String courseId;

  const ViewPreviousClassesPage({Key? key, required this.courseId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Previous Classes', style: TextStyle(color: Colors.white),),
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
              final fixedConferenceID = classData['conferenceID'];

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
                      ElevatedButton(
              onPressed: () async {
                // Save conference ID in Firebase
             

                // Navigate to VideoConferencePage with the generated ID
                Navigator.push(
                  context,//
                  MaterialPageRoute(
                    builder: (context) =>
                        VideoConferencePage(conferenceID: fixedConferenceID, classTitles: classTitle,),
                  ),
                );
              },
              child: const Text("Start Meeting"),
            ),
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
                          conferenceID: fixedConferenceID,
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

class VideoConferencePage extends StatelessWidget {
  final String conferenceID;
  final String classTitles;

  const VideoConferencePage({required this.conferenceID, required this.classTitles, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: const Text("Conference Room")),
      body: ZegoUIKitPrebuiltVideoConference(
        appID: Utils.app_id,
        appSign: Utils.app_sign_id,
        conferenceID: conferenceID,
        userID: "student_${DateTime.now().millisecondsSinceEpoch}",
        userName: classTitles,
        config: ZegoUIKitPrebuiltVideoConferenceConfig(),
      ),
    );
  }
}