import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../profileCard.dart';

class StudentProfilePage extends StatefulWidget {
  @override
  _StudentProfilePageState createState() => _StudentProfilePageState();
}

class _StudentProfilePageState extends State<StudentProfilePage> {
  String _email = '';
  String _displayName = '';
  String _gradeLevel = '';
  String _userId = '';

  @override
  void initState() {
    super.initState();
    _loadStudentData();
  }

  Future<void> _loadStudentData() async {
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
            _gradeLevel = userDoc['gradeLevel'] ?? 'Grade not specified';
            var userIdFromFirestore = userDoc['userId'];
            _userId = userIdFromFirestore != null
                ? userIdFromFirestore.toString()
                : 'Id not specified';
          });
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load student data: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Student Profile'),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Edit profile not implemented yet')),
              );
            },
          ),
        ],
      ),
      body: ProfileBody(
        displayName: _displayName,
        role: 'Student',
        profileInfo: [
          ProfileInfoItem(
            icon: Icons.email,
            label: 'Email',
            value: _email,
          ),
          ProfileInfoItem(
            icon: Icons.school,
            label: 'Grade Level',
            value: _gradeLevel,
          ),
          ProfileInfoItem(
            icon: Icons.person,
            label: 'User ID',
            value: _userId,
          ),
        ],
      ),
    );
  }
}
