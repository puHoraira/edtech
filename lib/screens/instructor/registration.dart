import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class InstructorRegisterPage extends StatefulWidget {
  @override
  _InstructorRegisterPageState createState() => _InstructorRegisterPageState();
}

class _InstructorRegisterPageState extends State<InstructorRegisterPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _expertiseController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Future<int> getNextUserId() async {
    final DocumentReference counterRef = FirebaseFirestore.instance.collection('counters').doc('userIdCounter');
    try {
      return FirebaseFirestore.instance.runTransaction((transaction) async {
        final DocumentSnapshot snapshot = await transaction.get(counterRef);
        if (!snapshot.exists) {
          transaction.set(counterRef, {'current': 1});
          return 1;
        }
        final int current = snapshot['current'] as int;
        final int nextId = current + 1;
        transaction.update(counterRef, {'current': nextId});
        return nextId;
      });
    } catch (e) {
      print('Failed to fetch or update counter: $e');
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Instructor Registration'),
        backgroundColor: Colors.greenAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Full Name',
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: Icon(Icons.lock),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _expertiseController,
                    decoration: InputDecoration(
                      labelText: 'Expertise Area',
                      prefixIcon: Icon(Icons.school),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your area of expertise';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        try {
                          int userId = await getNextUserId();
                          UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
                            email: _emailController.text.trim(),
                            password: _passwordController.text.trim(),
                          );

                          await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
                            'uid': userCredential.user!.uid,
                            'email': _emailController.text.trim(),
                            'userId': userId,
                            'role': 'instructor',
                            'displayName': _nameController.text.trim(),
                            'expertise': _expertiseController.text.trim(),
                          });

                          await userCredential.user?.sendEmailVerification();
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Registration successful!')));

                          // Navigate back to the previous screen
                          Navigator.pop(context);
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Registration failed: $e')));
                        }
                      }
                    },
                    child: Text('Register'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 50), backgroundColor: Colors.greenAccent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
