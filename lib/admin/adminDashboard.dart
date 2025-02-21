import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:gromore_application/admin/customerDetailsOrData.dart';
import 'package:gromore_application/admin/offerDetailsScreen.dart';
import 'package:gromore_application/admin/vegetablesQuantityScreen.dart';
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
  bool isLoading = false;
  bool _isLoading = false;
  List<Map<String, String>> vegetableData = [];

  Map<String, String> titleToKeyMap = {
    "मेथी": "methi",
    "गवार": "gavar",
    "पालक": "palak",
    "चवली": "chavali",
    "चूका": "chuka",
    "कोथिंबीर": "kothimbir",
    "शेपू": "shepu",
    "भेंडी": "bhendi",
    "कांदा पथ": "kandaPath",
    "कंदे": "kande",
    "करले": "karle",
    "डोकडा": "dodka",
    "काकड़ी": "kakdi",
    "आलू": "allu",
    "दोडका": "dodka",
    "वांगे": "vange",
    "फुलगोबी": "gobi",
    "पत्तागोबी": "pattagobi",
    "वालाच्या शेंगा": "valachyashenga",
  };

  Map<String, String> vegetableQuantities = {};
  Map<String, int> orderedQuantities = {};
  String? selectedVegetable;
  String? selectedVegetableQuantity = "N/A";
  String? selectedOrderedQuantity = "0 KG";
  String? selectedRemainingQuantity = "0 KG";

  @override
  void initState() {
    super.initState();
    fetchVegetableQuantities();
    fetchOrderedQuantities();
  }

  Future<void> fetchVegetableQuantities() async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('VegetablesPrice')
          .doc('QuantityOfVegetable')
          .get();
      if (snapshot.exists) {
        setState(() {
          vegetableQuantities =
              Map<String, String>.from(snapshot.data() as Map<String, dynamic>);
        });
      }
    } catch (e) {
      print("Error fetching vegetable quantities: $e");
    }
  }

  Future<void> fetchOrderedQuantities() async {
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('orders').get();
      Map<String, int> tempOrderedQuantities = {};

      for (var doc in snapshot.docs) {
        Map<String, dynamic> orderData = doc.data() as Map<String, dynamic>;
        orderData.forEach((key, value) {
          if (value is int) {
            tempOrderedQuantities[key] =
                (tempOrderedQuantities[key] ?? 0) + value;
          }
        });
      }
      setState(() {
        orderedQuantities = tempOrderedQuantities;
        isLoading = false; // ✅ Update this to stop showing the loader
      });
    } catch (e) {
      print("Error fetching ordered quantities: $e");
      setState(() {
        isLoading = false; // ✅ Ensure loading state is stopped even on error
      });
    }
  }

  String normalizeName(String name) {
    return name.trim().toLowerCase().replaceAll(RegExp(r"\s+"), "");
  }

  void _onVegetableSelected(String vegetable) {
    setState(() {
      selectedVegetable = vegetable;
      String vegetableKey = titleToKeyMap[vegetable] ?? vegetable;
      selectedVegetableQuantity = vegetableQuantities[vegetableKey] ?? "N/A";

      int orderedQuantity = orderedQuantities[normalizeName(vegetableKey)] ?? 0;

      double availableQty = double.tryParse(
              selectedVegetableQuantity!.replaceAll(RegExp(r'[^\d.]'), '')) ??
          0;
      double remainingQty = availableQty - orderedQuantity;
      if (remainingQty < 0) remainingQty = 0;

      selectedOrderedQuantity = "$orderedQuantity KG";
      selectedRemainingQuantity = "${remainingQty.toStringAsFixed(2)} KG";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.brown.shade400,
      appBar: AppBar(
        backgroundColor: Colors.purple,
        title: const Text("Admin Dashboard"),
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
                  image: AssetImage('assets/animation/vegetables.gif')),
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
                  ),
                );
              },
            ),
            ListTile(
              leading: const Image(
                image: AssetImage('assets/animation/online-order.gif'),
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
                  ),
                );
                Navigator.pushNamed(context, '/contact');
              },
            ),
            ListTile(
              leading: const Image(
                image: AssetImage('assets/animation/market.gif'),
              ),
              title: const Text(
                'Vegetable Quantity',
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => VegetableQuantityScreen(),
                    ));
                Navigator.pushNamed(context, '/contact');
              },
            ),
            ListTile(
              leading: const Image(
                image: AssetImage('assets/animation/rating.gif'),
              ),
              title: const Text(
                'Review History',
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
                image: AssetImage('assets/animation/customer-care.gif'),
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
                image: AssetImage('assets/animation/shopping-bag.gif'),
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
            Container(
              width: 60,
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
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: () async {
                //await fetchVegetableQuantities();
                await fetchOrderedQuantities();
              },
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Select Vegetable:",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    DropdownButton<String>(
                      value: selectedVegetable,
                      isExpanded: true,
                      hint: const Text("Choose a vegetable"),
                      items: vegetableData.map((veg) {
                        return DropdownMenuItem<String>(
                          value: veg["name"],
                          child: Text(veg["name"]!),
                        );
                      }).toList(),
                      onChanged: (value) {
                        _onVegetableSelected(value!);
                      },
                    ),
                    const SizedBox(height: 20),
                    selectedVegetable != null
                        ? Card(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            elevation: 3,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Stock Details for $selectedVegetable",
                                    style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                      "✅ Available: $selectedVegetableQuantity",
                                      style: const TextStyle(
                                          fontSize: 18, color: Colors.green)),
                                  const SizedBox(height: 5),
                                  Text("📦 Ordered: $selectedOrderedQuantity",
                                      style: const TextStyle(
                                          fontSize: 18, color: Colors.orange)),
                                  const SizedBox(height: 5),
                                  Text(
                                      "⚠️ Remaining: $selectedRemainingQuantity",
                                      style: const TextStyle(
                                          fontSize: 18, color: Colors.red)),
                                ],
                              ),
                            ),
                          )
                        : const Center(
                            child: Text("Select a vegetable to view details",
                                style: TextStyle(fontSize: 16))),
                  ],
                ),
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
                      child: 
                      Container(
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
