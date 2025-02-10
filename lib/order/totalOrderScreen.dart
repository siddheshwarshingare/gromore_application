import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AllOrdersScreen extends StatefulWidget {
  const AllOrdersScreen({super.key});

  @override
  State<AllOrdersScreen> createState() => _AllOrdersScreenState();
}

class _AllOrdersScreenState extends State<AllOrdersScreen> {
  DateTime selectedDate = DateTime.now(); // Default to today's date

  // Function to update order status
  Future<void> _updateOrderStatus(String orderId, bool newStatus) async {
    await FirebaseFirestore.instance.collection('orders').doc(orderId).update({
      'orderStatus': newStatus,
    });
    setState(
      () {}
    ); // Refresh the UI
  }

  // Function to select a date
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2022), // Set a reasonable start date
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Format selected date to match Firestore Timestamp format (YYYY-MM-DD)
    String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('सर्व ऑर्डर्स', style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon:  Icon(Icons.calendar_month,size: 30,),
            onPressed: () => _selectDate(context),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .where('orderDate', isGreaterThanOrEqualTo: Timestamp.fromDate(DateTime(selectedDate.year, selectedDate.month, selectedDate.day)))
            .where('orderDate', isLessThan: Timestamp.fromDate(DateTime(selectedDate.year, selectedDate.month, selectedDate.day + 1)))
            .snapshots(),
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

          return 
          ListView(
            padding: const EdgeInsets.all(10),
            children: orders.map((order) {
              final orderId = order.id;
              final orderItems = List<Map<String, dynamic>>.from(order['items']);
              final orderDate = (order['orderDate'] as Timestamp).toDate();
              final formattedDate = DateFormat('MM/dd/yyyy, hh:mm a').format(orderDate);
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
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 10),
                      Text('ग्राहकाचे नाव: ${order['customerName'] ?? "Unknown"}',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      Text('ग्राहकाचा मोबाईल नंबर: ${order['mobileNumber'] ?? "Unknown"}',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      ...orderItems.map((item) {
                        return ListTile(
                          title: Text(item['title'], style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('Quantity: ${item['quantity']}'),
                          trailing: Text('₹${item['totalPrice']}',
                              style: const TextStyle(fontSize: 16, color: Colors.green)),
                        );
                      }).toList(),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('टोटल (Total):',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                          Text('₹${order['totalPrice']}',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Order Status:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          Switch(
                            value: orderStatus,
                            activeColor: Colors.green,
                            inactiveThumbColor: Colors.red,
                            onChanged: (newValue) {
                              _updateOrderStatus(orderId, newValue);
                            },
                          ),
                          Text(
                            orderStatus ? 'Completed' : 'In Process',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: orderStatus ? Colors.green : Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
