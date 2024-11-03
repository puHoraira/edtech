import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // Import the url_launcher package

class AboutUs extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'About Us',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.deepPurpleAccent, // Color for the AppBar
        leading: IconButton(
          icon: Icon(Icons.arrow_back), // Back button icon
          onPressed: () {
            Navigator.pop(context); // Navigate back to the previous screen
          },
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.lightBlueAccent, Colors.pinkAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ), // Gradient background for the page
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListView(
            children: [
              MemberCard(
                imagePath: 'assets/img/horaira.png',
                name: 'Abu Horaira',
                roll: '26',
                role: 'Developer',
                email: 'abuhoraira1015@gmail.com', // Add email field
                color: Colors.redAccent,
              ),
              MemberCard(
                imagePath: 'assets/img/adib.png',
                name: 'Adib Ahsan',
                roll: '60',
                role: 'Designer',
                email: 'adib.ahsan@example.com', // Add email field
                color: Colors.greenAccent,
              ),
              MemberCard(
                imagePath: 'assets/img/shova.png',
                name: 'Showkoth Osman Shova',
                roll: '11',
                role: 'Tester',
                email: 'shova.osman@example.com', // Add email field
                color: Colors.orangeAccent,
              ),
              MemberCard(
                imagePath: 'assets/img/avi.png',
                name: 'Shraban Karmoker Avi',
                roll: '44',
                role: 'Manager',
                email: 'shraban.karmoker.avi@example.com', // Add email field
                color: Colors.blueAccent,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MemberCard extends StatefulWidget {
  final String imagePath;
  final String name;
  final String roll;
  final String role;
  final String email; // New email parameter
  final Color color; // New color parameter

  const MemberCard({
    Key? key,
    required this.imagePath,
    required this.name,
    required this.roll,
    required this.role,
    required this.email, // Accept email parameter
    required this.color, // Accept color parameter
  }) : super(key: key);

  @override
  _MemberCardState createState() => _MemberCardState();
}

class _MemberCardState extends State<MemberCard> {
  bool _isTapped = false;

  // Function to send email
  void _sendEmail() async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: widget.email,
      query: encodeQueryParameters({
        'subject': 'Hello ${widget.name}', // Predefined subject
        'body': 'Hi ${widget.name}, I would like to reach out to you regarding...', // Predefined email body
      }),
    );

    // Launch the email client
    if (await canLaunch(emailLaunchUri.toString())) {
      await launch(emailLaunchUri.toString());
    } else {
      throw 'Could not launch $emailLaunchUri';
    }
  }

  // Helper function to encode query parameters
  String encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map((entry) => '${Uri.encodeComponent(entry.key)}=${Uri.encodeComponent(entry.value)}')
        .join('&');
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isTapped = true),
      onTapUp: (_) {
        setState(() => _isTapped = false);
        _sendEmail(); // Call send email function on tap up
      },
      onTapCancel: () => setState(() => _isTapped = false),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        curve: Curves.easeOut,
        transform: Matrix4.identity()..scale(_isTapped ? 0.95 : 1.0),
        margin: const EdgeInsets.symmetric(vertical: 8.0), // Add vertical spacing
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: widget.color, // Set the box color
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
        ),
        height: 150, // Adjust height for each MemberCard
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            children: [
              CircleAvatar(
                backgroundImage: AssetImage(widget.imagePath),
                radius: 50,
              ),
              SizedBox(width: 30), // Space between image and text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.name,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      widget.roll,
                      style: TextStyle(fontSize: 20, color: Colors.white70),
                    ),
                    Text(
                      widget.role,
                      style: TextStyle(fontSize: 14, color: Colors.white70),
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
