import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gromore_application/admin/customerDetailsOrData.dart';
import 'package:gromore_application/admin/offerDetailsScreen.dart';
import 'package:gromore_application/login/loginScreen.dart';
import 'package:gromore_application/order/totalOrderScreen.dart';
import 'package:gromore_application/review/userReviewScreen.dart';
import 'package:gromore_application/vegetables/vegetablesPriceScreen.dart';

import 'package:shared_preferences/shared_preferences.dart';
class AdminDashboard extends StatefulWidget {
  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        
        title: const Text("Admin Dashboard"),
        automaticallyImplyLeading: true, // ✅ Fix for missing drawer button
        actions: [
          Container(
            width: 130,
            margin: const EdgeInsets.all(10),
            child: ElevatedButton(
              onPressed: () {
                HapticFeedback.mediumImpact();
                alertdialogBox(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
              child: const Text('Logout', style: TextStyle(fontSize: 16)),
            ),
          ),
        ],
      ),
      
            drawer: Drawer(
        backgroundColor: Colors.white,
        child: ListView(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.white,
              ),
              child: Column(
                children: [
                  SizedBox(
                    height: 130,
                    child: Image(
                      image: AssetImage('assets/animation/pp.png'),
                    ),
                  )
                ],
              ),
            ),
            ListTile(
              leading: const Image(
                  image: AssetImage('assets/greenVegetables/cart.gif')),
              title: const Text(
                'Vegetables Price',
                style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
              ),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => VegetablePriceScreen(),

                      // OrderScreen(),
                    ));
              },
            ),
            ListTile(
              leading: const Image(
                image: AssetImage('assets/animation/reviewhistory.gif'),
              ),
              title: const Text(
                'Order History',
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AllOrdersScreen(),
                    ));
                Navigator.pushNamed(context, '/contact');
              },
            ),
            ListTile(
              leading: const Image(
                image: AssetImage('assets/animation/reviewhistory.gif'),
              ),
              title: const Text(
                'अभिप्राय हिस्ट्री',
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const UserReviewsScreen(),
                    ));
                Navigator.pushNamed(context, '/contact');
              },
            ),
            ListTile(
              leading: const Image(
                image: AssetImage('assets/animation/reviewhistory.gif'),
              ),
              title: const Text(
                'Customer Details',
                style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
              ),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CustomerDetailsScreen(),
                    ));
                Navigator.pushNamed(context, '/contact');
              },
            ),
            ListTile(
              leading: const Image(
                image: AssetImage('assets/animation/reviewhistory.gif'),
              ),
              title: const Text(
                'Offer Details',
                style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
              ),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DiscountOfferScreen(),
                    ));
                Navigator.pushNamed(context, '/contact');
              },
            ),
          ],  
        ),
      ),
      body: const Center(
        child: Text("Welcome to Admin Dashboard!"),
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
                  content: const Text("Are you sure you want to logout?"),
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
                              setState(() => _isLoading = true);
                              SharedPreferences prefs =
                                  await SharedPreferences.getInstance();
                              await prefs.clear();
                              await Future.delayed(
                                  const Duration(milliseconds: 1500));
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => Loginscreen()),
                                (route) => false,
                              );
                            },
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          "Logout",
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
