import '../../course.dart';

class Instructor {
  final String uid;
  final String email;
  final String name;
  final int userId;
  final String expertise;

  Instructor({
    required this.uid,
    required this.email,
    required this.name,
    required this.userId,
    required this.expertise
  });

  factory Instructor.fromMap(Map<String, dynamic> map) {
    return Instructor(
      uid: map['uid'],
      email: map['email'],
      name: map['name'],
      userId: map['userId'],
      expertise: map['expertise']
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'userId': userId,
      'expertise': expertise
    };
  }
}