import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:gromore_application/admin/customerDetailsOrData.dart';
import 'package:gromore_application/admin/offerDetailsScreen.dart';
import 'package:gromore_application/admin/vegetablesQuantityScreen.dart';
import 'package:gromore_application/login/commenclasses/apiconstant.dart';
import 'package:gromore_application/login/loginScreen.dart';
import 'package:gromore_application/login/logoutDialog.dart';
import 'package:gromore_application/order/totalOrderScreen.dart';
import 'package:gromore_application/review/userReviewScreen.dart';
import 'package:gromore_application/vegetables/vegetablesPriceScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:device_info_plus/device_info_plus.dart';

class AdminDashboard extends StatefulWidget {
  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  bool isLoading = false;

  bool _isLoading = false;
  String token = '';
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

  Future<String?> getDeviceIdToLogout() async {
    String apiUrl = Apiconstants.getDevices;
    final response = await http.get(
      Uri.parse(apiUrl),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> devices = json.decode(response.body);

      // return the ID of the first device (or any logic you prefer)
      for (var device in devices) {
        if (device['id'].toString() != "CURRENT_DEVICE_ID") {
          return device['id'].toString();
        }
      }
    }

    return null;
  }

//logout

  Future<void> logoutFromOtherDevices() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token') ?? '';
    String apiUrl = Apiconstants.logoutDevices;

    var headers = {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json'
    };

    // Replace this with actual device ID you want to logout
    final deviceId = await getDeviceIdToLogout(); // implement logic if needed

