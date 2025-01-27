import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

class CourseDocumentsSection extends StatefulWidget {
  final String courseId;

  const CourseDocumentsSection({
    Key? key,
    required this.courseId,
  }) : super(key: key);

  @override
  _CourseDocumentsSectionState createState() => _CourseDocumentsSectionState();
}

class _CourseDocumentsSectionState extends State<CourseDocumentsSection> {
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
          print(path.basename(file.path));
          print("------------------------");
          downloadedFiles[path.basename(file.path)] = true;
        });
      }
    }
  }

  Future<void> uploadDocument(BuildContext context) async {
    try {
      // Pick file
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) return;

      if (result.files.single.path == null) {
        throw Exception('File path is null');
      }
      File file = File(result.files.single.path!);
      String fileName = path.basename(file.path);

      // Firebase Storage reference
      final storageRef = FirebaseStorage.instance.ref();
      final fileRef = storageRef.child('courses/${widget.courseId}/documents/$fileName');

      // Show progress dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text("Uploading document..."),
              ],
            ),
          );
        },
      );

      // Upload file
      UploadTask uploadTask = fileRef.putFile(file);

      // Wait for upload to complete
      await uploadTask.whenComplete(() async {
        String downloadUrl = await fileRef.getDownloadURL();

        // Update Firestore to add the document metadata
        final courseRef = FirebaseFirestore.instance.collection('courses').doc(widget.courseId);
        await courseRef.update({
          'files': FieldValue.arrayUnion([{
            'name': fileName,
            'url': downloadUrl,
            'uploadedAt': Timestamp.now(),
          }]),
        });

        // Close the progress dialog
        if (Navigator.canPop(context)) Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Document uploaded successfully')),
        );
      });
    } catch (e) {
      if (Navigator.canPop(context)) Navigator.pop(context); // Close dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error uploading document: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> downloadDocument(BuildContext context, String url, String fileName) async {
    try {
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
      final dio = Dio();
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Course Documents',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            ElevatedButton.icon(
              onPressed: () => uploadDocument(context),
              icon: const Icon(Icons.upload_file),
              label: const Text('Upload'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
              ),
            ),
          ],
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

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: ListTile(
                    leading: const Icon(Icons.insert_drive_file),
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
                        file['url'],
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
