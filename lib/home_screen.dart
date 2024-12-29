import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Simulate a loading delay
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isLoading = false;
      });
    });
  }

  Future<void> _contactUs() async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'abuhoraira1015@gmail.com',
      query: 'subject=Contacting EdTech Support',
    );
    try {
      await launchUrl(emailLaunchUri);
    } catch (e) {
      print('Could not launch email app: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "EdTech: Our First App",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.indigo,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF283593), Color(0xFF3949AB), Color(0xFF5C6BC0)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: _isLoading
              ? const CircularProgressIndicator(
            color: Colors.white,
          )
              : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo Section
              CircleAvatar(
                backgroundImage: const AssetImage('assets/img/logo.jpeg'),
                radius: 50,
              ),
              const SizedBox(height: 22),
              const Text(
                "Welcome to EdTech!",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Your gateway to learning",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 40),

              // Buttons Section
              _buildMenuButton("Login", Colors.blueAccent, () {
                Navigator.pushNamed(context, '/login');
              }),
              const SizedBox(height: 16),
              _buildMenuButton("About Us", Colors.teal, () {
                Navigator.pushNamed(context, '/about');
              }),
              const SizedBox(height: 16),
              _buildMenuButton("Contact Us", Colors.deepOrange, _contactUs),
              const SizedBox(height: 16),
              _buildMenuButton("Privacy Policy", Colors.purple, () {
                Navigator.pushNamed(context, '/privacy');
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuButton(String text, Color color, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 60.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        elevation: 4,
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
