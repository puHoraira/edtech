import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class TermsAndConditionsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Terms and Conditions'),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 2,
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Terms of Use',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal.shade800,
                      ),
                    ),
                    SizedBox(height: 20),
                    TermsSection(
                      title: '1. Acceptance of Terms',
                      content: 'By accessing and using this application, you accept and agree to be bound by the terms and provisions of this agreement.',
                    ),
                    TermsSection(
                      title: '2. User Registration',
                      content: 'Users must register with valid information and maintain the security of their account credentials. Users are responsible for all activities that occur under their account.',
                    ),
                    TermsSection(
                      title: '3. Privacy Policy',
                      content: 'Your use of the application is also governed by our Privacy Policy. Please review our Privacy Policy, which also governs the application and informs users of our data collection practices.',
                    ),
                    TermsSection(
                      title: '4. User Conduct',
                      content: 'Users agree to use the application in a manner consistent with all applicable laws and regulations. Users shall not use the application for any illegal or unauthorized purpose.',
                    ),
                    TermsSection(
                      title: '5. Intellectual Property',
                      content: 'All content included in or made available through the application is the property of EdTech App or its licensors and is protected by intellectual property laws.',
                    ),
                    TermsSection(
                      title: '6. Termination',
                      content: 'We reserve the right to terminate or suspend access to our application immediately, without prior notice or liability, for any reason whatsoever.',
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Last updated: December 2024',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'I Understand',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TermsSection extends StatelessWidget {
  final String title;
  final String content;

  const TermsSection({
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.teal.shade700,
            ),
          ),
          SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade700,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}