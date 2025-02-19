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

  Map<String, String> vegetablePrices = {};
  final Map<String, TextEditingController> controllers = {};

  @override
  void initState() {
    super.initState();
    _fetchExistingPrices();
  }

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
        setState(() => vegetablePrices = {});
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error fetching data: $e')));
    } finally {
      setState(() => isLoading = false);
    }
  }

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

  void _showAddVegetableDialog() {
    TextEditingController nameController = TextEditingController();
    TextEditingController priceController = TextEditingController();

    showDialog(
      
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.greenAccent,
        title: const Text("Add New Vegetable",style: TextStyle(color: Colors.pink),),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Vegetable Name"),
              validator: (value) => (value == null || value.isEmpty) ? "Enter vegetable name" : null,
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Price"),
              validator: (value) => (value == null || value.isEmpty) ? "Enter price" : null,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              _addNewVegetable(nameController.text.trim(), priceController.text.trim());
              Navigator.pop(context);
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  Future<void> _addNewVegetable(String name, String price) async {
    if (name.isEmpty || price.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please enter valid details")));
      return;
    }

    setState(() {
      vegetablePrices[name] = price;
      controllers[name] = TextEditingController(text: price);
    });

    try {
      await firestore.collection('VegetablesPrice').doc('vegetablePrices').set(vegetablePrices);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Vegetable added successfully!")));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to add vegetable: $e")));
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
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(right: 100),
        child: SizedBox(
          width: 140,
          child: FloatingActionButton(
            onPressed: _showAddVegetableDialog,
            child: Text("Add Vegetables")
            // const Icon(Icons.add),
          ),
        ),
      ),
    );
  }

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

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: isSubmitting ? null : _handleSubmit,
      child: isSubmitting ? const CircularProgressIndicator() : const Text("Save Prices"),
    );
  }

  String _formatVegetableName(String key) {
    String formattedKey = key.replaceAll("VegetablesPrice", "");
    formattedKey = formattedKey.replaceAllMapped(RegExp(r'([a-z])([A-Z])'), (match) => '${match[1]} ${match[2]}');
    formattedKey = formattedKey.replaceFirstMapped(RegExp(r'^[a-z]'), (match) => match.group(0)!.toUpperCase());
    return formattedKey;
  }

  @override
  void dispose() {
    controllers.values.forEach((controller) => controller.dispose());
    super.dispose();
  }
}
