import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AllOrdersScreen extends StatefulWidget {
  const AllOrdersScreen({super.key});

  @override
  State<AllOrdersScreen> createState() => _AllOrdersScreenState();
}

class _AllOrdersScreenState extends State<AllOrdersScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('सर्व ऑर्डर्स', style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold)),
        backgroundColor: Colors.green,
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance.collection('orders').get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No orders found.'));
          }

          final orders = snapshot.data!.docs;

          return ListView(
            padding: const EdgeInsets.all(10),
            children: orders.map((order) {
              final orderItems = List<Map<String, dynamic>>.from(order['items']);
              final orderDate = (order['orderDate'] as Timestamp).toDate();
              final formattedDate = DateFormat('MM/dd/yyyy, hh:mm a').format(orderDate);
              
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                elevation: 5,
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
                      Text(
                        'ग्राहकाचे नाव: ${order['customerName'] ?? "Unknown"}',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                        const SizedBox(height: 10),
                       Text(
                        'ग्राहकाच मोबाईल नंबर : ${order['mobileNumber'] ?? "Unknown"}',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                        const SizedBox(height: 10),
                      Text(
                        'पत्ता: ${order['customerAddress'] ?? "No Address"}',
                        style: const TextStyle(fontSize: 16,fontWeight: FontWeight.bold),
                      ),
                     // const SizedBox(height: 10),
                      ...orderItems.map((item) {
                        return ListTile(
                          title: Text(item['title'],
                              style: const TextStyle(fontWeight: FontWeight.bold)),
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
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
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
