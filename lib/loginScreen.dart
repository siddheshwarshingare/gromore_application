import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gromore_application/loginWithMobileNumber.dart';
import 'package:gromore_application/registrationForm.dart';
import 'package:gromore_application/vegetablesMenuHomeScreen.dart';
import 'package:slider_button/slider_button.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Loginscreen extends StatefulWidget {
  const Loginscreen({super.key});

  @override
  State<Loginscreen> createState() => _LoginscreenState();
}

class _LoginscreenState extends State<Loginscreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  String userName = '';
  String passWord = '';

  Future<String?> login(String userName, String passWord) async {
    try {
      // Fetch user details from Firestore based on the userName
      QuerySnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('CustomerDetails')
          .where('userName', isEqualTo: userName)
          .get();

      print("rrrrrrrr${userSnapshot}");

      if (userSnapshot.docs.isNotEmpty) {
        // If user exists, check the password
        var userDoc = userSnapshot.docs.first;
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;

        // Check if the passwords match
        if (userData['passWord'] == passWord) {
          return userData['passWord']; // Password matches, return success
        } else {
          return 'Invalid password'; // Password mismatch error
        }
      } else {
        return 'Username does not exist'; // No user found with this username
      }
    } catch (e) {
      print('Login error: $e');
      return 'Error occurred during login'; // Error handling
    }
  }

  @override
  Widget build(BuildContext context) {
    final applocalizations = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                // Gradient background
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black,
                        Colors.green,
                        Colors.blueAccent,
                        Colors.lightGreen,
                        Colors.black
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  height: MediaQuery.of(context).size.height,
                ),
                // Text at the top of the screen
                Column(
                  children: [
                    const Icon(
                      Icons.star_border_purple500_rounded,
                      size: 40,
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.only(top: 100, left: 10, right: 10),
                      child: Text(
                        '  ${applocalizations!.welcomeToOurGromoreFarming}🙏 ',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),

                Padding(
                  padding: const EdgeInsets.only(top: 100),
                  child: Form(
                    key: _formKey,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 120),
                      child: Container(
                        margin: const EdgeInsets.all(30),
                        padding: const EdgeInsets.all(20),
                        decoration: const BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.all(
                            Radius.circular(20),
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 30),
                            TextFormField(
                              controller: _usernameController,
                              decoration: InputDecoration(
                                labelText: applocalizations!.username,
                                labelStyle: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                                prefixIcon: const Icon(
                                  Icons
                                      .person, // You can change this to any icon you prefer
                                  color: Colors.black,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                      color: Colors.black, width: 2),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                      color: Colors.black, width: 2),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                      color: Colors.redAccent, width: 1),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                      color: Colors.black, width: 2),
                                ),
                              ),
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return applocalizations.usernameisrequired;
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                              controller: _passwordController,
                              decoration: InputDecoration(
                                labelText: applocalizations.password,
                                labelStyle: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                                prefixIcon: const Icon(
                                  Icons.lock, // Lock icon before password field
                                  color: Colors.black,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                      color: Colors.black, width: 2),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                      color: Colors.redAccent, width: 1),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                      color: Colors.black, width: 2),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: const BorderSide(
                                      color: Colors.black, width: 2),
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _isPasswordVisible
                                        ? Icons.visibility
                                        : Icons
                                            .visibility_off, // Proper eye icon
                                    color: Colors.black,
                                  ),
                                  onPressed: _togglePasswordVisibility,
                                ),
                              ),
                              obscureText: !_isPasswordVisible,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return applocalizations.passwordisrequired;
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),
                            Center(
                              child: SizedBox(
                                height: 50,
                                width: 230,
                                child: SliderButton(
                                  action: () async {
                                    HapticFeedback.mediumImpact();
                                    String username = _usernameController.text;
                                    String password = _passwordController.text;
                                    print("1111111111==$username");
                                    print("1111111111==$password");
                                    if (_formKey.currentState!.validate()) {
                                      setState(() {
                                        _isLoading = true;
                                      });
                                      String? loginResult =
                                          await login(username, password);
                                
                                      if (loginResult != null) {
                                        if (loginResult == password) {
                                          SharedPreferences prefs = await SharedPreferences.getInstance();
                                          prefs.setString("userName", username);
                                          prefs.setString("passWord", password);
                                          // Navigate to the next screen if login is successful
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                   HomeScreen()),
                                          );
                                        } else {
                                          // Show error message if login fails
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(loginResult),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                        }
                                      } else {
                                        // Show generic error if something went wrong
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                                "An error occurred, please try again."),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      }
                                
                                      setState(() {
                                        _isLoading = false;
                                      });
                                    }
                                    return false;
                                  },
                                  label: Center(
                                    child: _isLoading
                                        ? CircularProgressIndicator() // Show loading spinner while logging in
                                        : Text(
                                            applocalizations.login,
                                            style: const TextStyle(
                                              color: Color.fromARGB(
                                                  255, 212, 113, 113),
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                  ),
                                  icon: const Icon(Icons.swipe_right_outlined),
                                ),
                              ),
                            ),
                            SizedBox(height: 10,),
                            Center(child: Text(applocalizations.or,style: TextStyle(color: Colors.pink,fontSize: 16),)),
                          
                            //Login With Mobile Number 

                            Padding(
                              padding: const EdgeInsets.only(left: 20),
                              child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const loginWithMobileNumber (),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                      foregroundColor: Colors.black,
                                      backgroundColor: Colors.grey.shade400,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 15, horizontal: 30),
                                      elevation: 10,
                                      shadowColor: Colors.black),
                                  child: Text(
                                    applocalizations.loginWithMobileNumber,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                ),
                            ),
                            const SizedBox(height: 20),
                            Center(
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const CustomFormScreen(),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                    foregroundColor: Colors.black,
                                    backgroundColor: Colors.grey.shade400,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 15, horizontal: 30),
                                    elevation: 10,
                                    shadowColor: Colors.black),
                                child: Text(
                                  applocalizations.registerhere,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _togglePasswordVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }

  _loginMethod(String username, String password) async {
    setState(() {
      _isLoading = true;
    });
    await Future.delayed(const Duration(seconds: 1));

    if (username == "admin" && password == "admin") {
      return Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const Placeholder(),
        ),
      );
    } else {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          backgroundColor: Colors.red,
          duration: Duration(milliseconds: 700),
          content: Center(
            child: Text(
              "Invalid credentials",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      );
    }
  }
}