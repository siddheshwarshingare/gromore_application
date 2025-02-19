import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class VegetableQuantityScreen extends StatefulWidget {
  @override
  _VegetableQuantityScreenState createState() => _VegetableQuantityScreenState();
}

class _VegetableQuantityScreenState extends State<VegetableQuantityScreen> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();

  bool isLoading = true;
  bool isEditing = false;
  bool isSubmitting = false;

  Map<String, String> vegetableQuantities = {};
  final Map<String, TextEditingController> controllers = {};

  @override
  void initState() {
    super.initState();
    _fetchExistingQuantities();
  }

  Future<void> _fetchExistingQuantities() async {
    try {
      final doc = await firestore.collection('VegetablesPrice').doc('QuantityOfVegetable').get();
      if (doc.exists && doc.data() != null) {
        setState(() {
          vegetableQuantities = Map<String, String>.from(doc.data() ?? {});
          controllers.clear();
          vegetableQuantities.forEach((key, value) {
            controllers[key] = TextEditingController(text: value);
          });
        });
      } else {
        setState(() => vegetableQuantities = {});
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

      Map<String, String> updatedQuantities = {};
      controllers.forEach((key, controller) {
        updatedQuantities[key] = controller.text;
      });

      try {
        await firestore.collection('VegetablesPrice').doc('QuantityOfVegetable').set(updatedQuantities);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Quantities updated successfully!')));
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
    TextEditingController quantityController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.greenAccent,
        title: const Text("Add New Vegetable Quantity", style: TextStyle(color: Colors.pink)),
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
              controller: quantityController,
              decoration: const InputDecoration(labelText: "Quantity (e.g., 1kg, 500g)"),
              validator: (value) => (value == null || value.isEmpty) ? "Enter quantity" : null,
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
              _addNewVegetable(nameController.text.trim(), quantityController.text.trim());
              Navigator.pop(context);
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  Future<void> _addNewVegetable(String name, String quantity) async {
    if (name.isEmpty || quantity.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please enter valid details")));
      return;
    }

    setState(() {
      vegetableQuantities[name] = quantity;
      controllers[name] = TextEditingController(text: quantity);
    });

    try {
      await firestore.collection('VegetablesPrice').doc('QuantityOfVegetable').set(vegetableQuantities);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Vegetable quantity added successfully!")));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to add vegetable: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Vegetable Quantities")),
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
                        children: vegetableQuantities.keys.map((key) {
                          return _buildVegetableQuantityRow(key);
                        }).toList(),
                      ),
                    ),
                    if (isEditing) _buildSubmitButton(),
                  ],
                ),
              ),
            ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(right: 70),
        child: FloatingActionButton.extended(
          onPressed: _showAddVegetableDialog,
          icon: const Icon(Icons.add),
          label: const Text("Add Quantity"),
        ),
      ),
    );
  }

  Widget _buildVegetableQuantityRow(String key) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text(_formatVegetableName(key)),
        subtitle: isEditing
            ? TextFormField(
                controller: controllers[key],
                decoration: const InputDecoration(hintText: "Enter Quantity"),
                validator: (value) => (value == null || value.isEmpty) ? "Enter a valid quantity" : null,
              )
            : Text("${vegetableQuantities[key]}"),
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
      child: isSubmitting ? const CircularProgressIndicator() : const Text("Save Quantities"),
    );
  }

  String _formatVegetableName(String key) {
    String formattedKey = key.replaceAll("VegetablesQuantity", "");
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
