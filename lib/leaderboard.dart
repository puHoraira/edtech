import 'package:edtech/quiz.dart';
import 'package:edtech/screens/student/student.dart';

import 'course.dart';

class LeaderboardEntry {
  final Student student; // Student object
  final double percentage;

  LeaderboardEntry({
    required this.student,
    required this.percentage,
  });
}

class Leaderboard {
  final List<LeaderboardEntry> entries;

  Leaderboard({this.entries = const []});

  void calculateLeaderboard(List<Student> students, Course course) {
    final Map<Student, double> studentTotalScores = {};
    final Map<Student, int> studentMaxScores = {};

    for (Quiz quiz in course.quizzes) {
      for (var entry in quiz.studentScores.entries) {
        studentTotalScores[entry.key] =
            (studentTotalScores[entry.key] ?? 0) + entry.value;
        studentMaxScores[entry.key] =
            (studentMaxScores[entry.key] ?? 0) + quiz.totalMarks;
      }
    }

    entries.clear();
    studentTotalScores.forEach((student, totalScore) {
      final maxScore = studentMaxScores[student] ?? 1;
      final percentage = (totalScore / maxScore) * 100;

      entries.add(LeaderboardEntry(
        student: student,
        percentage: percentage,
      ));
    });

    entries.sort((a, b) => b.percentage.compareTo(a.percentage));
  }
}