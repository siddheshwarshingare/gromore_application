import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gromore_application/userProfileScreen.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gromore_application/cart/addToCartScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  String? custmerMobilenumber;
  String? customerAddress;
  double? discount;
  double? totalPrice = 0.0;
  double deliveryCharge = 25; // Ensure totalPrice is double
  double? discountAmount = 0.0; // Calculate discount
  double? finalPrice = 0.0;
  double? vegetablePrice = 0.0;
  double temp = 0.00;
  bool _isLoading = false;
  final String? local = "";
  Future<void> fetchOfferDetails() async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('OfferDetails')
          .doc('discount') // Ensure this is the correct Firestore document ID
          .get();

      if (snapshot.exists) {
        // Perform the asynchronous operations first
        double fetchedDiscount =
            double.tryParse(snapshot["discountt"].toString()) ?? 0.0;
        print("Fetched Discount: $fetchedDiscount");

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setDouble('discount', fetchedDiscount);
        print("Fetched Discount:34343434 $fetchedDiscount");

        // Now update the state synchronously
        setState(() {
          discount = fetchedDiscount;
        });
      } else {
        setState(() {
          discount = 0.0;
        });
      }
    } catch (e) {
      print('Error fetching offer details: $e');
      setState(() {
        discount = 0.0;
      });
    }
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _checkLoginStatus();
      await fetchOfferDetails();
      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      await cartProvider.loadCartFromLocal();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      print('asjflsdjkflsjkdfjk${prefs.getDouble('discount')}');
      print("111111111111111111111111 ==${discount}");
      // Initialize cart items only once after the first frame
      Future.microtask(() {
        final cartProvider = Provider.of<CartProvider>(context, listen: false);
        print(
            '22222222222222222222222222222222222222222222222${cartProvider.cartItems}');
        prefs.setStringList('localdata',
            cartProvider.cartItems.map((item) => item.toString()).toList());
        print(
            "tttttttttttttttttttttttttttttttttttttttttttttttttt${prefs.getStringList('localdata')}");
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

    // if (customerName == null || customerAddress == null) {
    //   //alertdialogBox(context);
    //   // ScaffoldMessenger.of(context).showSnackBar(
    //   //   const SnackBar(content: Text("ऑर्डर देण्यासाठी पत्ता आवश्यक आहे.")),
    //   // );
    //   return;
    // }

    try {
      List<Map<String, dynamic>> orderItems =
          cartProvider.cartItems.map((item) {
        final price = double.tryParse(item['price'].substring(1)) ?? 0.0;
        return {
          'title': item['title'],
          'quantity': item['quantity'],
          'totalPrice': price * (item['quantity'] ?? 0),
        };
      }).toList();

      double finalOrderPrice = cartProvider.totalPrice!;
      finalOrderPrice<50? finalOrderPrice += deliveryCharge : finalOrderPrice = cartProvider.totalPrice!;
      if (discount != null && discount != 0 && finalOrderPrice > 200) {
        finalOrderPrice -= (finalOrderPrice * (discount! / 100));
      }

      await FirebaseFirestore.instance.collection('orders').add({
        'userId': result,
        'customerName': customerName,
        'customerAddress': customerAddress,
        'items': orderItems,
        'totalPrice': finalOrderPrice,
        'mobileNumber': custmerMobilenumber,
        'orderDate': Timestamp.now(),
        'orderStatus': false,
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
                onPressed: () async {
                  Navigator.of(context).pop();
                  cartProvider.cartItems.clear();
                  cartProvider.notifyListeners();
                  await cartProvider.clearCartFromLocal();
                },
              ),
            ],
          );
        },
      );
    } catch (e) {
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
          custmerMobilenumber = userData['mobileNumber'] ?? "Unknown";
          customerAddress = userData['address'] ?? "No Address Provided";
        });
      } else {
        print("User not found!");
      }
    } catch (e) {
      print("Error fetching user details: $e");
    }
  }

  void _showOrderConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        // Use dialogContext for closing dialog
        return AlertDialog(
          title: const Text("आर्डर कन्फर्म करा",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
          content: const Text("तुम्ही खरेदी निश्चित करू इच्छिता का?",
              style: TextStyle(fontSize: 18)),
          actions: <Widget>[
            TextButton(
              child: const Text("नाही",
                  style: TextStyle(fontSize: 18, color: Colors.red)),
              onPressed: () {
                Navigator.of(dialogContext)
                    .pop(); // Close the confirmation popup
              },
            ),
            TextButton(
              child: const Text("हो",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Close the popup first

                // Delay execution to avoid invalid context issue
                Future.delayed(Duration(milliseconds: 100), () {
                  placeOrderAndStoreInFirebase(context);
                });
              },
            ),
          ],
        );
      },
    );
  }

  void showpriceConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        // Use dialogContext for closing dialog
        return AlertDialog(
          title: const Text(
              "जर ऑर्डर ५० ₹ पेक्षा कमी असेल, तर तुम्हाला २५ ₹ डिलिव्हरी शुल्क भरावे लागेल. ५० ₹ पेक्षा जास्त खरेदी केल्यास डिलिव्हरी शुल्क नाही.",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
          content: const Text("तुम्ही खरेदी निश्चित करू इच्छिता का?",
              style: TextStyle(fontSize: 18)),
          actions: <Widget>[
            TextButton(
              child: const Text("नाही",
                  style: TextStyle(fontSize: 18, color: Colors.red)),
              onPressed: () {
                Navigator.of(dialogContext)
                    .pop(); // Close the confirmation popup
              },
            ),
            TextButton(
              child: const Text("हो",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Close the popup first

                // Delay execution to avoid invalid context issue
                Future.delayed(Duration(milliseconds: 100), () {
                  _showOrderConfirmationDialog(context);
                  // placeOrderAndStoreInFirebase(context);
                });
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    // Initialize the cart with orderItems passed from the previous screen
    if (widget.orderItems != null && widget.orderItems!.isNotEmpty) {
      cartProvider.cartItems.clear();
      cartProvider.cartItems.addAll(widget.orderItems!);
      cartProvider.notifyListeners();
    }
print("cartProvider.cartItems.length${cartProvider.cartItems.length}");
print("Toatal price ${totalPrice}");
    // Calculate discount and final price
    if (totalPrice!<50) {
      totalPrice = totalPrice!+deliveryCharge;
    } else {
      totalPrice = cartProvider.totalPrice;
    }
    totalPrice = cartProvider.totalPrice;
    discountAmount = (totalPrice! * (discount ?? 0) / 100);
    finalPrice = totalPrice! - discountAmount!;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('कार्ट',
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.green,
      ),
      body: cartProvider.cartItems.isEmpty &&
              cartProvider.loadCartFromLocal() != null
          ? const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: 300,
                  child: Center(
                    child: Image(
                      image: AssetImage(
                          'assets/greenVegetables/shopping-cart.gif'),
                    ),
                  ),
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
                //  SharedPreferences prefs = await SharedPreferences.getInstance();
                //  prefs.setString('item', item.toString());
                print(
                    "11111111111111111111111111111111111>>>>>>>>>>>>>>>>>${item}");
                final price =
                    double.tryParse(item['price'].substring(1)) ?? 0.0;
                final totalPrice = price * (item['quantity'] ?? 0);
                // print(item['title'].contains('अंडी'));
                bool isEgg = item['title'].contains('अंडी');
                // if (!isEgg) {
                //   temp += totalPrice;
                // }
                print("|||||||||||||||||||||||||||||||||||||||||||||$temp");
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
                          style: const TextStyle(
                              color: Colors.black, fontSize: 16)),
                      IconButton(
                        icon: Icon(Icons.add, color: Colors.green[600]),
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
              height: (discount != null && discount != 0 && totalPrice! > 200)
                  ? width / 1.7
                  : width / 1.7,
              child: Column(
                children: [
                  // Show discount only if totalPrice > 100 and discount is not zero

                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total Price',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: width / 25,
                          ),
                        ),
                        Text('₹${totalPrice!.toStringAsFixed(2)}',
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  if (totalPrice! < 50)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              //  Text("${temp}"),
                              Text(
                                'जर ऑर्डर ५० ₹ पेक्षा कमी असेल, तर तुम्हाला २५ ₹\n डिलिव्हरी शुल्क भरावे लागेल.',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                  fontSize: width / 29,
                                ),
                              ),
                              Text('₹25.00',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  )),
                            ],
                            // print("______________________${temp}");
                          ),
                          SizedBox(
                            height: 4,
                          ),
                          Text(
                              "********************************************************"),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Final Price',
                                  style: TextStyle(
                                      // fontSize: 16,
                                      fontSize: width / 25,
                                      fontWeight: FontWeight.bold),
                                ),
                                
                                Text(
                                    '₹${(totalPrice! + deliveryCharge).toStringAsFixed(2)}',
                                    style: TextStyle(
                                        //fontSize: 18,
                                        fontSize: width / 25,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green)),
                                        
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                  if (discount != null && discount != 0 && totalPrice! > 200)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          //  Text("${temp}"),
                          Text(
                            'Discount ($discount %)',
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: width / 29,
                            ),
                          ),
                          Text('-₹${discountAmount!.toStringAsFixed(2)}',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                        // print("______________________${temp}");
                      ),
                    ),
                  totalPrice! > 50
                      ? Text(
                          "************************************************************")
                      : SizedBox(),
                  if (discount != null && discount != 0 && totalPrice! > 200)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Final Price',
                            style: TextStyle(
                                // fontSize: 16,
                                fontSize: width / 25,
                                fontWeight: FontWeight.bold),
                          ),
                          Text('₹${finalPrice!.toStringAsFixed(2)}',
                              style: TextStyle(
                                  //fontSize: 18,
                                  fontSize: width / 25,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green)),
                        ],
                      ),
                    ),
                  SizedBox(
                    height: 50,
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        HapticFeedback.mediumImpact();
                        (totalPrice ?? 0) < 50
                            ? showpriceConfirmationDialog(context)
                            : _showOrderConfirmationDialog(context);
                        // _showOrderConfirmationDialog(context);
                      },
                      child: Text(
                        'ऑर्डर करा',
                        style: TextStyle(
                          //fontSize: 20
                          fontSize: width / 22,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  void alertdialogBox(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: !_isLoading,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Stack(
              children: [
                AlertDialog(
                  title: const Text(
                    "Logout Confirmation",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  content: const Text(
                      "तुम्हाला खात्री आहे की तुम्ही लॉगआउट करू इच्छिता?"),
                  actions: [
                    TextButton(
                      onPressed: _isLoading
                          ? null
                          : () {
                              Navigator.of(context).pop();
                            },
                      child: const Text(
                        "Cancel",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    GestureDetector(
                      onTap: _isLoading
                          ? null
                          : () async {
                              setState(() => _isLoading = false);
                              Navigator.of(context).pop();
                              // _logout(context);
                              // SharedPreferences prefs =
                              //     await SharedPreferences.getInstance();
                              // await prefs.clear();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => ProfileScreen()),
                              );
                            },
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          "तुमचा पत्ता भरा",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                if (_isLoading)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black.withOpacity(0.7),
                      child: const Center(
                        child: CupertinoActivityIndicator(
                          radius: 40,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }
}