    if (deviceId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("No device to logout.")),
      );
      return;
    }

    final request = http.Request(
      'DELETE',
      Uri.parse('$apiUrl/$deviceId'),
    );
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Logged out device ID: $deviceId")),
      );
    } else {
      print(response.reasonPhrase);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to logout device.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
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
           DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.white,
              ),
              child: Column(
               
                children: [
                  Container(
                    height: 130,
                    child: Transform.scale(
                      scale: 1.3,
                      child: Image(
                        image: AssetImage('assets/animation/pp.png',),fit:BoxFit.fill,
                      ),
                    ),
                  )
                ],
              ),
            ),
          
            ListTile(
              leading: SizedBox(
                height: 40,
                width: 40,
                child: const Image(
                    image: AssetImage('assets/animation/vegetables.gif')),
              ),
              title: Text(
                'Vegetables Price',
                style: TextStyle(
                    fontSize: width / 20, fontWeight: FontWeight.bold),
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
              leading: SizedBox(
                height: 40,
                width: 40,
                child: const Image(
                  image: AssetImage('assets/animation/online-order.gif'),
                ),
              ),
              title: Text(
                'Order History',
                style: TextStyle(
                    fontSize: width / 20, fontWeight: FontWeight.bold),
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
              leading: SizedBox(
                height: 40,
                width: 40,
                child: const Image(
                  image: AssetImage('assets/animation/market.gif'),
                ),
              ),
              title: Text(
                'Vegetable Quantity',
                style: TextStyle(
                    fontSize: width / 20, fontWeight: FontWeight.bold),
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
              leading: SizedBox(
                height: 40,
                width: 40,
                child: const Image(
                  image: AssetImage('assets/animation/rating.gif'),
                ),
              ),
              title: Text(
                'Review History',
                style: TextStyle(
                    fontSize: width / 20, fontWeight: FontWeight.bold),
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
              leading: SizedBox(
                height: 40,
                width: 40,
                child: const Image(
                  image: AssetImage('assets/animation/customer-care.gif'),
                ),
              ),
              title: Text(
                'Customer Details',
                style: TextStyle(
                    fontSize: width / 20, fontWeight: FontWeight.bold),
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
              leading: SizedBox(
                height: 40,
                width: 40,
                child: const Image(
                  image: AssetImage('assets/animation/shopping-bag.gif'),
                ),
              ),
              title: Text(
                'Offer Details',
                style: TextStyle(
                    fontSize: width / 20, fontWeight: FontWeight.bold),
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
            ListTile(
              leading: Icon(Icons.devices, color: Colors.deepPurple),
              title: Text(
                'Active Devices',
                style: TextStyle(
                  fontSize: width / 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ActiveDeviceScreen()),
                );
              },
            ),
            SizedBox(
              height: height / 4.4,
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
                child: Text('Logout', style: TextStyle(fontSize: width / 20)),
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

  // logout method
  Future<void> _logout(BuildContext context) async {
    String apiUrl = Apiconstants.logOut;
    setState(() {
      _isLoading = true;
    });

    try {
      print("1111111111111111111$token");
      final response = await http.post(
        Uri.parse(apiUrl),
        body: null,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
      );

      if (response.statusCode == 200) {
        Navigator.pop;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Logout sucessfully")),
        );
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const Loginscreen(),
          ),
          (route) => false, // This condition removes all previous routes
        );
        print("Logged Out");
      } else {
        setState(() {
          _isLoading = false;
        });
        print(response.statusCode);
        print(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            ),
            backgroundColor: Colors.red,
            duration: const Duration(milliseconds: 700),
            content: Title(
              color: Colors.redAccent,
              child: const Center(
                child: Text(
                  "Can't Logout",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          backgroundColor: Colors.red,
          duration: const Duration(milliseconds: 700),
          content: Title(
            color: Colors.redAccent,
            child: const Center(
              child: Text(
                "An error occurred. Please try again later.",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
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
                              SharedPreferences prefs =
                                  await SharedPreferences.getInstance();
                              setState(() {
                                _isLoading = true;
                                token = prefs.getString('token') ?? 'NA';
                              });
                              // SharedPreferences prefs =
                              //     await SharedPreferences.getInstance();
                              // await prefs.clear();
                             // await _logout(context);
                             LogoutDialog.show(context);
                             // await prefs.clear();

                              // await Future.delayed(
                              //     const Duration(milliseconds: 1500));
                              // Navigator.pushAndRemoveUntil(
                              //   context,
                              //   MaterialPageRoute(
                              //       builder: (_) => Loginscreen()),
                              //   (route) => false,
                              // );
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

class ActiveDeviceScreen extends StatefulWidget {
  @override
  _ActiveDeviceScreenState createState() => _ActiveDeviceScreenState();
}

class _ActiveDeviceScreenState extends State<ActiveDeviceScreen> {
  List<dynamic> devices = [];
  bool isLoading = true;
  String? currentDeviceId;
  String token = '';

  @override
  void initState() {
    super.initState();
    initialize();
  }

  Future<void> initialize() async {
    await getCurrentDeviceId();
    await fetchDevices();
  }

  Future<void> getCurrentDeviceId() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      var androidInfo = await deviceInfo.androidInfo;
      currentDeviceId = androidInfo.id; // Unique ID on Android
    } else if (Platform.isIOS) {
      var iosInfo = await deviceInfo.iosInfo;
      currentDeviceId = iosInfo.identifierForVendor; // Unique ID on iOS
    }
  }

  Future<void> fetchDevices() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token') ?? '';

    String apiUrl = Apiconstants.getDevices;
    final response = await http.get(
      Uri.parse(apiUrl),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );
    print('22222222222222222222222222222222222${response.statusCode}');
    print('22222222222222222222222222222222222${token}');
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      setState(() {
        devices = data['devices'];
        print(
            '22222222222222222222222222222222222===================${devices}');
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
      print("Failed to fetch devices: ${response.body}");
    }
  }

  Future<void> logoutDevice(String deviceId) async {
    String apiUrl = Apiconstants.logoutDevices;
    print("11111111111111111111111${Uri.parse('$apiUrl$deviceId')}");
    print("tttttttttttttttttttttttttttt$token");
    final response = await http.delete(
      Uri.parse('$apiUrl/$deviceId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Logged out device ID: $deviceId")),
      );
      fetchDevices(); // Refresh list
    } else {
      print("Logout failed: ${response.body}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Active Devices")),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : devices.isEmpty
              ? Center(child: Text("No devices found"))
              : ListView.builder(
                  itemCount: devices.length,
                  itemBuilder: (context, index) {
                    final device = devices[index];
                    bool isCurrentDevice = device['id'] == currentDeviceId;
                    return ListTile(
                      leading: Icon(Icons.device_hub),
                      title: Text(device['name']),
                      subtitle: Text("ID: ${device['id']}"),
                      trailing: isCurrentDevice
                          ? Text("This Device")
                          : IconButton(
                              icon: Icon(Icons.logout, color: Colors.red),
                              onPressed: () {
                                logoutDevice(device['id'].toString());
                              },
                            ),
                    );
                  },
                ),
    );
  }
}
