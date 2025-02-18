import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DiscountOfferScreen extends StatefulWidget {
  @override
  _DiscountOfferScreenState createState() => _DiscountOfferScreenState();
}

class _DiscountOfferScreenState extends State<DiscountOfferScreen> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();

  bool isLoading = true;
  bool isSubmitting = false;

  String discount = '';
  String eggsOffer = '';
  String tcOffer = '';

  final TextEditingController discountController = TextEditingController();
  final TextEditingController eggsOfferController = TextEditingController();
  final TextEditingController tcOfferController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchOfferDetails();
  }

  // Fetch the discount and offer details from Firestore
  Future<void> _fetchOfferDetails() async {
    try {
      // Fetch 'discount' document
      DocumentSnapshot discountDoc = await firestore.collection('OfferDetails').doc('discount').get();

      if (discountDoc.exists) {
        setState(() async {
          // Retrieve discount data and store in variable
          discount = discountDoc['discountt'] ?? '';
          discountController.text = discount;

          // Retrieve the offer data from the 'eggsOffer' sub-document
          DocumentSnapshot eggsOfferDoc = await firestore.collection('OfferDetails').doc('eggsOffer').get();
          if (eggsOfferDoc.exists) {
            eggsOffer = eggsOfferDoc['offer'] ?? '';
            eggsOfferController.text = eggsOffer;
          }

          // Similarly fetch tcOffer if available
          DocumentSnapshot tcOfferDoc = await firestore.collection('OfferDetails').doc('tcQ5jNhydeqxtiVMTWWK').get();
          if (tcOfferDoc.exists) {
            tcOffer = tcOfferDoc['offer'] ?? '';
            tcOfferController.text = tcOffer;
          }
        });
      }
    } catch (e) {
      // Handle any errors during fetching
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error fetching data: $e')));
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Save updated details back to Firestore
  Future<void> _handleSubmit() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        isSubmitting = true;
      });

      try {
        // Update 'discount' document
        await firestore.collection('OfferDetails').doc('discount').update({
          'discountt': discountController.text,
        });

        // Update 'eggsOffer' document
        await firestore.collection('OfferDetails').doc('eggsOffer').update({
          'offer': eggsOfferController.text,
        });

        // Update 'tcOffer' document
        await firestore.collection('OfferDetails').doc('tcQ5jNhydeqxtiVMTWWK').update({
          'offer': tcOfferController.text,
        });

        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Data updated successfully!')));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update: $e')));
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
      appBar: AppBar(title: Center(child: const Text("Edit Discount  Offers",style: TextStyle(fontWeight: FontWeight.bold),)),backgroundColor: Colors.green,),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: discountController,
                      decoration: const InputDecoration(labelText: 'Discount (Percentage)'),
                      validator: (value) => (value == null || value.isEmpty) ? 'Enter a discount percentage' : null,
                    ),
                    TextFormField(
                       maxLines : 2,
                      controller: eggsOfferController,
                      decoration: const InputDecoration(labelText: 'Eggs Offer'),
                      validator: (value) => (value == null || value.isEmpty) ? 'Enter the eggs offer' : null,
                    ),
                    TextFormField(
                      maxLines : 2,
                      controller: tcOfferController,
                      decoration: const InputDecoration(labelText: 'TC Offer'),
                      validator: (value) => (value == null || value.isEmpty) ? 'Enter the TC offer' : null,
                    ),
                    const SizedBox(height: 20),
                   ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor:  isSubmitting ? Colors.grey.shade500 : Colors.blue,
  //  primary: isSubmitting ? Colors.grey.shade500 : Colors.blue, // Animated color
    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(30),
    ),
  ),
  onPressed: isSubmitting ? null : _handleSubmit,
  child: isSubmitting
      ? const CircularProgressIndicator(color: Colors.white)
      : const Text(
          "Save Changes",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
),

                  ],
                ),
              ),
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
