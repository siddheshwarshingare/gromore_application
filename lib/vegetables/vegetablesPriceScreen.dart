import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class VegetablePriceScreen extends StatefulWidget {
  @override
  _VegetablePriceScreenState createState() => _VegetablePriceScreenState();
}

class _VegetablePriceScreenState extends State<VegetablePriceScreen> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();

  bool isLoading = true;
  bool isEditing = false;
  bool isSubmitting = false;

  // Store prices
  Map<String, String> vegetablePrices = {};

  // Store controllers for editing
  final Map<String, TextEditingController> controllers = {};

  @override
  void initState() {
    super.initState();
    _fetchExistingPrices();
  }

  // Fetch prices from Firestore
  Future<void> _fetchExistingPrices() async {
    try {
      final doc = await firestore.collection('VegetablesPrice').doc('vegetablePrices').get();
      
      if (doc.exists && doc.data() != null) {
        setState(() {
          vegetablePrices = Map<String, String>.from(doc.data() ?? {}); 
          controllers.clear();
          vegetablePrices.forEach((key, value) {
            controllers[key] = TextEditingController(text: value);
          });
        });
      } else {
        // Handle case when Firestore has no data
        setState(() {
          vegetablePrices = {}; // Ensure it's not null
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error fetching data: $e')));
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Save updated prices to Firestore
  Future<void> _handleSubmit() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => isSubmitting = true);

      Map<String, String> updatedPrices = {};
      controllers.forEach((key, controller) {
        updatedPrices[key] = controller.text;
      });

      try {
        await firestore.collection('VegetablesPrice').doc('vegetablePrices').set(updatedPrices);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Prices updated successfully!')));
        setState(() => isEditing = false);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update: $e')));
      } finally {
        setState(() => isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Vegetable Prices")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Expanded(
                      child: ListView(
                        children: vegetablePrices.keys.map((key) {
                          return _buildVegetablePriceRow(key);
                        }).toList(),
                      ),
                    ),
                    if (isEditing) _buildSubmitButton(),
                  ],
                ),
              ),
            ),
    );
  }

  // Widget for each row (show price + edit button)
  Widget _buildVegetablePriceRow(String key) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text(_formatVegetableName(key)),
        subtitle: isEditing
            ? TextFormField(
                controller: controllers[key],
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(hintText: "Enter Price"),
                validator: (value) => (value == null || value.isEmpty) ? "Enter a valid price" : null,
              )
            : Text("₹${vegetablePrices[key]}"),
        trailing: isEditing
            ? null
            : IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => setState(() => isEditing = true),
              ),
      ),
    );
  }

  // Submit button
  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: isSubmitting ? null : _handleSubmit,
      child: isSubmitting ? const CircularProgressIndicator() : const Text("Save Prices"),
    );
  }

  // Format key names for display
  String _formatVegetableName(String key) {
    // Remove 'VegetablesPrice' suffix
    String formattedKey = key.replaceAll("VegetablesPrice", "");

    // Insert space between lowercase and uppercase letters
    formattedKey = formattedKey.replaceAllMapped(RegExp(r'([a-z])([A-Z])'), (match) => '${match[1]} ${match[2]}');

    // Capitalize the first letter of the key
    formattedKey = formattedKey.replaceFirstMapped(RegExp(r'^[a-z]'), (match) => match.group(0)!.toUpperCase());

    return formattedKey;
  }

  @override
  void dispose() {
    controllers.values.forEach((controller) => controller.dispose());
    super.dispose();
  }
}
