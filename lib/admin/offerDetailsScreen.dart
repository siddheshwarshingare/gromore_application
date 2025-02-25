import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

class DiscountOfferScreen extends StatefulWidget {
  @override
  _DiscountOfferScreenState createState() => _DiscountOfferScreenState();
}

class _DiscountOfferScreenState extends State<DiscountOfferScreen>
 {
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
      }
      );

      try {
        await firestore.collection('OfferDetails').doc('discount').update({
          'discountt': discountController.text,
        }
        );

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
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            duration: const Duration(seconds: 3),
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
      backgroundColor: Colors.orange.shade100, 
      appBar: AppBar(
        title: const Text(
          "Edit Discount Offers",
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22,
              color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: Colors.green,
        elevation: 5,
        shadowColor: Colors.black.withOpacity(0.3),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    SizedBox(height: 30,),
                    _buildTextField(discountController, "Discount (Percentage)"),
                    const SizedBox(height: 40),
                    _buildTextField(eggsOfferController, "Eggs Offer"),
                    const SizedBox(height: 40),
                    _buildTextField(tcOfferController, "TC Offer", maxLines: 2),
                    const SizedBox(height: 60),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isSubmitting
                            ? Colors.grey.shade300
                            : const Color.fromARGB(255, 232, 121, 88),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        shadowColor: Colors.black.withOpacity(0.3),
                        elevation: 6,
                      ),
                      onPressed: isSubmitting
                          ? null
                          : () {
                              HapticFeedback.vibrate();
                              _handleSubmit();
                            },
                      child: isSubmitting
                          ? const CircularProgressIndicator(
                              color: Colors.white)
                          : const Text(
                              "Save Changes",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {int maxLines = 1}) {
    return SizedBox(

      width: 500,
      child: 
      TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          filled: true,
          fillColor: Colors.white.withOpacity(0.9),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.green, width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.blueAccent, width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        validator: (value) => (value == null || value.isEmpty) ? "Enter $label" : null,
      ),
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
