import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CustomerDetailsScreen extends StatefulWidget {
  @override
  _CustomerDetailsScreenState createState() => _CustomerDetailsScreenState();
}

class _CustomerDetailsScreenState extends State<CustomerDetailsScreen> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // List to store all customer details
  List<Map<String, dynamic>> customerDetailsList = [];
  
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCustomerDetails();
  }

  // Fetch all customer details from Firestore
  Future<void> _fetchCustomerDetails() async {
    try {
      // Fetch all documents from 'CustomerDetails' collection
      QuerySnapshot querySnapshot = await firestore.collection('CustomerDetails').get();
      
      // Iterate over all documents and add them to the list
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
        isLoading = false; // Stop loading once the data is fetched
      });
    } catch (e) {
      setState(() {
        isLoading = false; // Error occurred, stop loading
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error fetching data: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 83, 214, 214),
      appBar: AppBar(
        backgroundColor:  Colors.green,
        title: Center(child: const Text('Customer Details',style: TextStyle(fontWeight: FontWeight.bold,),)),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator()) // Loading indicator
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView.builder(
                itemCount: customerDetailsList.length,
                itemBuilder: (context, index) {
                  var customer = customerDetailsList[index];
                  return Card(
                    elevation: 10,
                    color: Color.fromARGB(255, 241, 78, 206),
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title: Text('Customre Name : ${customer['name']}',style: TextStyle(fontWeight: FontWeight.bold,),),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Username: ${customer['userName']}',style: TextStyle(fontWeight: FontWeight.bold,),),
                          SizedBox(height: 4,),
                          Text('Address: ${customer['address']}',style: TextStyle(fontWeight: FontWeight.bold,),),
                           SizedBox(height: 4,),
                          Text('Mobile Number: ${customer['mobileNumber']}',style: TextStyle(fontWeight: FontWeight.bold,),),
                           SizedBox(height: 4,),
                          Text('Password: ${customer['passWord']}',style: TextStyle(fontWeight: FontWeight.bold,),),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
