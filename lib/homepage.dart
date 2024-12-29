import 'package:edtech/screens/instructor/instructor.dart';
import 'package:edtech/screens/instructor/profile.dart';
import 'package:edtech/screens/student/enrolled.dart';
import 'package:edtech/screens/student/profile.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';

import 'course_page.dart';
import 'launchedCourses.dart';

class HomePage extends StatefulWidget {
  final String role;

  const HomePage({
    Key? key,
    required this.role,
  }) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  List<Widget> _pages = [];
  String? userId;
  // Instructor? inst =

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializePages();
    });
  }

  void _initializePages() {
    // Extract query parameters
    final queryParams = GoRouter.of(context)
        .routerDelegate
        .currentConfiguration!
        .uri
        .queryParameters;

    userId = queryParams['instructorId'] ?? queryParams['studentId'];
    print(userId);

    setState(() {
      _pages = widget.role == 'student'
          ? [
        CoursesPage(userId: userId == null?'0' :userId!,isInstructor: false,),
        EnrolledCoursesPage(studentId: userId == null?'0' :userId!,),
        StudentProfilePage(),
      ]
          : [
        CoursesPage(userId: userId == null?'0' :userId!,isInstructor: true,),
        LaunchedCoursesPage(instructorId: userId == null? '0' : userId!),
        InstructorProfilePage(),
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages.isEmpty
          ? Center(child: CircularProgressIndicator()) // Show a loader until pages are set
          : _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Courses'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
