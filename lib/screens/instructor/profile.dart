import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../profileCard.dart';

class InstructorProfilePage extends StatefulWidget {
  @override
  _InstructorProfilePageState createState() => _InstructorProfilePageState();
}

class _InstructorProfilePageState extends State<InstructorProfilePage> {
  String _email = '';
  String _displayName = '';
  String _expertise = '';
  String _userId = '';

  TextEditingController _emailController = TextEditingController();
  TextEditingController _displayNameController = TextEditingController();
  TextEditingController _expertiseController = TextEditingController();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _loadInstructorData();
  }

  Future _loadInstructorData() async {
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
            _displayName = userDoc['displayName'] ?? 'No name';
            _expertise = userDoc['expertise'] ?? 'Expertise not specified';
            _userId = userDoc['userId'].toString() ?? 'Id not specified';

            // Initialize controllers with current values
            _emailController.text = _email;
            _displayNameController.text = _displayName;
            _expertiseController.text = _expertise;
          });
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load instructor data: $e')),
        );
      }
    }
  }

  Future _updateInstructorData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
          'email': _emailController.text.trim(),
          'displayName': _displayNameController.text.trim(),
          'expertise': _expertiseController.text.trim(),
        });

        setState(() {
          _email = _emailController.text;
          _displayName = _displayNameController.text;
          _expertise = _expertiseController.text;
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
        title: Text(_isEditing ? 'Edit Profile' : 'Instructor Profile'),
      ),
      body: SingleChildScrollView( // Wrap body content with SingleChildScrollView
        padding: const EdgeInsets.all(16.0),
        child: _isEditing
            ? Column(
          crossAxisAlignment: CrossAxisAlignment.start, // Ensure children align to the start
          children: [
            TextFormField(
              controller: _displayNameController,
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
              controller: _expertiseController,
              decoration: InputDecoration(labelText: 'Expertise Area'),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: _updateInstructorData,
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
              displayName: _displayName,
              role: 'Instructor',
              profileInfo: [
                ProfileInfoItem(icon: Icons.email, label: 'Email', value: _email),
                ProfileInfoItem(icon: Icons.work, label: 'Expertise', value: _expertise),
                ProfileInfoItem(icon: Icons.person, label: 'User ID', value: _userId),
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
