import 'package:flutter/material.dart';
import 'package:gromore_application/loginScreen.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

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

class _LanguageselectorState extends State<Languageselector> {
  bool isEnglish = true;

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
  Widget build(BuildContext context) {
    final applocalizations = AppLocalizations.of(context);
    if (applocalizations == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: Column(
        children: [
          SizedBox(
            height: 100,
          ),
          Image.asset("assets/org3.jpeg"),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  applocalizations.registrationForm,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                const Text(
                  'मराठी',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Transform.scale(
                  scale: 0.8,
                  child: Switch(
                    value: isEnglish,
                    onChanged: _toggleLanguage,
                    activeColor: Colors.green,
                  ),
                ),
                const Text(
                  'English',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => Loginscreen()));
              },
              child: Text(applocalizations.clickonnext))
        ],
      ),
    );
  }
}
