import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutUsPage extends StatelessWidget {
  final List<Map<String, String>> developers = [
    {
      'name': 'Md. Abu Horaira',
      'role': 'Lead Developer',
      'email': 'abuhoraira1015@gmail.com',
      'image': 'assets/horaira.png', // Local asset path
    },
    {
      'name': 'Shraban Karomoker Avi',
      'role': 'UI/UX Designer',
      'email': 'abuhoraira1015@gmail.com',
      'image': 'assets/avi.png', // Local asset path
    },
    {
      'name': 'Showkoth Osman Shova',
      'role': 'Backend Developer',
      'email': 'abuhoraira1015@gmail.com',
      'image': 'assets/shova.png', // Local asset path
    },
    {
      'name': 'Md. Adib Ahsan',
      'role': 'Manager',
      'email': 'abuhoraira1015@gmail.com',
      'image': 'assets/adib.png', // Local asset path
    },
  ];

  Future<void> _launchEmail(String email) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
    );

    try {
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
      }
    } catch (e) {
      debugPrint('Error launching email: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('About Us'),
        backgroundColor: Colors.teal,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20.0),
        itemCount: developers.length,
        itemBuilder: (context, index) {
          final developer = developers[index];
          return Card(
            elevation: 3,
            margin: EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              contentPadding: EdgeInsets.all(16),
              leading: CircleAvatar(
                radius: 30,
                backgroundImage:
                    AssetImage(developer['image']!), // Load local asset
              ),
              title: Text(
                developer['name']!,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 4),
                  Text(developer['role']!),
                  SizedBox(height: 8),
                  TextButton.icon(
                    icon: Icon(Icons.email, size: 18),
                    label: Text('Contact'),
                    onPressed: () => _launchEmail(developer['email']!),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
