import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'dart:io';
import 'package:path/path.dart' as path;


class StudentCourseDocuments extends StatefulWidget {
  final String courseId;

  const StudentCourseDocuments({Key? key, required this.courseId}) : super(key: key);

  @override
  _StudentCourseDocumentsState createState() => _StudentCourseDocumentsState();
}

class _StudentCourseDocumentsState extends State<StudentCourseDocuments> {
  final Map<String, bool> downloadedFiles = {};

  @override
  void initState() {
    super.initState();
    loadDownloadedFiles();
  }

  // Load downloaded files from local storage
  Future<void> loadDownloadedFiles() async {
    final directory = await getApplicationDocumentsDirectory();

    // List all files in the documents directory
    final files = directory.listSync();
    for (var file in files) {
      if (file is File) {
        setState(() {
          downloadedFiles[path.basename(file.path)] = true;
        });
      }
    }
  }

  Future<void> downloadDocument(BuildContext context, String url, String fileName) async {
    try {
      final dio = Dio();
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/$fileName';
      final file = File(filePath);

      // Check if the file already exists locally
      if (await file.exists()) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$fileName has already been downloaded')),
        );
        return; // File already exists, no need to download again
      }

      // Proceed with downloading the file
      await dio.download(url, filePath);

      // Mark the file as downloaded
      setState(() {
        downloadedFiles[fileName] = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Downloaded: $fileName')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error downloading document: $e')),
      );
    }
  }

  Future<void> openDocument(String fileName) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/$fileName';
      await OpenFile.open(filePath);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error opening document: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Course Documents',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('courses')
              .doc(widget.courseId)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || !snapshot.data!.exists) {
              return const Center(child: Text('No documents found'));
            }

            final courseData = snapshot.data!.data() as Map<String, dynamic>;
            final files = (courseData['files'] as List<dynamic>?) ?? [];
            if (files.isEmpty) {
              return const Center(
                child: Text(
                  'No documents uploaded yet',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              );
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: files.length,
              itemBuilder: (context, index) {
                final file = files[index] as Map<String, dynamic>;
                final fileName = file['name'];
                final fileUrl = file['url'];
                final fileType = fileName.split('.').last; // to determine file type (pdf, jpg, png)

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: ListTile(
                    leading: Icon(
                      fileType == 'pdf' ? Icons.picture_as_pdf : Icons.image,
                      color: fileType == 'pdf' ? Colors.red : Colors.blue,
                    ),
                    title: Text(fileName),
                    subtitle: Text(
                      'Uploaded: ${(file['uploadedAt'] as Timestamp).toDate().toString()}',
                    ),
                    trailing: downloadedFiles[fileName] == true
                        ? IconButton(
                      icon: const Icon(Icons.visibility),
                      onPressed: () => openDocument(fileName),
                    )
                        : IconButton(
                      icon: const Icon(Icons.download),
                      onPressed: () => downloadDocument(
                        context,
                        fileUrl,
                        fileName,
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}
