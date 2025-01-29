import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'loginScreen.dart'; // Make sure this is correctly imported

// LocaleProvider
class LocaleProvider with ChangeNotifier {
  Locale _locale = const Locale('en'); // Default language is English

  Locale get locale => _locale;

  void changeLanguage(Locale newLocale) {
    if (_locale != newLocale) {
      _locale = newLocale;
      notifyListeners(); // Notify listeners when the locale changes
    }
  }
}

// LanguageSelector Widget
class Languageselector extends StatefulWidget {
  const Languageselector({super.key});

  @override
  State<Languageselector> createState() => _LanguageselectorState();
}

class _LanguageselectorState extends State<Languageselector>
    with SingleTickerProviderStateMixin {
  bool isEnglish = true;
  late AnimationController _controller;
  late Animation<double> _animation;
  late Animation<Offset> _slideAnimation;
  late Animation<Offset> _buttonSlideAnimation;

  void _toggleLanguage(bool value) {
    setState(() {
      isEnglish = value;
    });

    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    localeProvider.changeLanguage(
      isEnglish ? const Locale('en') : const Locale('te'),
    );
  }

  @override
  void initState() {
    super.initState();

    // Animation for scale transition
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 2));
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();

    // Animation for sliding the form and button
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _buttonSlideAnimation = Tween<Offset>(
            begin: const Offset(0, 1), end: Offset.zero)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  void _navigateWithFadeTransition(Widget page) {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 800),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final applocalizations = AppLocalizations.of(context);
    if (applocalizations == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 223, 220, 220),
      body: Stack(
        children: [
          SizedBox(
            height: 550,
            child: ClipPath(
              clipper: CustomClipPath(),
              child: Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(
                        'assets/market.jpg'), // Update to your image path
                    fit: BoxFit.cover,
                  ),
                ),
                height: MediaQuery.of(context).size.height * 0.5,
              ),
            ),
          ),

          // Overlay content
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SlideTransition(
                position: _slideAnimation,
                child: Padding(
                  padding: const EdgeInsets.only(top: 500, left: 5, right: 5),
                  child: Row(
                    children: [
                      Text(
                        applocalizations.registrationForm,
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      const Text(
                        'मराठी',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 19,
                        ),
                      ),
                      Transform.scale(
                        scale: 0.8,
                        child: Switch(
                          value: isEnglish,
                          onChanged: _toggleLanguage,
                          activeColor: Colors.blue,
                        ),
                      ),
                      const Text(
                        'English',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 19,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 100,
              ),
              SlideTransition(
                position: _buttonSlideAnimation,
                child: Center(
                    child: SizedBox(
                  height: 70,
                  width: 200,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Loginscreen(),
                        ),
                      );
                    },
                    child: Text(
                      applocalizations.clickonnext,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize: 20),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange.shade300,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15), // <-- Radius
                      ),
                    ),
                  ),
                )),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

//clipath class...
class CustomClipPath extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height * 0.8); // Start from the bottom left

    // First wave
    path.quadraticBezierTo(size.width * 0.28, size.height * 0.9,
        size.width * 0.5, size.height * 0.8);

    // Second wave
    path.quadraticBezierTo(
        size.width * 0.75, size.height * 0.7, size.width, size.height * 0.8);

    path.lineTo(size.width, 0); // Draw to the top-right corner
    path.close(); // Close the path
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
