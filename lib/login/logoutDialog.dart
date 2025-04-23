import 'package:flutter/material.dart';
import 'package:gromore_application/login/commenclasses/apiconstant.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gromore_application/login/loginScreen.dart';
import 'package:http/http.dart' as http;

class LogoutDialog extends StatefulWidget {
  const LogoutDialog({Key? key}) : super(key: key);

  static void show(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const LogoutDialog();
      },
    );
  }

  @override
  State<LogoutDialog> createState() => _LogoutDialogState();
}

class _LogoutDialogState extends State<LogoutDialog> {
  bool _isLoading = false; // Loading state
  // logout method
  Future<void> _logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token') ?? '';
    String apiUrl = Apiconstants.logOut;
    setState(() {
      _isLoading = true;
    });

    try {
      print("1111111111111111111$token");
      final response = await http.post(
        Uri.parse(apiUrl),
        body: null,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
      );

      if (response.statusCode == 200) {
        prefs.clear();
        Navigator.pop;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Logout sucessfully")),
        );
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const Loginscreen(),
          ),
          (route) => false, // This condition removes all previous routes
        );
        print("Logged Out");
      } else {
        setState(() {
          _isLoading = false;
        });
        print(response.statusCode);
        print(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            ),
            backgroundColor: Colors.red,
            duration: const Duration(milliseconds: 700),
            content: Title(
              color: Colors.redAccent,
              child: const Center(
                child: Text(
                  "Can't Logout",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          backgroundColor: Colors.red,
          duration: const Duration(milliseconds: 700),
          content: Title(
            color: Colors.redAccent,
            child: const Center(
              child: Text(
                "An error occurred. Please try again later.",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Future<void> _logout(BuildContext context) async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   await prefs.clear();

  //   // Navigate to Login Screen and remove all previous routes
  //   Navigator.pushAndRemoveUntil(
  //     context,
  //     MaterialPageRoute(builder: (_) => const Loginscreen()),
  //     (route) => false,
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        "Logout Confirmation",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: const Text("तुम्हाला खात्री आहे की तुम्ही लॉगआउट करू इच्छिता?"),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Close dialog
          },
          child: const Text(
            "Cancel",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        ElevatedButton(
          onPressed: () => _logout(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
          ),
          child: const Text(
            "Logout",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
