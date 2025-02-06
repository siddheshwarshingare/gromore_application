import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gromore_application/login/loginScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? userData;
  String? userName, passWord, mobileNumber, documentId;
  TextEditingController _addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchUserDetails();
  }

  Future<void> fetchUserDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userName = prefs.getString('userName');
    passWord = prefs.getString('passWord');
    mobileNumber = prefs.getString("mobileNumber");

    if (passWord != null) {
      try {
        QuerySnapshot querySnapshot;

        if (userName != null && userName!.isNotEmpty) {
          querySnapshot = await FirebaseFirestore.instance
              .collection('CustomerDetails')
              .where('userName', isEqualTo: userName)
              .where('passWord', isEqualTo: passWord)
              .get();
        } else if (mobileNumber != null && mobileNumber!.isNotEmpty) {
          querySnapshot = await FirebaseFirestore.instance
              .collection('CustomerDetails')
              .where('mobileNumber', isEqualTo: mobileNumber)
              .where('passWord', isEqualTo: passWord)
              .get();
        } else {
          print("No valid login credentials found!");
          return;
        }

        if (querySnapshot.docs.isNotEmpty) {
          setState(() {
            userData = querySnapshot.docs.first.data() as Map<String, dynamic>;
            documentId = querySnapshot.docs.first.id;
            _addressController.text = userData!['address'] ?? "";
          });
        } else {
          print("User not found!");
        }
      } catch (e) {
        print("Error fetching user data: $e");
      }
    } else {
      print("Password is missing in SharedPreferences");
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
        userData!['address'] = newAddress;
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
                            _buildProfileRow(
                                Icons.person, "नाव", userData!['name']),
                            _buildProfileRow(Icons.account_circle, "वापरकर्त्याचे नाव",
                                userData!['userName']),
                            _buildProfileRow(Icons.phone, "मोबाईल",
                                userData!['mobileNumber']),
                            _buildEditableProfileRow(
                                Icons.home, "पत्ता", userData!['address']),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 200,
                  ),
                  SizedBox(
                    height: 50,
                    width: 200,
                    child: ElevatedButton(


                        onPressed: () async {
                          SharedPreferences prefs = await SharedPreferences.getInstance();

                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const Loginscreen(),
                              ),
                              );
                              prefs.clear();
                              

                        },
                        child: const Text(
                          "लॉगआउट",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: Colors.black),
                        ),
                        style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(
                                Colors.green.shade500),
                            shape: MaterialStateProperty.all<
                                    RoundedRectangleBorder>(
                                const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.zero,
                                    side: BorderSide(color: Colors.green))))),
                  ),
                ],
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
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
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
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
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
