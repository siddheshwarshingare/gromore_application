import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class TotalOrderScreen extends StatefulWidget {
  const TotalOrderScreen({super.key});

  @override
  State<TotalOrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<TotalOrderScreen> {
  DateTime? selectedDate; // Store the selected date
  Future<QuerySnapshot>? futureOrders;

  @override
  void initState() {
    super.initState();
    futureOrders = FirebaseFirestore.instance.collection('orders').get(); // Fetch all orders initially
  }

  // Function to show date picker and update orders list
  Future<void> _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
        _filterOrdersByDate();
      });
    }
  }

  // Function to filter orders based on selected date
  void _filterOrdersByDate() {
    if (selectedDate == null) return;

    DateTime startOfDay = DateTime(selectedDate!.year, selectedDate!.month, selectedDate!.day);
    DateTime endOfDay = startOfDay.add(const Duration(days: 1));

    setState(() {
      futureOrders = FirebaseFirestore.instance
          .collection('orders')
          .where('orderDate', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('orderDate', isLessThan: Timestamp.fromDate(endOfDay))
          .get();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Order History', style: TextStyle(fontSize: 25)),
        backgroundColor: Colors.green,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  selectedDate == null
                      ? 'Select Date'
                      : DateFormat('MM/dd/yyyy').format(selectedDate!),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                ElevatedButton(
                  onPressed: () => _pickDate(context),
                  child: const Text('Filter by Date'),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<QuerySnapshot>(
              future: futureOrders,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No orders found for the selected date.'));
                }

                final orders = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final order = orders[index];
                    final orderItems = List<Map<String, dynamic>>.from(order['items']);
                    final orderDate = (order['orderDate'] as Timestamp).toDate();
                    final formattedDate = DateFormat('MM/dd/yyyy, hh:mm a').format(orderDate);

                    return Card(
                      margin: const EdgeInsets.all(10),
                      elevation: 5,
                      color: Colors.teal.shade100,
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Date: $formattedDate',
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
                                const Text('Total:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                                Text(
                                  '₹${order['totalPrice']}',
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
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
          ),
        ],
      ),
    );
  }
}
