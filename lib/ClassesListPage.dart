// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
//
// import 'classDetailPage.dart';
//
// class ClassesListPage extends StatelessWidget {
//   final String courseId;
//
//   const ClassesListPage({Key? key, required this.courseId}) : super(key: key);
//
//   Widget _buildClassesList() {
//     return FutureBuilder<QuerySnapshot>(
//       future: FirebaseFirestore.instance
//           .collection('classes')
//           .where('courseId', isEqualTo: courseId)
//           .get(),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Center(child: CircularProgressIndicator());
//         }
//
//         if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//           return const Center(
//             child: Text(
//               'No classes scheduled.',
//               style: TextStyle(fontSize: 18, color: Colors.grey),
//             ),
//           );
//         }
//
//         final classes = snapshot.data!.docs;
//         return ListView.builder(
//           shrinkWrap: true,
//           physics: const NeverScrollableScrollPhysics(),
//           itemCount: classes.length,
//           itemBuilder: (context, index) {
//             final classData = classes[index];
//             final classTitle = classData['classTitle'] ?? 'Class Title';
//             final classDescription = classData['classDescription'] ?? 'Description not available';
//             final classTime = classData['classTime'] ?? 'Time not set';
//             final maxStudents = classData['maxStudents'].toString() ?? 'No limit';
//             final enrolledStudents = List<String>.from(classData['enrolledStudents'] ?? []);
//             final formattedDate = classData['createdAt'].toDate().toString();
//
//             return Card(
//               elevation: 4,
//               margin: const EdgeInsets.symmetric(vertical: 8),
//               child: ListTile(
//                 leading: const Icon(Icons.video_call, color: Colors.indigo),
//                 title: Text(
//                   classTitle,
//                   style: const TextStyle(fontSize: 18),
//                 ),
//                 subtitle: Text(
//                   'Scheduled At: ${classData['classTime']}',
//                   style: const TextStyle(color: Colors.grey),
//                 ),
//                 onTap: () {
//                   // Navigate to class details page
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => ClassDetailsPage(
//                         classTitle: classTitle,
//                         classDescription: classDescription,
//                         classTime: classTime,
//                         maxStudents: maxStudents,
//                         enrolledStudents: enrolledStudents,
//                         formattedDate: formattedDate,
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             );
//           },
//         );
//       },
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Classes'),
//         backgroundColor: Colors.blueAccent,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: _buildClassesList(),
//       ),
//     );
//   }
// }
