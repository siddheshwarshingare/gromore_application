import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
  //instance...
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  @override
  Widget build(BuildContext context) {
    final applocalizations = AppLocalizations.of(context);
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.yellow.shade50,
        appBar: AppBar(
          toolbarHeight: 80,
          backgroundColor: Colors.amber,
          title: Text(
            applocalizations!.registrationForm,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 27),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 10,
                ),

                TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: applocalizations.name,
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value == null || value.isEmpty
                      ? applocalizations.nameisrequired
                      : null,
                ),

                const SizedBox(height: 20),
                // Mobile Number Field
                TextFormField(
                  controller: mobileController,
                  decoration: InputDecoration(
                    labelText: applocalizations.mobileNumber,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(width: 10),
                    ),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return applocalizations.mobileNumberisrequired;
                    }
                    if (value.length != 10) {
                      return applocalizations.enteravalid10digitmobilenumber;
                    }
                    return null;
                  },
                ),

                // Address Field

                const SizedBox(height: 20),

                // Username Field
                TextFormField(
                  controller: usernameController,
                  decoration: InputDecoration(
                    labelText: applocalizations.username,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(width: 10),
                    ),
                  ),
                  validator: (value) => value == null || value.isEmpty
                      ? applocalizations.usernameisrequired
                      : null,
                ),
                const SizedBox(height: 20),

                // Password Field
                TextFormField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: applocalizations.password,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(width: 10),
                    ),
                  ),
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
                const SizedBox(height: 20),

                // Confirm Password Field
                TextFormField(
                  controller: confirmPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintStyle: TextStyle(fontSize: 40),
                    labelText: applocalizations.confirmPassword,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(width: 10),
                    ),
                  ),
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
                const SizedBox(height: 20),
                TextFormField(
                  controller: addressController,
                  decoration: InputDecoration(
                    labelText: applocalizations.address,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(width: 10),
                    ),
                  ),
                  maxLines: 3,
                  validator: (value) => value == null || value.isEmpty
                      ? applocalizations.addressisrequired
                      : null,
                ),
                SizedBox(
                  height: 40,
                ),

                // Submit Button
                Center(
                  child: ElevatedButton(
                    onPressed: isSubmitting
                        ? null
                        : () {
                            if (_formKey.currentState?.validate() ?? false) {
                              setState(() {
                                isSubmitting = true;
                              });
                              storeDataToFirebase();
                              //  Simulate form submission
                              Future.delayed(const Duration(seconds: 2), () {
                                setState(() {
                                  isSubmitting = false;
                                });

                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content:
                                        Text('Form submitted successfully!'),
                                  ),
                                );
                              });
                            }
                          },
                    child: isSubmitting
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            applocalizations.submit,
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 20),
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

//
  Future<void> storeDataToFirebase() async {
    String name = nameController.text.trim();
    String mobileNumber = mobileController.text.trim();
    String userName = usernameController.text.trim();
    String passWord = passwordController.text.trim();
    String confirmPassword = confirmPasswordController.text.trim();
    String address = addressController.text.trim();

    try {
      print("Name   ====== >$name");
      print("Name   ====== >$mobileNumber");
      print("Name   ====== >$userName");
      print("Name   ====== >$confirmPassword");
      print("Name   ====== >$address");
      await firestore.collection('CustomerDetails').add({
        "name": name,
        "mobileNumber": mobileNumber,
        "userName": userName,
        "passWord": passWord,
        "confirmPassword": confirmPassword,
        "address": address,
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
