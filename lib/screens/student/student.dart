import '../../course/course.dart';

class Student {
  final String uid;
  final String email;
  final String name;
  final int userId;
  final Map<String, dynamic> additionalInfo;
  final List<Course> enrolledCourses; // List of Course objects

  Student({
    required this.uid,
    required this.email,
    required this.name,
    required this.userId,
    this.additionalInfo = const {},
    this.enrolledCourses = const [],
  });

  factory Student.fromMap(Map<String, dynamic> map) {
    return Student(
      uid: map['uid'],
      email: map['email'],
      name: map['name'],
      userId: map['userId'],
      additionalInfo: map['additionalInfo'] ?? {},
      enrolledCourses: (map['enrolledCourses'] as List<dynamic>?)
          ?.map((course) =>
          Course.fromMap(course))
          .toList() ??
          [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'userId': userId,
      'additionalInfo': additionalInfo,
      'enrolledCourses': enrolledCourses.map((course) => course.toMap()).toList(),
    };
  }
}