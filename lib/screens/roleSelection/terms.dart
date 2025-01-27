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
                      content: 'By accessing and using this application, you accept and agree to be bound by the terms and provisions of this agreement. If you do not agree to these terms, you should not use the app.',
                    ),
                    TermsSection(
                      title: '2. User Registration',
                      content: 'Users must register with accurate and valid information. You are responsible for maintaining the confidentiality of your account and password. Any unauthorized use of your account should be reported immediately.',
                    ),
                    TermsSection(
                      title: '3. Privacy Policy',
                      content: 'By using the application, you consent to the collection and use of personal data as described in our Privacy Policy. Please review it for detailed information on our data practices.',
                    ),
                    TermsSection(
                      title: '4. Permissions',
                      content: 'To provide full functionality, this app may request permissions such as camera access, location, and notifications. By accepting these terms, you authorize the app to request these permissions.',
                    ),
                    TermsSection(
                      title: '5. User Conduct',
                      content: 'You agree to use the app only for lawful purposes. Prohibited activities include, but are not limited to, fraud, harassment, spam, or any activity that violates local or international laws.',
                    ),
                    TermsSection(
                      title: '6. Intellectual Property',
                      content: 'All content, logos, and trademarks within this app are the property of EdTech App or its licensors. Unauthorized reproduction or distribution is prohibited.',
                    ),
                    TermsSection(
                      title: '7. Third-Party Links',
                      content: 'This app may contain links to third-party websites or services. We are not responsible for the content or privacy practices of such sites. Please review their policies separately.',
                    ),
                    TermsSection(
                      title: '8. Limitation of Liability',
                      content: 'To the fullest extent permitted by law, EdTech App is not liable for any direct, indirect, incidental, special, or consequential damages resulting from your use of this app.',
                    ),
                    TermsSection(
                      title: '9. Termination of Account',
                      content: 'We reserve the right to suspend or terminate your account if you violate any of these terms. You will be notified of any such action.',
                    ),
                    TermsSection(
                      title: '10. Governing Law',
                      content: 'These terms will be governed by and construed in accordance with the laws of [Your Country/State]. Any disputes will be resolved in the courts located in [Jurisdiction].',
                    ),
                    TermsSection(
                      title: '11. Updates to Terms',
                      content: 'We may update these terms from time to time. You will be notified of significant changes. Continued use of the app after such updates constitutes acceptance of the new terms.',
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Last updated: January 2025',
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
