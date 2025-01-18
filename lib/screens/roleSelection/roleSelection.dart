import 'package:edtech/screens/roleSelection/terms.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../instructor/login.dart';
import '../student/login.dart';
import 'aboutUs.dart';
import 'contactUs.dart';

class RoleSelectionPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Role'),
        backgroundColor: Colors.teal,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.teal.shade50, Colors.white],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Animated Welcome Section
              TweenAnimationBuilder(
                duration: Duration(milliseconds: 800),
                tween: Tween<double>(begin: 0, end: 1),
                builder: (context, double value, child) {
                  return Opacity(
                    opacity: value,
                    child: Transform.translate(
                      offset: Offset(0, 50 * (1 - value)),
                      child: child,
                    ),
                  );
                },
                child: Column(
                  children: [
                    Icon(
                      Icons.school_outlined,
                      size: 80,
                      color: Colors.teal,
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Welcome to EdTech',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal.shade800,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Choose your role to get started',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.teal.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 40),

              // Role Selection Cards
              RoleCard(
                title: 'I am a Student',
                subtitle: 'Access learning materials and track progress',
                icon: Icons.school,
                onPressed: () {Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => StudentLoginPage()),
                );}
              ),
              SizedBox(height: 20),
              RoleCard(
                title: 'I am an Instructor',
                subtitle: 'Create courses and manage students',
                icon: Icons.account_circle,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => InstructorLoginPage()),
                  );
                },
              ),
              SizedBox(height: 40),

              // Additional Features Section
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Additional Resources',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal.shade800,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 20),
                    FeatureButton(
                      title: 'About Us',
                      icon: Icons.info,
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AboutUsPage()),
                      ),
                    ),
                    SizedBox(height: 15),
                    FeatureButton(
                      title: 'Contact Us',
                      icon: Icons.contact_mail,
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ContactUsPage()),
                      ),
                    ),
                    SizedBox(height: 15),
                    FeatureButton(
                      title: 'Terms and Conditions',
                      icon: Icons.document_scanner,
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TermsAndConditionsPage(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RoleCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onPressed;

  const RoleCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.teal.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: Colors.teal,
                ),
              ),
              SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal.shade800,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
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
      ),
    );
  }
}

class FeatureButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onPressed;

  const FeatureButton({
    required this.title,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.teal,
        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: Colors.teal.shade200),
        ),
        elevation: 0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20),
          SizedBox(width: 10),
          Text(
            title,
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}
