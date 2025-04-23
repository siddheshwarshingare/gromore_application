import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gromore_application/login/commenclasses/apiconstant.dart';
import 'package:gromore_application/login/logoutDialog.dart';
import 'package:gromore_application/login/models/usermodel.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';// if you have it in a separate file

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserModel? userData;
  String? userName, passWord, mobileNumber, documentId;
  bool _isLoading = false;
  String tokenForAPI = '';
  TextEditingController _addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchUserDetails();
  }

  Future<void> fetchUserDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    tokenForAPI = prefs.getString('token') ?? '';
    print("Token => $tokenForAPI");

    String apiUrl = Apiconstants.fetchUserDetails;

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $tokenForAPI',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );

      print('Response Statuscode: ${response.statusCode}');
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = json.decode(response.body);

        setState(() {
          userData = UserModel.fromJson(responseBody);
          _addressController.text = userData?.address ?? '';
          _isLoading = false;
        });

        print("User Data: $userData");
      } else {
        setState(() {
          _isLoading = false;
        });
        print("Error: ${response.statusCode}");
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          backgroundColor: Colors.red,
          duration: const Duration(milliseconds: 700),
          content: Center(
            child: Text(
              "$e\nAn error occurred. Please try again later.",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      );
    }
  }

  Future<void> _updateAddress(String newAddress) async {
    if (documentId == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('CustomerDetails')
          .doc(documentId)
          .update({'address': newAddress});

      setState(() {
        userData?.address = newAddress;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Address updated successfully!")),
      );
    } catch (e) {
      print("Error updating address: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to update address")),
      );
    }
  }

  void _showEditAddressDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Edit Address"),
          content: TextField(
            controller: _addressController,
            decoration: const InputDecoration(
              hintText: "Enter new address",
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                _updateAddress(_addressController.text);
                Navigator.pop(context);
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildGradientAppBar(),
      body: userData == null
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20.0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      height: 500,
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 156, 237, 248),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Card(
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        color: Colors.transparent,
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const SizedBox(height: 20),
                              _buildProfileRow(Icons.person, "नाव", userData?.name ?? ''),
                              _buildProfileRow(Icons.account_circle, "वापरकर्त्याचे नाव", userData?.username ?? ''),
                              _buildProfileRow(Icons.phone, "मोबाईल", userData?.phone ?? ''),
                              _buildEditableProfileRow(Icons.home, "पत्ता", userData?.address ?? ''),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 150),                
                    SizedBox(
                      height: 50,
                      width: 200,
                      child: ElevatedButton(
                        onPressed: () async {
                          LogoutDialog.show(context);
                          SharedPreferences prefs = await SharedPreferences.getInstance();
                          // prefs.clear(); // Optional
                        },
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(Colors.green.shade500),
                          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                            const RoundedRectangleBorder(
                              borderRadius: BorderRadius.zero,
                              side: BorderSide(color: Colors.green),
                            ),
                          ),
                        ),
                        child: const Text(
                          "लॉगआउट",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.black),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  AppBar _buildGradientAppBar() {
    return AppBar(
      title: const Text(
        "प्रोफाइल स्क्रीन",
        style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
      ),
      centerTitle: true,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          color: Colors.green,
        ),
      ),
    );
  }

  Widget _buildProfileRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.black, size: 26),
          const SizedBox(width: 16),
          Text(
            "$title: ",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black87),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditableProfileRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.black, size: 26),
          const SizedBox(width: 16),
          Text(
            "$title: ",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black87),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.black),
            onPressed: _showEditAddressDialog,
          ),
        ],
      ),
    );
  }
}
