import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CustomerDetailsScreen extends StatefulWidget {
  @override
  _CustomerDetailsScreenState createState() => _CustomerDetailsScreenState();
}

class _CustomerDetailsScreenState extends State<CustomerDetailsScreen> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> customerDetailsList = [];
  bool isLoading = true;
  bool showPasswords = false; // Toggle password visibility

  @override
  void initState() {
    super.initState();
    _fetchCustomerDetails();
  }

  // Fetch all customer details from Firestore
  Future<void> _fetchCustomerDetails() async {
    try {
      QuerySnapshot querySnapshot =
          await firestore.collection('CustomerDetails').get();

      setState(() {
        customerDetailsList = querySnapshot.docs.map((doc) {
          return {
            'name': doc['name'],
            'userName': doc['userName'],
            'address': doc['address'],
            'mobileNumber': doc['mobileNumber'],
            'passWord': doc['passWord'],
          };
        }).toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error fetching data: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, // Allows the background to extend behind AppBar
      appBar: AppBar(
        backgroundColor: Colors.green,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Customer Details',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Colors.black),
        ),
      ),
      body: Stack(
        children: [
          // Soft Gradient Background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFFEECE2), // Light cream
                  Color(0xFFFFD8A8)  // Warm orange
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          isLoading
              ? const Center(child: CircularProgressIndicator(color: Colors.orange))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ListView.builder(
                    itemCount: customerDetailsList.length,
                    itemBuilder: (context, index) {
                      var customer = customerDetailsList[index];

                      return Card(
                        elevation: 8,
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        color: const Color(0xFFFDF6EC), // Light Beige
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.deepOrangeAccent.shade100,
                            child: Text(
                              customer['name'][0].toUpperCase(),
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.deepOrange,
                              ),
                            ),
                          ),
                          title: Text(
                            customer['name'],
                            style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Icon(Icons.person, size: 18, color: Colors.brown),
                                  const SizedBox(width: 5),
                                  Text(
                                    "Username: ${customer['userName']}",
                                    style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black54),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.location_on, size: 18, color: Colors.green),
                                  const SizedBox(width: 5),
                                  Expanded(
                                    child: Text(
                                      "Address: ${customer['address']}",
                                      style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black54),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.phone, size: 18, color: Colors.blueAccent),
                                  const SizedBox(width: 5),
                                  Text(
                                    "Mobile: ${customer['mobileNumber']}",
                                    style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black54),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.lock, size: 18, color: Colors.red),
                                  const SizedBox(width: 5),
                                  Expanded(
                                    child: Text(
                                      showPasswords
                                          ? "Password: ${customer['passWord']}"
                                          : "Password: •••••••",
                                      style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black54),
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      showPasswords ? Icons.visibility : Icons.visibility_off,
                                      size: 20,
                                      color: Colors.grey,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        showPasswords = !showPasswords;
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
        ],
      ),
    );
  }
}
