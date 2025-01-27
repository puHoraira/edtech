import 'package:edtech/screens/student/student.dart';

class Quiz {
  final String quizId;
  final String title;
  final int totalMarks;
  final Map<Student, double> studentScores; // Map of Student objects to their scores

  Quiz({
    required this.quizId,
    required this.title,
    required this.totalMarks,
    this.studentScores = const {},
  });

  factory Quiz.fromMap(Map<String, dynamic> map) {
    return Quiz(
      quizId: map['quizId'],
      title: map['title'],
      totalMarks: map['totalMarks'],
      studentScores: (map['studentScores'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(
          Student.fromMap({"uid": key}), // You may need full Student data here
          value.toDouble(),
        ),
      ) ??
          {},
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'quizId': quizId,
      'title': title,
      'totalMarks': totalMarks,
      'studentScores': studentScores.map(
            (student, score) => MapEntry(student.uid, score),
      ),
    };
  }
}