import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? userData;
  String? userName, passWord, mobileNumber;

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

    if (passWord != null || mobileNumber != null) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profile", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blueGrey,
        centerTitle: true,
      ),
      body: userData == null
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildProfileRow(Icons.person, "Name", userData!['name']),
                       SizedBox(width: 12),
                      _buildProfileRow(
                          Icons.account_circle, "Username", userData!['userName']),
                           SizedBox(width: 12),
                      _buildProfileRow(
                          Icons.phone, "Mobile", userData!['mobileNumber']),
                          
                      _buildProfileRow(
                          Icons.home, "Address", userData!['address']),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildProfileRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.blueGrey, size: 28),
          SizedBox(width: 12),
          Text(
            "$title: ",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 16, color: Colors.black54),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
