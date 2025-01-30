import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class LeaderboardPage extends StatelessWidget {
  final String courseId;

  const LeaderboardPage({Key? key, required this.courseId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Course Leaderboard', style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.indigo,
      ),
      body: FutureBuilder<List<StudentLeaderboardData>>(
        future: _fetchLeaderboardData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No leaderboard data available'));
          }

          final leaderboardData = snapshot.data!;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Leaderboard',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo[800]
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: leaderboardData.length,
                  itemBuilder: (context, index) {
                    final student = leaderboardData[index];
                    return _buildLeaderboardItem(index + 1, student);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLeaderboardItem(int rank, StudentLeaderboardData student) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getRankColor(rank),
          child: Text(
            rank.toString(),
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
            student.name,
            style: const TextStyle(fontWeight: FontWeight.bold)
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Average Score: ${student.averageScore.toStringAsFixed(2)}%'),
            Text('Total Quizzes: ${student.totalQuizzes}'),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'Best Score: ${student.bestScore.toStringAsFixed(2)}%',
              style: TextStyle(color: Colors.green[700]),
            ),
          ],
        ),
      ),
    );
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return Colors.amber;
      case 2:
        return Colors.grey;
      case 3:
        return Colors.brown;
      default:
        return Colors.indigo;
    }
  }

  Future<List<StudentLeaderboardData>> _fetchLeaderboardData() async {
    // Fetch enrollments for this course
    final enrollmentSnapshot = await FirebaseFirestore.instance
        .collection('enrollment')
        .where('courseId', isEqualTo: courseId)
        .get();
    // Process each enrolled student
    final leaderboardData = <StudentLeaderboardData>[];

    for (var enrollment in enrollmentSnapshot.docs) {
      // Get student details

      final studentId = enrollment['studentId'];
      final userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('userId', isEqualTo: int.parse(studentId))
          .limit(1)
          .get();
      print(studentId);
      print("--------");
      if(enrollment.data().containsKey('quizzes')){
        final quizzes = enrollment['quizzes'] ?? {};
        if (quizzes.isNotEmpty) {
          double totalScore = 0;
          double bestScore = 0;
          int totalQuizzes = 0;

          quizzes.forEach((quizId, quizData) {
            if (quizData is Map &&
                quizData['totalQuestions'] != null &&
                quizData['score'] != null) {
              final quizPercentage = (quizData['score'] / quizData['totalQuestions'] * 100);
              totalScore += quizPercentage;
              bestScore = max(bestScore, quizPercentage);
              totalQuizzes++;
            }
          });

          double averageScore2 = totalQuizzes > 0 ? totalScore / totalQuizzes : 0;

          leaderboardData.add(
              StudentLeaderboardData(
                name: userSnapshot.docs.isNotEmpty
                    ? userSnapshot.docs.first['displayName']
                    : 'Unknown Student',
                averageScore: averageScore2,
                totalQuizzes: totalQuizzes,
                bestScore: bestScore,
              )
          );
        }
      }else{
        leaderboardData.add(StudentLeaderboardData(name: userSnapshot.docs.isNotEmpty? userSnapshot.docs.first['displayName']:'Unknown Student', averageScore: 0, totalQuizzes: 0, bestScore: 0));
      }
    }

    leaderboardData.sort((a, b) => b.averageScore.compareTo(a.averageScore));

    return leaderboardData;
  }
}

class StudentLeaderboardData {
  final String name;
  final double averageScore;
  final int totalQuizzes;
  final double bestScore;

  StudentLeaderboardData({
    required this.name,
    required this.averageScore,
    required this.totalQuizzes,
    required this.bestScore,
  });
}