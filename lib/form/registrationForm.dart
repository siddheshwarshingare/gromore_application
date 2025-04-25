import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/services.dart';
import 'package:gromore_application/login/commenclasses/apiconstant.dart';

import 'package:http/http.dart' as http;
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
  final TextEditingController confirmPasswordController = TextEditingController();

  bool isSubmitting = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;
  //String _selectedUserType = 'Customer'; // Default user type
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<void> _registerUser(BuildContext context) async {
    setState(() {
      _isLoading = true;
    });

    final String apiUrl = Apiconstants.adduser;

    try {
      // Get the current platform
      // final TargetPlatform platform = defaultTargetPlatform;

      // Fetch the user agent dynamically
      // final String userAgent = await DeviceInfoUtil.getUserAgent(platform);

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json'
        },
        body: json.encode({
          "name": nameController.text,
          "username": usernameController.text,
          "phone": mobileController.text,
          "password": passwordController.text,
          "password_confirmation": confirmPasswordController.text,
          "user_type": 3, // Include selected user type
           "address": addressController.text,
        }),
      );
      print(
        json.encode({
          "name": nameController.text,
          "username": usernameController.text,
          "phone": mobileController.text,
          "password": passwordController.text,
          "password_confirmation": confirmPasswordController.text,
          "user_type": 3, // Include selected user type
        }),
      );
      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registration successful!'),
            backgroundColor: Colors.green,
          ),
        );
        // Navigate back after successful registration
        Navigator.pop(context, 'User added successfully');
      } else {
        final errorData = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Registration failed: ${errorData['message']}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('An error occurred. Please try again later.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final applocalizations = AppLocalizations.of(context);

    return Scaffold(
       backgroundColor: Colors.white,
      appBar: AppBar(
        title: Center(
          child: Text(
            applocalizations!.registrationForm,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                // Name Field
                _buildTextField(
                  controller: nameController,
                  labelText: applocalizations.name,
                  icon: Icons.person,
                  inputFormatter: FilteringTextInputFormatter.allow(RegExp(r'^[\u0900-\u097F\u0020a-zA-Z]*$')),
                  validator: (value) {
                    if (value == null || value.isEmpty) return applocalizations.nameisrequired;
                    return null;
                  },
                ),

                // Mobile Field
                _buildTextField(
                  controller: mobileController,
                  labelText: applocalizations.mobileNumber,
                  icon: Icons.phone,
                  
                  keyboardType: TextInputType.phone,
                  inputFormatter: FilteringTextInputFormatter.digitsOnly,
                  validator: (value) {
                    if (value == null || value.isEmpty) return applocalizations.mobileNumberisrequired;
                    if (value.length != 10) return applocalizations.enteravalid10digitmobilenumber;
                    return null;
                  },
                ),

                // Username Field
                _buildTextField(
                  controller: usernameController,
                  labelText: applocalizations.username,
                  icon: Icons.account_circle,
                  inputFormatter: FilteringTextInputFormatter.allow(RegExp(r'^[\u0900-\u097F a-zA-Z0-9\\/@#&()-_]*$')),
                   validator: (value) {
                    if (value == null || value.isEmpty) return applocalizations.usernameisrequired;
                    return null;
                  },
                ),

                // Password Field with Toggle Visibility
                _buildPasswordField(
  controller: passwordController,
  labelText: applocalizations.password,
  isPasswordVisible: _isPasswordVisible,
  validator: (value) {
    if (value == null || value.isEmpty) {
      return applocalizations.passwordisrequired;
    } else if (value.length < 8) {
      return applocalizations.passwordmustbeatleast6characterslong;
    }
    return null;
  },
  toggleVisibility: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
),


                // Confirm Password Field with Toggle Visibility
                _buildPasswordField(
                  controller: confirmPasswordController,
                  labelText: applocalizations.confirmPassword,
                  isPasswordVisible: _isConfirmPasswordVisible,
                  toggleVisibility: () => setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible),
                  validator: (value) {
                    if (value == null || value.isEmpty) return applocalizations.confirmPasswordisrequired;
                    if (value != passwordController.text) return applocalizations.passwordsdonotmatch;
                    return null;
                  },
                ),

                // Address Field
                _buildTextField(
                  controller: addressController,
                  labelText: applocalizations.address,
                  icon: Icons.home,
                  maxLines: 3,
                  inputFormatter: FilteringTextInputFormatter.allow(RegExp(r'^[\u0900-\u097F\u0020a-zA-Z0-9,.-]*$')),
                   validator: (value) {
                    if (value == null || value.isEmpty) return applocalizations.addressisrequired;
                    return null;
                  },
                ),

                const SizedBox(height: 30),

                // Submit Button
                Center(
                  child: ElevatedButton(
                    onPressed: isSubmitting
                        ? null
                        : () {
                            if (_formKey.currentState?.validate() ?? false) {
                              setState(() => isSubmitting = true);
                              //Creating the  new user 
                              _registerUser(context);
                             // storeDataToFirebase();
                              // Future.delayed(const Duration(seconds: 2), () {
                              //   setState(() => isSubmitting = false);
                              //   ScaffoldMessenger.of(context).showSnackBar(
                              //     const SnackBar(
                              //       content: Text('Form submitted successfully!'),
                              //       backgroundColor: Colors.green,
                              //     ),
                              //   );
                              //   Navigator.pop(context);
                              // });
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: isSubmitting ? Colors.grey : Colors.orange.shade700,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 45),
                    ),
                    child: isSubmitting
                        ? const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white))
                        : Text(
                            applocalizations.submit,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    TextInputFormatter? inputFormatter,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        inputFormatters: inputFormatter != null ? [inputFormatter] : [],
        decoration: _inputDecoration(labelText).copyWith(
          prefixIcon: Icon(icon, color: Colors.black),
        ),
        validator: validator ?? (value) => value == null || value.isEmpty ? 'This field is required' : null,
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String labelText,
    required bool isPasswordVisible,
    required VoidCallback toggleVisibility,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: controller,
        obscureText: !isPasswordVisible,
        decoration: _inputDecoration(labelText).copyWith(
          prefixIcon: const Icon(Icons.lock, color: Colors.black),
          suffixIcon: IconButton(
            icon: Icon(isPasswordVisible ? Icons.visibility : Icons.visibility_off, color: Colors.black),
            onPressed: toggleVisibility,
          ),
        ),
        validator: validator,
      ),
    );
  }

  InputDecoration _inputDecoration(String labelText) {
    return InputDecoration(
      labelText: labelText,
      labelStyle: const TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.white)),
      filled: true,
      //fillColor: Colors.blue.shade900.withOpacity(0.3),
    );
  }

  Future<void> storeDataToFirebase() async {
    await firestore.collection('CustomerDetails').add({
      "name": nameController.text.trim(),
      "mobileNumber": mobileController.text.trim(),
      "userName": usernameController.text.trim(),
      "passWord": passwordController.text.trim(),
      "address": addressController.text.trim(),
    });
  }
}
