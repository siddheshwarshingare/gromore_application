import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gromore_application/login/commenclasses/apiconstant.dart';
import 'package:gromore_application/login/models/addNewVegetables.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class AddNewVegetables extends StatefulWidget {
  final String adminToken;

  const AddNewVegetables({super.key, required this.adminToken});

  @override
  State<AddNewVegetables> createState() => _AddNewVegetablesState();
}

class _AddNewVegetablesState extends State<AddNewVegetables> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController nameController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController quantityController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController offerDetailsController = TextEditingController();

  File? _imageFile;

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (_imageFile == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please select an image")),
        );
        return;
      }

      String apiUrl = Apiconstants.addNewVegetable;
      final url = Uri.parse(apiUrl);

      var headers = {
        'Authorization': 'Bearer ${widget.adminToken}',
        'Accept': 'application/json',
      };

      var request = http.MultipartRequest('POST', url)
        ..fields.addAll({
          'name': nameController.text,
          'price': priceController.text,
          'quantity': quantityController.text,
          'description': descriptionController.text,
          'offer_details': offerDetailsController.text,
        })
        ..files.add(await http.MultipartFile.fromPath('image', _imageFile!.path))
        ..headers.addAll(headers);

      try {
        http.StreamedResponse response = await request.send();

        if (response.statusCode == 200) {
          final responseString = await response.stream.bytesToString();
          final jsonData = json.decode(responseString);
          final result = AddVegetableModel.fromJson(jsonData);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Added Successfully: ${result.message}")),
          );

          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Failed: ${response.reasonPhrase}")),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Exception: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Add New Vegetable"),
        backgroundColor: Colors.green[700],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                buildTextField(nameController, "Vegetable Name"),
                buildTextField(priceController, "Price"),
                buildTextField(quantityController, "Quantity"),
                buildTextField(descriptionController, "Description"),
                buildTextField(offerDetailsController, "Offer Details"),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    height: 180,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.green, width: 1.5),
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.green[50],
                    ),
                    child: _imageFile != null
                        ? Image.file(_imageFile!, fit: BoxFit.cover)
                        : const Center(
                            child: Text(
                              "Tap to select image",
                              style: TextStyle(color: Colors.green, fontWeight: FontWeight.w600),
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[700],
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text(
                      "Add Vegetable",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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

  Widget buildTextField(TextEditingController controller, String label) {
  bool isTextOnlyField = label == "Vegetable Name" || label == "Description" || label == "Offer Details";
  bool isNumberOnlyField = label == "Price" || label == "Quantity";

  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: TextFormField(
      controller: controller,
      keyboardType: isNumberOnlyField ? TextInputType.number : TextInputType.text,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter $label';
        }

        if (isTextOnlyField && !RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
          return '$label should contain only alphabets';
        }

        if (isNumberOnlyField && !RegExp(r'^\d+$').hasMatch(value)) {
          return '$label should contain only numbers';
        }

        return null;
      },
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.green),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.green),
        ),
      ),
    ),
  );
}
}
