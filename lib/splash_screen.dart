import 'package:flutter/material.dart';
import 'package:gromore_application/admin/adminDashboard.dart';
import 'package:gromore_application/language/languageSelector.dart';
import 'package:gromore_application/vegetables/vegetablesMenuHomeScreen.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Splashscreen extends StatefulWidget {
  const Splashscreen({super.key});

  @override
  State<Splashscreen> createState() => _SplashscreenState();
}

class _SplashscreenState extends State<Splashscreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final List<String> _animations = [
    'assets/animation/vegeatble5.json',
    'assets/animation/vegetable4.json',
  ];
  String? userName = '';
  String? passWord = '';
  String? mobileNumber = '';
  String? result = '';

  void _navigateToNextScreen() async {
    // Simulate a delay for 1 second
    await Future.delayed(const Duration(seconds: 2));

    // Check login status
    bool isLoggedIn = await _checkLoginStatus();

    // Navigate based on login status
    if (isLoggedIn) {

      // This login is for admin only 
      
      userName=="Raje@1234"&&passWord=="Raje@12345"? 
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) =>  AdminDashboard()),
      ):
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomeScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const Languageselector()),
      );
    }
  }

  Future<bool> _checkLoginStatus() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    // Retrieve the username from SharedPreferences
    setState(() {
      userName = prefs.getString('userName');
      passWord = prefs.getString('passWord');
      mobileNumber = prefs.getString("mobileNumber");
      result=  userName == null ? mobileNumber : userName;
    });
    // Check if the username is not null or empty
    return result != null;
  }

  @override
  void initState() {
    super.initState();

    Future.delayed(
      Duration.zero, () 
    {
      _navigateToNextScreen();
      _startAutoSlide();
    }
    );

    // Navigate to LoginScreen after 6 seconds
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Languageselector()),
      );
    });
  }

  void _startAutoSlide() {
    Future.delayed(const Duration(seconds: 1), () {
      if (_currentPage < _animations.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }

      if (mounted) {
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SizedBox(
          height: 300,
          width: 500,
          child: PageView.builder(
            controller: _pageController,
            itemCount: _animations.length,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              return Lottie.asset(
                _animations[index],
              );
            },
          ),
        ),
      ),
    );
  }
}