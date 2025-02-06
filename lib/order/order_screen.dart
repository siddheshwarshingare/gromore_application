import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gromore_application/cart/cartScreen.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gromore_application/cart/addToCartScreen.dart'; // Assuming this is where CartScreen is located

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  String? result =
      ''; // To store the logged-in user's ID (userName or mobileNumber)

  // Fetch the result (userId) from SharedPreferences
  Future<void> _getUserId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final storedUserName = prefs.getString('userName');
    final storedMobileNumber = prefs.getString('mobileNumber');

    // Determine whether to use userName or mobileNumber
    setState(() {
      result = storedUserName ?? storedMobileNumber;
    });
  }

  @override
  void initState() {
    super.initState();
    _getUserId(); // Fetch user ID when the screen is initialized
  }

  Future<void> _deleteOrder(String orderId) async {
    try {
      await FirebaseFirestore.instance
          .collection('orders')
          .doc(orderId)
          .delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Order deleted successfully")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: result?.isEmpty ?? true // Check if result is still null or empty
          ? const Center(child: CircularProgressIndicator())
          : FutureBuilder<QuerySnapshot>(
              // Query orders filtered by the user's ID (result)
              future: FirebaseFirestore.instance
                  .collection('orders')
                  .where('userId',
                      isEqualTo:
                          result) // Filter orders by userId (either userName or mobileNumber)
                  .get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No orders placed yet.'));
                }

                final orders = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final order = orders[index];
                    final orderItems =
                        List<Map<String, dynamic>>.from(order['items']);
                    final orderDate =
                        (order['orderDate'] as Timestamp).toDate();
                    final formattedDate =
                        DateFormat('MM/dd/yyyy, hh:mm a').format(orderDate);

                    return Card(
                      margin: const EdgeInsets.all(10),
                      elevation: 20,
                      color: Colors.teal.shade100,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ' तारीख: $formattedDate', // Use formatted date
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            const SizedBox(height: 10),
                            ...orderItems.map((item) {
                              return ListTile(
                                title: Text(item['title'],
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                                subtitle: Text('Quantity: ${item['quantity']}'),
                                trailing: Text('₹${item['totalPrice']}',
                                    style: const TextStyle(
                                        fontSize: 16, color: Colors.green)),
                              );
                            }).toList(),
                            const Divider(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('टोटल(एकूण):',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18)),
                                Text('₹${order['totalPrice']}',
                                    style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green)),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit,
                                      color: Colors.blue),
                                  onPressed: () {
                                    // Pass orderItems to CartScreen
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => CartScreen(
                                          orderItems:
                                              orderItems, // Pass the list of order items
                                          orderId:
                                              order.id, // Pass the order ID
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed: () => _deleteOrder(order.id),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
