import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/services.dart';

class Vegetablespricescreen extends StatefulWidget {
  const Vegetablespricescreen({Key? key}) : super(key: key);

  @override
  State<Vegetablespricescreen> createState() => _CustomFormScreenState();
}

class _CustomFormScreenState extends State<Vegetablespricescreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  // final TextEditingController nameController = TextEditingController();
  // final TextEditingController mobileController = TextEditingController();
  // final TextEditingController addressController = TextEditingController();
  // final TextEditingController usernameController = TextEditingController();
  // final TextEditingController passwordController = TextEditingController();
  // final TextEditingController confirmPasswordController =
  //     TextEditingController();

  final TextEditingController methiBhajiController = TextEditingController();
  final TextEditingController palakBhajiController = TextEditingController();
  final TextEditingController bhendiBhajiController = TextEditingController();
  final TextEditingController kandaPathBhajiController =  TextEditingController();
  final TextEditingController chavaliBhajiController = TextEditingController();
  final TextEditingController shepuBhajiController = TextEditingController();
  final TextEditingController dodkaBhajiController = TextEditingController();
  final TextEditingController kaddiBhajiController = TextEditingController();
  final TextEditingController karleBhajiController = TextEditingController();
  final TextEditingController gavarBhajiController = TextEditingController();
  final TextEditingController kandeBhajiController = TextEditingController();
  final TextEditingController kothimbirBhajiController = TextEditingController();
  final TextEditingController chukaBhajiController = TextEditingController();
   final TextEditingController kandeController = TextEditingController();


  // final TextEditingController BhajiController = TextEditingController();

  // final TextEditingController methiBhajiController = TextEditingController();

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
                        applocalizations!.vegetablesPriceScreen,
                        style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Name Field
                    CommonTextFormField(applocalizations, methiBhajiController,
                        applocalizations.enterMethiVegetablesPrice),
                    const SizedBox(height: 15),

                    CommonTextFormField(applocalizations, palakBhajiController,
                        applocalizations.enterPalakVegetablesPrice),
                    const SizedBox(height: 15),

                    CommonTextFormField(applocalizations, bhendiBhajiController,
                        applocalizations.enterBhendiVegetablesPrice),
                    const SizedBox(height: 15),

                    CommonTextFormField(applocalizations, chukaBhajiController,
                        applocalizations.enterChukaVegetablesPrice),
                    const SizedBox(height: 15),

                    CommonTextFormField(applocalizations,chavaliBhajiController ,
                        applocalizations.enterChavalikVegetablesPrice),
                    const SizedBox(height: 15),

                    CommonTextFormField(applocalizations, dodkaBhajiController,
                        applocalizations.enterDodkaVegetablesPrice),
                    const SizedBox(height: 15),

                    CommonTextFormField(applocalizations,kaddiBhajiController,
                        applocalizations.enterkakdiVegetablesPrice),
                    const SizedBox(height: 15),

                    CommonTextFormField(applocalizations, gavarBhajiController,
                        applocalizations.enterGavarVegetablesPrice),
                    const SizedBox(height: 15),

                    CommonTextFormField(applocalizations, kandeBhajiController,
                        applocalizations.enterKandaPathVegetablesPrice),
                    const SizedBox(height: 15),

                    CommonTextFormField(applocalizations, karleBhajiController,
                        applocalizations.enterKarleVegetablesPrice),
                        const SizedBox(height: 15),
                          CommonTextFormField(applocalizations, kothimbirBhajiController,
                        applocalizations.enterKothimbirVegetablesPrice),
                        const SizedBox(height: 15),
                          CommonTextFormField(applocalizations, shepuBhajiController,
                        applocalizations.enterShepuVegetablesPrice),
                        const SizedBox(height: 15),
                        CommonTextFormField(applocalizations, chukaBhajiController,
                        applocalizations.enterChukaVegetablesPrice),
                        CommonTextFormField(applocalizations, kandeController,
                        applocalizations. enterKandeVegetablesPrice),
                     


