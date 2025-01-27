import 'package:edtech/screens/instructor/profile.dart';
import 'package:edtech/screens/student/enrolled.dart';
import 'package:edtech/screens/student/profile.dart';
import 'package:flutter/material.dart';
import 'course/course_page.dart';
import 'course/launchedCourses.dart';

class HomePage extends StatefulWidget {
  final String role;
  final String userId;

  const HomePage({
    Key? key,
    required this.role,
    required this.userId,
  }) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  List<Widget> _pages = [];

  @override
  void initState() {
    super.initState();
    _initializePages();
  }

  void _initializePages() {
    _pages = widget.role == 'student'
        ? [
      CoursesPage(
        userId: widget.userId,
        isInstructor: false,
      ),
      EnrolledCoursesPage(studentId: widget.userId),
      StudentProfilePage(),
    ]
        : [
      CoursesPage(
        userId: widget.userId,
        isInstructor: true,
      ),
      LaunchedCoursesPage(instructorId: widget.userId),
      InstructorProfilePage(),
    ];
  }

  Future<bool> _onWillPop() async {
    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Exit'),
          content: Text('Do you really want to quit the app?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false), // Stay in the app
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true), // Exit the app
              child: Text('Quit'),
            ),
          ],
        );
      },
    );

    // Return true to allow the app to close, false otherwise.
    return shouldExit ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Intercept the back button press
        final shouldExit = await _onWillPop();
        if (shouldExit) {
          // Exit the app programmatically
          return true;
        } else {
          return false;
        }
      },
      child: Scaffold(
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
      ),
    );
  }
}
