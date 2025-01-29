import 'package:flutter/material.dart';
import 'package:gromore_application/languageSelector.dart';
import 'package:lottie/lottie.dart';

class Splashscreen extends StatefulWidget {
  const Splashscreen({super.key});

  @override
  State<Splashscreen> createState() => _SplashscreenState();
}

class _SplashscreenState extends State<Splashscreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final List<String> _animations = [
    'assets/animation/vegetable2.json',
    'assets/animation/vegetable4.json',
  ];

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () {
      _startAutoSlide();
    });

    // Navigate to LoginScreen after 6 seconds
    Future.delayed(const Duration(seconds: 6), () {
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
