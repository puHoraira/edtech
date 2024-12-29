import 'package:edtech/quiz.dart';
import 'package:edtech/screens/student/student.dart';

import 'screens/instructor/instructor.dart';

class Course {
  final String courseId;
  final String title;
  final String description;
  final Instructor instructor;
  final List<Student> enrolledStudents;
  final List<Quiz> quizzes;

  Course({
    required this.courseId,
    required this.title,
    required this.description,
    required this.instructor,
    this.enrolledStudents = const [],
    this.quizzes = const [],
  });

  factory Course.fromMap(Map<String, dynamic> map) {
    return Course(
      courseId: map['courseId'],
      title: map['title'],
      description: map['description'],
      instructor: Instructor.fromMap(map['instructor']),
      enrolledStudents: (map['enrolledStudents'] as List<dynamic>?)
          ?.map((student) => Student.fromMap(student))
          .toList() ??
          [],
      quizzes: (map['quizzes'] as List<dynamic>?)
          ?.map((quiz) => Quiz.fromMap(quiz))
          .toList() ??
          [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'courseId': courseId,
      'title': title,
      'description': description,
      'instructor': instructor.toMap(),
      'enrolledStudents': enrolledStudents.map((student) => student.toMap()).toList(),
      'quizzes': quizzes.map((quiz) => quiz.toMap()).toList(),
    };
  }
}
