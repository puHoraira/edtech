import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../profileCard.dart';

class StudentProfilePage extends StatefulWidget {
  @override
  _StudentProfilePageState createState() => _StudentProfilePageState();
}

class _StudentProfilePageState extends State<StudentProfilePage> {
  String _email = '';
  String _fullName = '';
  String _studentId = '';
  String _grade = '';  // Replaced enrollment history with grade
  bool _isEditing = false;

  TextEditingController _emailController = TextEditingController();
  TextEditingController _fullNameController = TextEditingController();
  TextEditingController _gradeController = TextEditingController(); // Grade controller

  @override
  void initState() {
    super.initState();
    _loadStudentData();
  }

  Future _loadStudentData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          setState(() {
            _email = user.email ?? 'No email';
            _fullName = userDoc['displayName'] ?? 'No name';
            _studentId = userDoc['userId'].toString() ?? 'ID not specified';
            _grade = userDoc['gradeLevel'] ?? 'Grade not available';

            // Initialize controllers with current values
            _emailController.text = _email;
            _fullNameController.text = _fullName;
            _gradeController.text = _grade;  // Initialize grade field
          });
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load student data: $e')),
        );
      }
    }
  }

  Future _updateStudentData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
          'email': _emailController.text.trim(),
          'fullName': _fullNameController.text.trim(),
          'grade': _gradeController.text.trim(),  // Update grade field
        });

        setState(() {
          _email = _emailController.text;
          _fullName = _fullNameController.text;
          _grade = _gradeController.text;  // Set updated grade
          _isEditing = false; // Exit editing mode
        });

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Profile updated successfully!')));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Profile' : 'Student Profile'),
      ),
      body: SingleChildScrollView( // Wrap body content with SingleChildScrollView
        padding: const EdgeInsets.all(16.0),
        child: _isEditing
            ? Column(
          crossAxisAlignment: CrossAxisAlignment.start, // Ensure children align to the start
          children: [
            TextFormField(
              controller: _fullNameController,
              decoration: InputDecoration(labelText: 'Full Name'),
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _gradeController,
              decoration: InputDecoration(labelText: 'Grade'),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: _updateStudentData,
              child: Text('Save Changes'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
                backgroundColor: Colors.greenAccent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        )
            : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ProfileBody(
              displayName: _fullName,
              role: 'Student',
              profileInfo: [
                ProfileInfoItem(icon: Icons.email, label: 'Email', value: _email),
                ProfileInfoItem(icon: Icons.school, label: 'Student ID', value: _studentId),
                ProfileInfoItem(icon: Icons.grade, label: 'Grade', value: _grade),  // Display grade
              ],
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
              child: Text('Edit Profile'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
                backgroundColor: Colors.greenAccent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
