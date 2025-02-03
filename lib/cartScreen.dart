import 'package:flutter/material.dart';
import 'package:gromore_application/addToCartScreen.dart';
import 'package:provider/provider.dart';

class CartScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("Your Cart"),
        backgroundColor: Colors.green[700],  // Dark green AppBar
      ),
      body: cartProvider.cartItems.isEmpty
          ? Center(child: Text("Your cart is empty", style: TextStyle(fontSize: 18, color: Colors.black),))
          : ListView.builder(
              itemCount: cartProvider.cartItems.length,
              itemBuilder: (context, index) {
                final item = cartProvider.cartItems[index];
                final price = double.tryParse(item['price'].substring(1)) ?? 0.0; // Convert price string to double
                final totalPrice = price * (item['quantity'] ?? 0);

                return ListTile(
                  title: Text(item['title'], style: TextStyle(color: Colors.black)),
                  subtitle: Text(
                    '₹${totalPrice.toStringAsFixed(2)}', // Calculating total price
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700], // Dark green for price
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.remove, color: Colors.green[600]), // Slightly lighter green for the icon
                        onPressed: () {
                          cartProvider.removeFromCart(item);
                        },
                      ),
                      Text(item['quantity'].toString(), style: TextStyle(color: Colors.black)),
                      IconButton(
                        icon: Icon(Icons.add, color: Colors.green[600]), // Slightly lighter green for the icon
                        onPressed: () {
                          cartProvider.addToCart(item);
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
      bottomNavigationBar: cartProvider.cartItems.isEmpty
          ? null
          : BottomAppBar(
              color: Colors.green[50], // Light green for bottom app bar
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total: ₹${cartProvider.totalPrice.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[700], // Dark green for total price
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        // Implement checkout functionality here
                      },
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(Colors.green[700]), // Dark green button
                      ),
                      child: Text('Proceed to Checkout', style: TextStyle(color: Colors.white)), // White text
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