//                    TextFormField(
//   controller: methiBhajiController,
//   decoration: _inputDecoration(applocalizations.enterMethiVegetablesPrice),
//   keyboardType: TextInputType.number, // Allows number input
//   inputFormatters: [
//     FilteringTextInputFormatter.digitsOnly, // Allows only digits
//   ],
//   validator: (value) {
//     if (value == null || value.isEmpty) {
//       return applocalizations.enterMethiVegetablesPrice;
//     }
//     return null;
//   },
// ),

                    const SizedBox(height: 15),

                    // Mobile Field
                    TextFormField(
                      controller: palakBhajiController,
                      decoration: _inputDecoration(
                          applocalizations.enterPalakVegetablesPrice),
                      keyboardType: TextInputType.phone,
                      inputFormatters: [
                        FilteringTextInputFormatter
                            .digitsOnly, // Allow only digits
                        LengthLimitingTextInputFormatter(
                            10), // Limit to 10 digits
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return applocalizations.enterPalakVegetablesPrice;
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 15),

                    // Username Field
                    // TextFormField(
                    //   controller: bhendiBhajiController,
                    //   decoration: _inputDecoration(applocalizations.enterBhendiVegetablesPrice),
                    //   validator: (value) => value == null || value.isEmpty
                    //       ? applocalizations.usernameisrequired
                    //       : null,
                    // ),
                    // const SizedBox(height: 15),

                    // // Password Field
                    // TextFormField(
                    //   controller: kandaPathBhajiController,
                    //   obscureText: true,
                    //   decoration: _inputDecoration(applocalizations.enterKandaPathVegetablesPrice),
                    //   validator: (value) {
                    //     if (value == null || value.isEmpty) {
                    //       return applocalizations.enterKandaPathVegetablesPrice;
                    //     }
                    //     if (value.length < 6) {
                    //       return applocalizations
                    //           .passwordmustbeatleast6characterslong;
                    //     }
                    //     return null;
                    //   },
                    // ),
                    // const SizedBox(height: 15),

                    // // Confirm Password Field
                    // TextFormField(
                    //   controller: chavaliBhajiController,
                    //   obscureText: true,
                    //   decoration:
                    //       _inputDecoration(applocalizations.confirmPassword),
                    //   validator: (value) {
                    //     if (value == null || value.isEmpty) {
                    //       return applocalizations.confirmPasswordisrequired;
                    //     }

                    //     return null;
                    //   },
                    // ),
                    // const SizedBox(height: 15),

                    // // Address Field
                    // TextFormField(
                    //   controller: dodkaBhajiController,
                    //   decoration: _inputDecoration(applocalizations.address),
                    //   // maxLines: 3,
                    //   validator: (value) => value == null || value.isEmpty
                    //       ? applocalizations.addressisrequired
                    //       : null,
                    // ),
                    // const SizedBox(height: 30),

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
                                    Navigator.pop(context);
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

  Widget CommonTextFormField(AppLocalizations applocalizations,
      TextEditingController controller, String hintText) {
    return TextFormField(
      controller: controller,
      decoration: _inputDecoration(hintText),
      keyboardType: TextInputType.number, // Allows number input
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly, // Allows only digits
      ],
      validator: (value) {
        if (value == null || value.isEmpty) {
          return applocalizations.enterMethiVegetablesPrice;
        }
        return null;
      },
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
      await firestore.collection('VegetablesPrice').doc('vegetablePrices').set({
        "methiVegetablesPrice": methiBhajiController.text.trim(),
        "palakVegetablesPrice": palakBhajiController.text.trim(),
        "bhendiVegetablesPrice": bhendiBhajiController.text.trim(),
        "chukaVegetablesPrice": chukaBhajiController.text.trim(),
        "chavaliVegetablesPrice": chavaliBhajiController.text.trim(),
        "dodkaVegetablesPrice": dodkaBhajiController.text.trim(),
        "kakdivegetablesPrice": kaddiBhajiController.text.trim(),
        "gavarVegetablesPrice": gavarBhajiController.text.trim(),
        "kandaPathVegetablesPrice": kandaPathBhajiController.text.trim(),
        "karleVegetablesPrice": karleBhajiController.text.trim(),
        "kothimbirVegetablesPrice": kothimbirBhajiController.text.trim(),
        "shepuVegetablesPrice": shepuBhajiController.text.trim(),
        "kandeVegetablesPrice": kandeController.text.trim(),
        // "methiVegetablesPrice": methiBhajiController.text.trim(),
        // "mobileNumber": mobileController.text.trim(),
        // "userName": usernameController.text.trim(),
        // "passWord": passwordController.text.trim(),
        // "confirmPassword": confirmPasswordController.text.trim(),
        // "address": addressController.text.trim(),
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
