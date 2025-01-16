import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:zego_uikit_prebuilt_video_conference/zego_uikit_prebuilt_video_conference.dart';
import 'package:edtech/liveClass/utils.dart';

class StudentPage extends StatefulWidget {
  const StudentPage({Key? key}) : super(key: key);

  @override
  _StudentPageState createState() => _StudentPageState();
}

class _StudentPageState extends State<StudentPage> {
  final TextEditingController conferenceIDController = TextEditingController();
  bool _isConferenceValid = true;
  String? _errorMessage;

  @override
  void dispose() {
    conferenceIDController.dispose(); // Dispose controller to prevent memory leaks
    super.dispose();
  }

  Future<bool> validateConferenceID(String enteredID) async {
    try {
      // Check Firestore for the entered conference ID
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('conferenceID', isEqualTo: enteredID)
          .get();

      // If a document with the entered ID exists, it's valid
      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      // Handle exceptions (e.g., network issues)
      setState(() {
        _errorMessage = "Failed to validate conference ID. Please try again.";
      });
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Student Page")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Enter Conference ID to Join", style: TextStyle(fontSize: 16)),
            TextField(
              controller: conferenceIDController,
              decoration: InputDecoration(
                labelText: 'Conference ID',
                errorText: _isConferenceValid ? null : 'Invalid Conference ID',
              ),
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 10),
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            ],
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                String enteredID = conferenceIDController.text.trim();

                // Validate conference ID
                bool isValid = await validateConferenceID(enteredID);

                if (isValid) {
                  // Navigate to the conference room
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => VideoConferencePage(conferenceID: enteredID),
                    ),
                  );
                } else {
                  // Display error if the ID is invalid
                  setState(() {
                    _isConferenceValid = false;
                  });
                }
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
