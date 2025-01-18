import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../roleSelection/roleSelection.dart';

class OnboardingPage extends StatefulWidget {
  @override
  _OnboardingPageState createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  late AnimationController _animationController;
  int _currentPage = 0;
  bool _isLastPage = false;

  final List<Map<String, dynamic>> _onboardingData = [
    {
      'image': 'assets/illustrations_1.jpg',
      'title': 'Learn Without Limits',
      'description': 'Explore and achieve your goals in a vibrant community of learners.',
      'backgroundColor': Color(0xFF1A237E),
      'foregroundColor': Color(0xFF3949AB),
    },
    {
      'image': 'assets/illustrations_2.jpg',
      'title': 'Courses That Inspire',
      'description': 'Transform every moment into an opportunity for growth.',
      'backgroundColor': Color(0xFF006064),
      'foregroundColor': Color(0xFF00838F),
    },
    {
      'image': 'assets/illustrations_3.jpg',
      'title': 'Shine Bright',
      'description': 'Join a space where you can grow, collaborate, and excel.',
      'backgroundColor': Color(0xFF1B5E20),
      'foregroundColor': Color(0xFF2E7D32),
    },
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

    _pageController.addListener(() {
      setState(() {
        _isLastPage = _pageController.page?.round() == _onboardingData.length - 1;
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _goToRoleSelection() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RoleSelectionPage()),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Animated background gradient
          AnimatedContainer(
            duration: Duration(milliseconds: 500),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  _onboardingData[_currentPage]['backgroundColor'],
                  _onboardingData[_currentPage]['foregroundColor'],
                ],
              ),
            ),
          ),

          // Content
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Skip button with shimmer effect
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextButton(
                      onPressed: _goToRoleSelection,
                      child: ShaderMask(
                        shaderCallback: (Rect bounds) {
                          return LinearGradient(
                            colors: [Colors.white, Colors.white60],
                          ).createShader(bounds);
                        },
                        child: Text(
                          'Skip',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Page content
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                        _isLastPage = index == _onboardingData.length - 1;
                      });
                    },
                    itemCount: _onboardingData.length,
                    itemBuilder: (context, index) {
                      return _buildPage(_onboardingData[index]);
                    },
                  ),
                ),

                // Navigation and indicators
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
                  child: Column(
                    children: [
                      // Page indicators
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          _onboardingData.length,
                              (index) => _buildDotIndicator(index),
                        ),
                      ),
                      SizedBox(height: 24),
                      // Navigation button
                      _buildNavigationButton(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage(Map<String, dynamic> data) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Hero image with animation
          Expanded(
            flex: 5,
            child: Hero(
              tag: data['image'],
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 20,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: Image.asset(
                    data['image'],
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),

          SizedBox(height: 40),

          // Content card with glassmorphism effect
          Container(
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  spreadRadius: -5,
                ),
              ],
            ),
            child: Column(
              children: [
                // Animated title
                TweenAnimationBuilder(
                  duration: Duration(milliseconds: 500),
                  tween: Tween<double>(begin: 0, end: 1),
                  builder: (context, double value, child) {
                    return Opacity(
                      opacity: value,
                      child: Transform.translate(
                        offset: Offset(0, 20 * (1 - value)),
                        child: child,
                      ),
                    );
                  },
                  child: Text(
                    data['title'],
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                      height: 1.2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                SizedBox(height: 16),

                // Animated description
                TweenAnimationBuilder(
                  duration: Duration(milliseconds: 700),
                  tween: Tween<double>(begin: 0, end: 1),
                  builder: (context, double value, child) {
                    return Opacity(
                      opacity: value,
                      child: Transform.translate(
                        offset: Offset(0, 30 * (1 - value)),
                        child: child,
                      ),
                    );
                  },
                  child: Text(
                    data['description'],
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 16,
                      height: 1.5,
                      letterSpacing: 0.3,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDotIndicator(int index) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      margin: EdgeInsets.symmetric(horizontal: 4),
      height: 8,
      width: _currentPage == index ? 24 : 8,
      decoration: BoxDecoration(
        color: _currentPage == index
            ? Colors.white
            : Colors.white.withOpacity(0.4),
        borderRadius: BorderRadius.circular(4),
        boxShadow: _currentPage == index
            ? [
          BoxShadow(
            color: Colors.white.withOpacity(0.3),
            blurRadius: 10,
            spreadRadius: 2,
          )
        ]
            : [],
      ),
    );
  }

  Widget _buildNavigationButton() {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      width: _isLastPage ? MediaQuery.of(context).size.width * 0.6 : 60, // Adjust width based on screen size
      height: 60,
      child: ElevatedButton(
        onPressed: () {
          if (_isLastPage) {
            _goToRoleSelection();
          } else {
            _pageController.nextPage(
              duration: Duration(milliseconds: 500),
              curve: Curves.easeInOut,
            );
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: _onboardingData[_currentPage]['backgroundColor'],
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          elevation: 8,
          shadowColor: Colors.black.withOpacity(0.3),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isLastPage) ...[
              Text(
                'Get Started',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              SizedBox(width: 8),
            ],
            Icon(
              _isLastPage ? Icons.arrow_forward : Icons.arrow_forward,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

}