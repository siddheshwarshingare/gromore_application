import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  String? result = ''; // To store the logged-in user's ID
  List<Map<String, dynamic>> ordersList = []; // Store orders locally
  List<Map<String, dynamic>> filteredOrdersList = []; // Store filtered orders
  DateTime? selectedDate;

  @override
  void initState() {
    super.initState();
    _getUserId();
  }

  // Fetch user ID from SharedPreferences
  Future<void> _getUserId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final storedUserName = prefs.getString('userName');
    final storedMobileNumber = prefs.getString('mobileNumber');

    setState(() {
      result = storedUserName ?? storedMobileNumber;
    });

    if (result != null && result!.isNotEmpty) {
      _fetchOrders();
    }
  }

  // Fetch orders from Firestore and store them in a list
  Future<void> _fetchOrders() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('orders')
          .where('userId', isEqualTo: result)
          .get();

      List<Map<String, dynamic>> fetchedOrders = snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['orderDate'] = (data['orderDate'] as Timestamp).toDate(); // Convert timestamp to DateTime
        return data;
      }).toList();

      // Sort orders by orderDate in descending order
      fetchedOrders.sort((a, b) => b['orderDate'].compareTo(a['orderDate']));

      setState(() {
        ordersList = fetchedOrders;
        filteredOrdersList = fetchedOrders; // Initially, show all orders
      });
    } catch (e) {
      print("Error fetching orders: $e");
    }
  }

  // Filter orders based on selected date
  void _filterOrdersByDate(DateTime selectedDate) {
    setState(() {
      filteredOrdersList = ordersList.where((order) {
        DateTime orderDate = order['orderDate'];
        return orderDate.year == selectedDate.year &&
            orderDate.month == selectedDate.month &&
            orderDate.day == selectedDate.day;
      }).toList();
    });
  }

  // Show date picker and filter orders based on the selected date
  Future<void> _selectDate(BuildContext context) async {
    DateTime initialDate = DateTime.now();
    DateTime firstDate = DateTime(2000); // Start date for the date picker
    DateTime lastDate = DateTime.now(); // End date for the date picker

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
      _filterOrdersByDate(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Orders"),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () {
              _selectDate(context); // Trigger date picker when clicked
            },
          ),
        ],
      ),
      body: result == null || result == ''
          ? const Center(child: CircularProgressIndicator())
          : filteredOrdersList.isEmpty
              ? const Center(child: Text('No orders found for the selected date.'))
              : ListView.builder(
                  itemCount: filteredOrdersList.length,
                  itemBuilder: (context, index) {
                    final order = filteredOrdersList[index];
                    final orderItems = List<Map<String, dynamic>>.from(order['items']);
                    final formattedDate = DateFormat('MM/dd/yyyy, hh:mm a').format(order['orderDate']);
                    final bool orderStatus = order['orderStatus'] ?? false;

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
                              'तारीख: $formattedDate',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            const SizedBox(height: 10),
                            ...orderItems.map((item) {
                              return ListTile(
                                title: Text(item['title'], style: const TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Text('Quantity: ${item['quantity']}'),
                                trailing: Text('₹${item['totalPrice']}', style: const TextStyle(fontSize: 16, color: Colors.green)),
                              );
                            }).toList(),
                            const Divider(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('एकूण:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                                Text('₹${order['totalPrice']}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                const Text('Order Status  :  ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                Text(
                                  orderStatus ? "Completed" : "In Process",
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 233, 61, 61)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
