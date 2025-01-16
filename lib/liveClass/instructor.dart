import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import 'package:zego_uikit_prebuilt_video_conference/zego_uikit_prebuilt_video_conference.dart';
import 'package:edtech/liveClass/utils.dart';


class InstructorPage extends StatefulWidget {
  const InstructorPage({Key? key}) : super(key: key);

  @override
  _InstructorPageState createState() => _InstructorPageState();
}

class _InstructorPageState extends State<InstructorPage> {
  late String fixedConferenceID;

  @override
  void initState() {
    super.initState();
    fixedConferenceID = Random().nextInt(100000).toString(); // Initialize here
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Instructor Page")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Conference ID: $fixedConferenceID"),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                // Save conference ID in Firebase


                // Navigate to VideoConferencePage with the generated ID
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        VideoConferencePage(conferenceID: fixedConferenceID),
                  ),
                );
              },
              child: const Text("Start Meeting"),
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
      // appBar: AppBar(title: const Text("Conference Room")),
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
