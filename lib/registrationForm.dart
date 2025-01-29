import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:lottie/lottie.dart';

class CustomFormScreen extends StatefulWidget {
  const CustomFormScreen({Key? key}) : super(key: key);

  @override
  State<CustomFormScreen> createState() => _CustomFormScreenState();
}

class _CustomFormScreenState extends State<CustomFormScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool isSubmitting = false;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    final applocalizations = AppLocalizations.of(context);

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              height: double.infinity,
              width: double.infinity,
              child: const Image(
                alignment: Alignment.center,
                image: AssetImage('assets/color.avif'),
                fit: BoxFit.fill,
              ),
            ),
          ),
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.purple,
                  Colors.purpleAccent,
                  Colors.purple,
                  Colors.deepPurpleAccent,
                  Colors.deepPurple,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            height: MediaQuery.of(context).size.height,
          ),
          // Form Content
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 80),
                    Center(
                      child: Text(
                        applocalizations!.registrationForm,
                        style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Name Field
                    TextFormField(
                      controller: nameController,
                      decoration: _inputDecoration(applocalizations.name),
                      validator: (value) => value == null || value.isEmpty
                          ? applocalizations.nameisrequired
                          : null,
                    ),
                    const SizedBox(height: 15),

                    // Mobile Field
                    TextFormField(
                      controller: mobileController,
                      decoration:
                          _inputDecoration(applocalizations.mobileNumber),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return applocalizations.mobileNumberisrequired;
                        }
                        if (value.length != 10) {
                          return applocalizations
                              .enteravalid10digitmobilenumber;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),

                    // Username Field
                    TextFormField(
                      controller: usernameController,
                      decoration: _inputDecoration(applocalizations.username),
                      validator: (value) => value == null || value.isEmpty
                          ? applocalizations.usernameisrequired
                          : null,
                    ),
                    const SizedBox(height: 15),

                    // Password Field
                    TextFormField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: _inputDecoration(applocalizations.password),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return applocalizations.passwordisrequired;
                        }
                        if (value.length < 6) {
                          return applocalizations
                              .passwordmustbeatleast6characterslong;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),

                    // Confirm Password Field
                    TextFormField(
                      controller: confirmPasswordController,
                      obscureText: true,
                      decoration:
                          _inputDecoration(applocalizations.confirmPassword),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return applocalizations.confirmPasswordisrequired;
                        }
                        if (value != passwordController.text) {
                          return applocalizations.passwordsdonotmatch;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),

                    // Address Field
                    TextFormField(
                      controller: addressController,
                      decoration: _inputDecoration(applocalizations.address),
                      maxLines: 3,
                      validator: (value) => value == null || value.isEmpty
                          ? applocalizations.addressisrequired
                          : null,
                    ),
                    const SizedBox(height: 30),

                    // Submit Button
                    Center(
                      child: ElevatedButton(
                        onPressed: isSubmitting
                            ? null
                            : () {
                                if (_formKey.currentState?.validate() ??
                                    false) {
                                  setState(() {
                                    isSubmitting = true;
                                  });
                                  storeDataToFirebase();
                                  Future.delayed(const Duration(seconds: 2),
                                      () {
                                    setState(() {
                                      isSubmitting = false;
                                    });

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            'Form submitted successfully!'),
                                      ),
                                    );
                                  });
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.black,
                          backgroundColor: isSubmitting
                              ? Colors.grey
                              : Colors.orange.shade200,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(
                              vertical: 15, horizontal: 45),
                          elevation: 10,
                          shadowColor: Colors.black.withOpacity(0.2),
                        ),
                        child: isSubmitting
                            ? const CircularProgressIndicator(
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              )
                            : Text(
                                applocalizations.submit,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
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
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String labelText) {
    return InputDecoration(
      labelText: labelText,
      labelStyle: const TextStyle(color: Colors.white),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.white),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.white),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.orange),
      ),
    );
  }

  Future<void> storeDataToFirebase() async {
    try {
      await firestore.collection('CustomerDetails').add({
        "name": nameController.text.trim(),
        "mobileNumber": mobileController.text.trim(),
        "userName": usernameController.text.trim(),
        "passWord": passwordController.text.trim(),
        "confirmPassword": confirmPasswordController.text.trim(),
        "address": addressController.text.trim(),
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data added successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add data: $e')),
      );
    }
  }
}
