import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
        SnackBar(content: Text("Address updated successfully!")),
      );
    } catch (e) {
      print("Error updating address: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update address")),
      );
    }
  }

  void _showEditAddressDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Edit Address"),
          content: TextField(
            controller: _addressController,
            decoration: InputDecoration(
              hintText: "Enter new address",
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                _updateAddress(_addressController.text);
                Navigator.pop(context);
              },
              child: Text("Save"),
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
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20.0),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.blue.shade400,
                      Colors.pink.shade700,
                      Colors.yellow,
                      Colors.green
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Card(
                  elevation: 14,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  color: Colors.transparent,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: 20),
                        _buildProfileRow(Icons.person, "Name", userData!['name']),
                        _buildProfileRow(Icons.account_circle, "Username",
                            userData!['userName']),
                        _buildProfileRow(
                            Icons.phone, "Mobile", userData!['mobileNumber']),
                        _buildEditableProfileRow(
                            Icons.home, "Address", userData!['address']),
                        Spacer(),
                        ElevatedButton(
                          onPressed: () {},
                          child: Text("Logout"),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  AppBar _buildGradientAppBar() {
    return AppBar(
      title: Text(
        "Profile",
        style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
      ),
      centerTitle: true,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.blue.shade400,
              Colors.pink.shade700,
              Colors.yellow,
              Colors.green
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
    );
  }

  Widget _buildProfileRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.blueAccent, size: 26),
          SizedBox(width: 16),
          Text(
            "$title: ",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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
          Icon(icon, color: Colors.blueAccent, size: 26),
          SizedBox(width: 16),
          Text(
            "$title: ",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            icon: Icon(Icons.edit, color: Colors.blueAccent),
            onPressed: _showEditAddressDialog,
          ),
        ],
      ),
    );
  }
}
