import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gromore_application/form/registrationForm.dart';
import 'package:gromore_application/vegetables/vegetablesMenuHomeScreen.dart';
import 'package:slider_button/slider_button.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

class loginWithMobileNumber extends StatefulWidget {
  const loginWithMobileNumber({super.key});

  @override
  State<loginWithMobileNumber> createState() => _LoginscreenState();
}

class _LoginscreenState extends State<loginWithMobileNumber> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _mobileNumberController = TextEditingController();
  bool _isLoading = false;
  bool _isMobileNumberVisible = false;

  Future<String?> loginWithMobileNumber(String mobileNumber) async {
    try {
      // Fetch user details from Firestore based on the userName
      QuerySnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('CustomerDetails')
          .where('mobileNumber', isEqualTo: mobileNumber)
          .get();

      print("rrrrrrrr${userSnapshot}");

      if (userSnapshot.docs.isNotEmpty) {
        // If user exists, check the password
        var userDoc = userSnapshot.docs.first;
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;

        // Check if the passwords match
        if (userData['mobileNumber'] == mobileNumber) {
          return userData['mobileNumber']; // Password matches, return success
        } else {
          return '2'; // Password mismatch error
        }
      } else {
        return '4'; // No user found with this username
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
                          const EdgeInsets.only(top: 150, left: 10, right: 10),
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
                  padding: const EdgeInsets.only(top: 80),
                  child: Form(
                    key: _formKey,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 200),
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
                            const SizedBox(height: 20),
                            TextFormField(
                              controller: _mobileNumberController,
                              decoration: InputDecoration(
                                labelText: applocalizations.mobileNumber,
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
                                    _isMobileNumberVisible
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                    color: Colors.black,
                                  ),
                                  onPressed: _toggleMobileNumberVisibility,
                                ),
                              ),
                              obscureText: !_isMobileNumberVisible,
                              keyboardType: TextInputType.phone,
                              inputFormatters: [
                                FilteringTextInputFormatter
                                    .digitsOnly, // Allow only digits
                                LengthLimitingTextInputFormatter(
                                    10), // Limit input to 10 digits
                              ],
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return applocalizations
                                      .mobileNumberisrequired;
                                }
                                if (value.length != 10) {
                                  return applocalizations
                                      .enteravalid10digitmobilenumber;
                                }
                                return null;
                              },
                            ),
                            //: const SizedBox(),

                            const SizedBox(height: 20),
                            Center(
                              child: SliderButton(
                                action: () async {
                                  HapticFeedback.mediumImpact();

                                  if (!_formKey.currentState!.validate()) {
                                    return false; // Return early if validation fails
                                  }

                                  String mobileNumber =
                                      _mobileNumberController.text.trim();
                                  String? loginResult =
                                      await loginWithMobileNumber(mobileNumber);
                                  print(
                                      "1111111111111111111111111${loginResult}");
                                  if (loginResult == mobileNumber) {
                                     SharedPreferences prefs = await SharedPreferences.getInstance();
                                          prefs.setString("mobileNumber", mobileNumber);
                                    // Successful login
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              HomeScreen()),
                                    );
                                    return true;
                                  } else if (loginResult == "2") {
                                    // Show error for invalid mobile number
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(applocalizations
                                            .invalidMobileNumber),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  } else {
                                    // No user found
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(applocalizations
                                            .mobileNumberDoesNotExist),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }

                                  return false; // Prevent slider button from completing
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
                                            fontSize: 20,
                                          ),
                                        ),
                                ),
                                icon: const Icon(Icons.swipe_right_outlined),
                              ),
                            ),
                            const SizedBox(height: 20),
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

  void _toggleMobileNumberVisibility() {
    setState(() {
      _isMobileNumberVisible = !_isMobileNumberVisible;
    });
  }
}
