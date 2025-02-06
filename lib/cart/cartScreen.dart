import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gromore_application/cart/addToCartScreen.dart';

class CartScreen extends StatefulWidget {
  final List<Map<String, dynamic>>? orderItems;
  final String? orderId;

  const CartScreen({
    Key? key,
    this.orderItems,
    this.orderId,
  }) : super(key: key);

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  String? userName = '';
  String? passWord = '';
  String? mobileNumber = '';
  String? result = '';
  String? customerName;
  String? customerAddress;
@override
void initState() {
  super.initState();

  WidgetsBinding.instance.addPostFrameCallback((_) {
    _checkLoginStatus();

    // Initialize cart items only once after the first frame
    Future.microtask(() {
      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      if (widget.orderItems != null && widget.orderItems!.isNotEmpty) {
        cartProvider.cartItems.clear();
        cartProvider.cartItems.addAll(widget.orderItems!);
        cartProvider.notifyListeners(); // Notify after setting items
      } 
    });
  });
}


  Future<void> placeOrderAndStoreInFirebase(BuildContext context) async {
  final cartProvider = Provider.of<CartProvider>(context, listen: false);

  if (cartProvider.cartItems.isEmpty) return;

  if (customerName == null || customerAddress == null) {
    ScaffoldMessenger.of(context).showSnackBar( 
      const SnackBar(content: Text("Address is required to place an order")),
    );
    return;
  }

  try {
    List<Map<String, dynamic>> orderItems =
        cartProvider.cartItems.map((item) {
    final priceString = item['price'] ?? '₹0';
final price = double.tryParse(priceString.replaceAll(RegExp(r'[^\d.]'), '')) ?? 0.0;

      return {
        'title': item['title'],
        'quantity': item['quantity'],
        'totalPrice': price,
      };
    }).toList();

    await FirebaseFirestore.instance.collection('orders').add({
      'userId': result,
      'customerName': customerName,
      'customerAddress': customerAddress,
      'items': orderItems,
      'totalPrice': cartProvider.totalPrice,
      'orderDate': Timestamp.now(),
    });

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: const Text("Order Placed Successfully!",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 19)),
          actions: <Widget>[
            TextButton(
              child: const Text("OK",
                  style:
                      TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
              onPressed: () {
                Navigator.of(context).pop();
                cartProvider.cartItems.clear();
                cartProvider.notifyListeners();
              },
            ),
          ],
        );
      },
    );
  } catch (e) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: const Text("Failed to place order, please try again.",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 19)),
          actions: <Widget>[
            TextButton(
              child: const Text("OK",
                  style:
                      TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
    print("Error placing order: $e");
  }
}


  // Fetch logged-in user ID and details
  Future<void> _checkLoginStatus() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      userName = prefs.getString('userName');
      passWord = prefs.getString('passWord');
      mobileNumber = prefs.getString("mobileNumber");
      result = userName ?? mobileNumber;
    });

    if (result != null && result!.isNotEmpty) {
      await fetchUserDetails();
    }
  }

  // Fetch user details from Firestore
  Future<void> fetchUserDetails() async {
    try {
      QuerySnapshot querySnapshot;

      if (userName != null && userName!.isNotEmpty) {
        querySnapshot = await FirebaseFirestore.instance
            .collection('CustomerDetails')
            .where('userName', isEqualTo: userName)
            .where('passWord', isEqualTo: passWord)
            .get();
      } else if (mobileNumber != null && mobileNumber!.isNotEmpty) {
        querySnapshot = await FirebaseFirestore.instance
            .collection('CustomerDetails')
            .where('mobileNumber', isEqualTo: mobileNumber)
            .get();
      } else {
        print("No valid login credentials found!");
        return;
      }

      if (querySnapshot.docs.isNotEmpty) {
        final userData =
            querySnapshot.docs.first.data() as Map<String, dynamic>;
        setState(() {
          customerName = userData['name'] ?? "Unknown";
          customerAddress = userData['address'] ?? "No Address Provided";
        });
      } else {
        print("User not found!");
      }
    } catch (e) {
      print("Error fetching user details: $e");
    }
  }

  // Handle editing the cart item
  void _editCartItem(Map<String, dynamic> item) {
    // Logic to edit the item in the cart
    showDialog(
      context: context,
      builder: (context) {
        TextEditingController quantityController =
            TextEditingController(text: item['quantity'].toString());

        return AlertDialog(
          title: Text('Edit ${item['title']}'),
          content: TextField(
            controller: quantityController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Quantity',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                final updatedQuantity = int.tryParse(quantityController.text);
                if (updatedQuantity != null && updatedQuantity > 0) {
                  setState(() {
                    item['quantity'] = updatedQuantity;
                  });
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Update'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  // Update the Firestore database after modifying the cart
Future<void> updateOrderInFirestore() async {
  if (widget.orderItems == null || widget.orderItems!.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("No items to update")),
    );
    return;
  }

  try {
    double totalPrice = 0.0;

    for (var item in widget.orderItems!) {
      final priceString = item['price'] ?? '₹0'; // Default to ₹0 if price is null
      final price = double.tryParse(priceString.replaceAll(RegExp(r'[^\d.]'), '')) ?? 0.0;
      final quantity = item['quantity'] ?? 0;
      totalPrice += price * quantity;
    }

    await FirebaseFirestore.instance.collection('orders').doc(widget.orderId).update({
      'items': widget.orderItems,
      'totalPrice': totalPrice,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Order updated successfully")),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Error updating order: $e")),
    );
  }
}



  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);

    // Initialize the cart with orderItems passed from the previous screen
    if (widget.orderItems != null && widget.orderItems!.isNotEmpty) {
      cartProvider.cartItems.clear();
      cartProvider.cartItems.addAll(widget.orderItems!);
      cartProvider.notifyListeners();
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('कार्ट',
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.green,
      ),
      body: cartProvider.cartItems.isEmpty
          ? const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                    height: 300,
                    child: Center(
                        child: Image(
                            image: AssetImage(
                                'assets/greenVegetables/shopping-cart.gif'),),),
                                ),
                Text("तुमची कार्ट रिकामी आहे...",
                    style: TextStyle(
                        fontSize: 23,
                        color: Colors.black,
                        fontWeight: FontWeight.bold)),
              ],
            )
          : ListView.builder(
              itemCount: cartProvider.cartItems.length,
              itemBuilder: (context, index) {
                final item = cartProvider.cartItems[index];
                final price = double.tryParse(item['price'].substring(1)) ?? 0.0;
                final totalPrice = price * (item['quantity'] ?? 0);

                return ListTile(
                  title: Text(item['title'],
                      style: const TextStyle(color: Colors.black)),
                  subtitle: Text(
                    '₹${totalPrice.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700],
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.remove, color: Colors.green[600]),
                        onPressed: () {
                          cartProvider.removeFromCart(item);
                        },
                      ),
                      Text(item['quantity'].toString(),
                          style: const TextStyle(color: Colors.black)),
                      IconButton(
                        icon: Icon(Icons.add, color: Colors.green[600]),
                        onPressed: () {
                          cartProvider.addToCart(item);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          _editCartItem(item);  // Edit item when clicked
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
              color: Colors.green[50],
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
                        color: Colors.green[700],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        placeOrderAndStoreInFirebase(context);
                      },
                      style: ButtonStyle(
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero,
                            side: BorderSide(color: Colors.green),
                          ),
                        ),
                      ),
                      child: const Text(
                        'Place Order',
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 19,
                              fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
