import 'package:edtech/liveClass/utils.dart';
import 'package:flutter/material.dart';
import 'package:zego_uikit_prebuilt_video_conference/zego_uikit_prebuilt_video_conference.dart';

class ClassDetailsPage extends StatelessWidget {
  final String classTitle;
  final String classDescription;
  final String classTime;
  final String maxStudents;
  final List<String> enrolledStudents;
  final String formattedDate;
  final String conferenceID;

  const ClassDetailsPage({
    Key? key,
    required this.classTitle,
    required this.classDescription,
    required this.classTime,
    required this.maxStudents,
    required this.enrolledStudents,
    required this.formattedDate,
    required this.conferenceID,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(classTitle),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Class Title: $classTitle',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('Description: $classDescription'),
            SizedBox(height: 8),
            Text('Time: $classTime'),
            SizedBox(height: 8),
            Text('Max Students: $maxStudents'),
            SizedBox(height: 8),
            Text('Enrolled Students: ${enrolledStudents.join(', ')}'),
            SizedBox(height: 8),
            Text('Date: $formattedDate'),
            ElevatedButton(
              onPressed: () async {
                String enteredID = conferenceID;

                // Validate conference ID
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => VideoConferencePage(conferenceID: enteredID),
                    ),
                  );
              },
              child: const Text("Join Meeting"),
            ),
          ],
        ),
      ),
    );
  }
}


class VideoConferencePage extends StatelessWidget {
  final String conferenceID;

  const VideoConferencePage({required this.conferenceID, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //  appBar: AppBar(title: const Text("Conference Room")),
      body: ZegoUIKitPrebuiltVideoConference(
        appID: Utils.app_id,
        appSign: Utils.app_sign_id,
        conferenceID: conferenceID,
        userID: "student_${DateTime.now().millisecondsSinceEpoch}",
        userName: "Student",
        config: ZegoUIKitPrebuiltVideoConferenceConfig(),
      ),
    );
  }
}