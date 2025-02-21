import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

class DiscountOfferScreen extends StatefulWidget {
  @override
  _DiscountOfferScreenState createState() => _DiscountOfferScreenState();
}

class _DiscountOfferScreenState extends State<DiscountOfferScreen> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();

  bool isLoading = true;
  bool isSubmitting = false;

  final TextEditingController discountController = TextEditingController();
  final TextEditingController eggsOfferController = TextEditingController();
  final TextEditingController tcOfferController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchOfferDetails();
  }

  Future<void> _fetchOfferDetails() async {
    try {
      DocumentSnapshot discountDoc =
          await firestore.collection('OfferDetails').doc('discount').get();
      if (discountDoc.exists) {
        discountController.text = discountDoc['discountt'] ?? '';
      }

      DocumentSnapshot eggsOfferDoc =
          await firestore.collection('OfferDetails').doc('eggsOffer').get();
      if (eggsOfferDoc.exists) {
        eggsOfferController.text = eggsOfferDoc['offer'] ?? '';
      }

      DocumentSnapshot tcOfferDoc = await firestore
          .collection('OfferDetails')
          .doc('tcQ5jNhydeqxtiVMTWWK')
          .get();
      if (tcOfferDoc.exists) {
        tcOfferController.text = tcOfferDoc['offer'] ?? '';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching data: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _handleSubmit() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        isSubmitting = true;
      });

      try {
        await firestore.collection('OfferDetails').doc('discount').update({
          'discountt': discountController.text,
        });

        await firestore.collection('OfferDetails').doc('eggsOffer').update({
          'offer': eggsOfferController.text,
        });

        await firestore
            .collection('OfferDetails')
            .doc('tcQ5jNhydeqxtiVMTWWK')
            .update({
          'offer': tcOfferController.text,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Data updated successfully!',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white, // Text color
              ),
            ),
            backgroundColor: Colors.green, // Success message color
            behavior: SnackBarBehavior.floating, // Makes it float above UI
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10), // Rounded corners
            ),
            duration: const Duration(seconds: 3), // Visibility duration
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update: $e')),
        );
      } finally {
        setState(() {
          isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFDFF6DD), // Light green background
      appBar: AppBar(
          title: const Text(
            "Edit Discount Offers",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          centerTitle: true,
          backgroundColor: Colors.green // Deep green
          ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    SizedBox(
                      height: 20,
                    ),
                    _buildTextField(
                        discountController, "Discount (Percentage)"),
                    const SizedBox(height: 50),
                    _buildTextField(eggsOfferController, "Eggs Offer"),
                    const SizedBox(height: 50),
                    _buildTextField(tcOfferController, "TC Offer"),
                    const SizedBox(height: 100),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            isSubmitting ? Colors.grey.shade300 : Colors.yellow,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(5), // Square shape
                        ),
                        shadowColor: Colors.black.withOpacity(0.3),
                        elevation: 5, // Adds a soft shadow effect
                      ),
                      onPressed: isSubmitting
                          ? null
                          : () {
                              HapticFeedback
                                  .vibrate(); // Triggers vibration on press
                              _handleSubmit();
                            },
                      child: isSubmitting
                          ? const CircularProgressIndicator(color: Colors.black)
                          : const Text(
                              "Save Changes",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black, // Improves contrast
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontWeight: FontWeight.bold),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.green, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      validator: (value) =>
          (value == null || value.isEmpty) ? "Enter $label" : null,
    );
  }

  @override
  void dispose() {
    discountController.dispose();
    eggsOfferController.dispose();
    tcOfferController.dispose();
    super.dispose();
  }
}
