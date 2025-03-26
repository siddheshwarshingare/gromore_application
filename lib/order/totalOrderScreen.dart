import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AllOrdersScreen extends StatefulWidget {
  const AllOrdersScreen({super.key});

  @override
  State<AllOrdersScreen> createState() => _AllOrdersScreenState();
}

class _AllOrdersScreenState extends State<AllOrdersScreen> {
  DateTime selectedDate = DateTime.now();
  String searchQuery = "";
  double? discount;     

  // Function to update order status
  Future<void> _updateOrderStatus(String orderId, bool newStatus) async {
    await FirebaseFirestore.instance.collection('orders').doc(orderId).update({
      'orderStatus': newStatus,
    });
    setState(() {}); // Refresh the UI
  }

  // Function to select a date
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2022),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getDiscountValue();
    //  _getUserId();
  }

// Get the discount Value

  Future<void> getDiscountValue() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    discount = prefs.getDouble('discount') ?? 0.0;
    print("Discount: $discount");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'सर्व ऑर्डर्स',
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month, size: 30),
            onPressed: () => _selectDate(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Search by name or status (Completed/In Process)',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value.trim().toLowerCase();
                });
              },
            ),
          ),

          // Orders List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('orders')
                  .where(
                    'orderDate',
                    isGreaterThanOrEqualTo: Timestamp.fromDate(DateTime(
                        selectedDate.year,
                        selectedDate.month,
                        selectedDate.day)),
                  )
                  .where(
                    'orderDate',
                    isLessThan: Timestamp.fromDate(DateTime(selectedDate.year,
                        selectedDate.month, selectedDate.day + 1)),
                  )
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                      child: Text('No orders found for the selected date.'));
                }

                final orders = snapshot.data!.docs;

                // Filter orders based on search query
                final filteredOrders = orders.where((order) {
                  final String customerName =
                      (order['customerName'] ?? "").toString().toLowerCase();
                  final bool orderStatus = order['orderStatus'];
                  final String statusText =
                      orderStatus ? "completed" : "in process";

                  // If the search query is empty, show all orders
                  if (searchQuery.isEmpty) return true;

                  // Check if the query matches customer name or order status
                  return customerName.contains(searchQuery) ||
                      statusText.contains(searchQuery);
                }).toList();

                // Sort the filtered orders by order date in descending order
                filteredOrders.sort((a, b) {
                  final aDate = (a['orderDate'] as Timestamp).toDate();
                  final bDate = (b['orderDate'] as Timestamp).toDate();
                  return bDate
                      .compareTo(aDate); // Sort by descending order date
                });

                // Calculate total amount and vegetable quantities
                double totalAmount = 0.0;
                Map<String, int> vegetableQuantities = {};

                for (var order in filteredOrders) {
                  totalAmount += (order['totalPrice'] as num).toDouble();

                  final orderItems =
                      List<Map<String, dynamic>>.from(order['items']);
                  for (var item in orderItems) {
                    String itemTitle = item['title'];
                    int quantity = item['quantity'];
                    if (vegetableQuantities.containsKey(itemTitle)) {
                      vegetableQuantities[itemTitle] =
                          vegetableQuantities[itemTitle]! + quantity;
                    } else {
                      vegetableQuantities[itemTitle] = quantity;
                    }
                  }
                }

                return ListView(padding: const EdgeInsets.all(10), children: [
                  // Display total amount

                  // Display total quantity for each vegetable
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: vegetableQuantities.entries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Text(
                              '${entry.key}: ${entry.value} quantity',
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            entry.key != "गावरान अंडी (12 नग)" &&
                                    entry.key != "गावरान अंडी (6 नग)"
                                ? Text(
                                    '  OR  ${entry.value / 4} KG',
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  )
                                : const SizedBox(),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        //SharedPreferences prefs = await SharedPreferences.getInstance();

                        Text(
                          'एकूण रक्कम:',
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black),
                        ),
                        Text(
                          '₹${totalAmount.toStringAsFixed(2)}',
                          style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                  const Divider(),

                  // Orders List
                  ...filteredOrders.map((order) {
                    final orderId = order.id;
                    final orderItems =
                        List<Map<String, dynamic>>.from(order['items']);
                    final orderDate =
                        (order['orderDate'] as Timestamp).toDate();
                    final formattedDate =
                        DateFormat('MM/dd/yyyy, hh:mm a').format(orderDate);
                    final bool orderStatus = order['orderStatus'];

                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      elevation: 5,
                      color: Colors.teal.shade100,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('तारीख: $formattedDate',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16)),
                            const SizedBox(height: 10),
                            Text(
                                'ग्राहकाचे नाव: ${order['customerName'] ?? "Unknown"}',
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 10),
                            Text(
                                'ग्राहकाचा मोबाईल नंबर: ${order['mobileNumber'] ?? "Unknown"}',
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
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
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'एकूण ऑर्डर रक्कम: Discount($discount)',
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black),
                                ),
                                Text(
                                  '₹${(order['totalPrice'] as num).toDouble().toStringAsFixed(2)}',
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            // Display Order Status
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Order Status:',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16)),
                                Text(
                                  orderStatus ? 'Completed' : 'In Process',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color:
                                        orderStatus ? Colors.green : Colors.red,
                                  ),
                                ),
                                Switch(
                                  value: orderStatus,
                                  activeColor: Colors.green,
                                  inactiveThumbColor: Colors.red,
                                  onChanged: (newValue) {
                                    _updateOrderStatus(orderId, newValue);
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ]);
              },
            ),
          ),
        ],
      ),
    );
  }
}
