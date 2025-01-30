import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactUsPage extends StatelessWidget {
  Future<void> _launchEmail(String email) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
    );

    try {
      print("Ami ekhane achi");
      if (await canLaunchUrl(emailUri)) {
        print("Ami ekhane achi");

        await launchUrl(emailUri);
        print("Ami ekhane achi");

      }
    } catch (e) {
      print("Ami ekhane achi");

      debugPrint('Error launching email: $e');
    }
  }
  Future<void> _launchURL(String urlString, BuildContext context) async {
    try {
      if (urlString.startsWith('mailto:')) {
        // For email, use direct Uri construction
        final email = urlString.replaceAll('mailto:', '');
        final Uri emailUri = Uri.parse('https://mail.google.com/mail/?view=cm&fs=1&to=$email');

        if (await canLaunchUrl(emailUri)) {
          await launchUrl(emailUri, mode: LaunchMode.externalApplication);
        } else {
          // Fallback - copy to clipboard
          await Clipboard.setData(ClipboardData(text: email));
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Email address copied to clipboard'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        }
      } else {
        final Uri url = Uri.parse(urlString);
        if (await canLaunchUrl(url)) {
          await launchUrl(url, mode: LaunchMode.externalApplication);
        }
      }
    } catch (e) {
      debugPrint('Error launching URL: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open link. Please try again later.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Contact Us', style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.teal,
      ),
      body: Container(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    ContactItem(
                      label: 'Email',
                      value: 'abuhoraira1015@gmail.com',
                      icon: Icons.email,
                      onTap: () => _launchEmail('mailto:abuhoraira1015@gmail.com'),
                    ),
                    Divider(),
                    ContactItem(
                      label: 'Facebook',
                      value: 'facebook.com/',
                      icon: Icons.facebook,
                      onTap: () => _launchURL('https://facebook.com/h.sayonara.a.936', context),
                    ),
                    Divider(),
                    ContactItem(
                      label: 'Instagram',
                      value: 'instagram.com/edtechapp',
                      icon: Icons.camera_alt,
                      onTap: () => _launchURL('https://instagram.com/at.horaira', context),
                    ),
                    Divider(),
                    ContactItem(
                      label: 'Phone',
                      value: '+01751777543',
                      icon: Icons.phone,
                      onTap: () => _launchURL('tel:+01751777543', context),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class ContactItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final VoidCallback onTap;

  const ContactItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.teal.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: Colors.teal),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal.shade800,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.teal,
            ),
          ],
        ),
      ),
    );
  }
}
