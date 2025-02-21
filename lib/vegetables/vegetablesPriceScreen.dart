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
      final doc = await firestore
          .collection('VegetablesPrice')
          .doc('vegetablePrices')
          .get();
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
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error fetching data: $e')));
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
        await firestore
            .collection('VegetablesPrice')
            .doc('vegetablePrices')
            .set(updatedPrices);
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Prices updated successfully!')));
        setState(() => isEditing = false);
      } catch (e) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Failed to update: $e')));
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
        backgroundColor: Colors.yellow.shade100,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          "Add New Vegetable",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.pink,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8, // Increases width
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: "Vegetable Name",
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (value) => (value == null || value.isEmpty)
                    ? "Enter vegetable name"
                    : null,
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Price",
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (value) =>
                    (value == null || value.isEmpty) ? "Enter price" : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
              textStyle:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              _addNewVegetable(
                  nameController.text.trim(), priceController.text.trim());
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              textStyle:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  Future<void> _addNewVegetable(String name, String price) async {
    if (name.isEmpty || price.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please enter valid details")));
      return;
    }

    setState(() {
      vegetablePrices[name] = price;
      controllers[name] = TextEditingController(text: price);
    });

    try {
      await firestore
          .collection('VegetablesPrice')
          .doc('vegetablePrices')
          .set(vegetablePrices);
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Vegetable added successfully!")));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Failed to add vegetable: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.yellowAccent.shade100,
      appBar: AppBar(
          backgroundColor: Colors.green,
          title: const Text(
            "Vegetable Prices",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 25,
            ),
          )),
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
        child: Container(
          height: 70,
          width: 160,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.green.shade700,
                Colors.greenAccent.shade400
              ], 
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(30), 
            boxShadow: [
              const BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: const Offset(3, 5),
              ),
            ],
          ),
          child: FloatingActionButton.extended(
            onPressed: _showAddVegetableDialog,
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text(
              "Add Vegetables",
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
        ),
      ),
    );
  }

  Widget _buildVegetablePriceRow(String key) {
    return Card(
      color: Colors.brown.shade100,
      elevation: 7,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text(
          _formatVegetableName(key),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: isEditing
            ? TextFormField(
                controller: controllers[key],
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(hintText: "Enter Price"),
                validator: (value) => (value == null || value.isEmpty)
                    ? "Enter a valid price"
                    : null,
              )
            : Text(
                "₹${vegetablePrices[key]}",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
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
      child: isSubmitting
          ? const CircularProgressIndicator()
          : const Text("Save Prices"),
    );
  }

  String _formatVegetableName(String key) {
    String formattedKey = key.replaceAll("VegetablesPrice", "");
    formattedKey = formattedKey.replaceAllMapped(
        RegExp(r'([a-z])([A-Z])'), (match) => '${match[1]} ${match[2]}');
    formattedKey = formattedKey.replaceFirstMapped(
        RegExp(r'^[a-z]'), (match) => match.group(0)!.toUpperCase());
    return formattedKey;
  }

  @override
  void dispose() {
    controllers.values.forEach((controller) => controller.dispose());
    super.dispose();
  }
}
