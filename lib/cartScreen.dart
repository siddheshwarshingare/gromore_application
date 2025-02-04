import 'package:flutter/material.dart';
import 'package:gromore_application/addToCartScreen.dart';
import 'package:provider/provider.dart';

class CartScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Your Cart"),
        backgroundColor: Colors.green[700],  // Dark green AppBar
      ),
      body: cartProvider.cartItems.isEmpty
          ? const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 300,
                child: Center(child: Image(image: AssetImage('assets/greenVegetables/shopping-cart.gif')))),
              Text("Your cart is empty", style: TextStyle(fontSize: 23, color: Colors.black),),
            ],
          )
          
          : ListView.builder(
              itemCount: cartProvider.cartItems.length,
              itemBuilder: (context, index) {
                final item = cartProvider.cartItems[index];
                final price = double.tryParse(item['price'].substring(1)) ?? 0.0; // Convert price string to double
                final totalPrice = price * (item['quantity'] ?? 0);

                return ListTile(
                  title: Text(item['title'], style: const TextStyle(color: Colors.black)),
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
                      Text(item['quantity'].toString(), style: const TextStyle(color: Colors.black)),
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
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[700], // Dark green for total price
                      ),
                    ),
                 ElevatedButton(
                onPressed: () {
                 showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
      
          content: const Text("Your order has been successfully added to the cart.",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 19),),
          actions: <Widget>[
            TextButton(
              child: const Text("OK",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20),),
              onPressed: () {
                Navigator.of(context).pop(); 
              },
            ),
          ],
        );
      },
    );
  },
  style: ButtonStyle(
    backgroundColor: MaterialStateProperty.all(Colors.green[500]), 
  ),
  child: const Text('Proceed to Checkout', style: TextStyle(color: Colors.black,fontSize: 18)), 
),

                  ],
                ),
              ),
            ),
    );
  }
}
