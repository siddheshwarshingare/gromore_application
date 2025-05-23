import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gromore_application/about/aboutUs.dart';
import 'package:gromore_application/admin/adminDashboard.dart';
import 'package:gromore_application/cart/addToCartScreen.dart';
import 'package:gromore_application/cart/cartScreen.dart';
import 'package:gromore_application/contact/contact_us.dart';
import 'package:gromore_application/eggs/eggs_screen.dart';
import 'package:gromore_application/login/loginScreen.dart';
import 'package:gromore_application/order/order_screen.dart';
import 'package:gromore_application/review/reviewScreen.dart';
import 'package:gromore_application/userProfileScreen.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // List to store counts for each item
  final List<int> itemCounts = List.filled(12, 0);
  final TextEditingController _searchController = TextEditingController();
  bool isLoading = true;
  String offerDetails = '';
  int _selectedIndex = 0;
  List<Map<String, dynamic>> _filteredItems = [];
  bool _isLoading = false;
  GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey();

  final List<Map<String, dynamic>> menuItems = [
    {
      "title": "मेथी",
      "image": "assets/greenVegetables/methi.jpg",
      "vegetablesName": "/vegetables",
      "price": ''
    },
    {
      "title": "गवार",
      "image": "assets/greenVegetables/gavar.jpg",
      "vegetablesName": "/fruits",
      "price": ''
    },
    {
      "title": "पालक",
      "image": "assets/greenVegetables/palak.jpg",
      "vegetablesName": "/cart",
      "price": ''
    },
    {
      "title": "चवली",
      "image": "assets/greenVegetables/chawli.png",
      "vegetablesName": "/orders",
      "price": ''
    },
    {
      "title": "कोथिंबीर",
      "image": "assets/greenVegetables/kothimbir.jpeg",
      "vegetablesName": "/profile",
      "price": ''
    },
    {
      "title": "शेपू",
      "image": "assets/greenVegetables/sepu.jpg",
      "vegetablesName": "/settings",
      "price": ''
    },
    {
      "title": "कंदे",
      "image": "assets/greenVegetables/kandhe.jpg",
      "vegetablesName": "/vegetables",
      "price": ''
    },
    {
      "title": "भेंडी",
      "image": "assets/greenVegetables/bhendi.jpg",
      "vegetablesName": "/fruits",
      "price": ''
    },
    {
      "title": "आलू",
      "image": "assets/greenVegetables/batate.jpg",
      "vegetablesName": "/fruits",
      "price": ''
    },
    {
      "title": "काकड़ी",
      "image": "assets/greenVegetables/kakdi.jpeg",
      "vegetablesName": "/fruits",
      "price": ''
    },
    {
      "title": "कांदा पथ",
      "image": "assets/greenVegetables/kandhapath.jpg",
      "vegetablesName": "/fruits",
      "price": ''
    },
    {
      "title": "करले",
      "image": "assets/greenVegetables/karela.jpg",
      "vegetablesName": "/fruits",
      "price": ''
    },
    {
      "title": "वांगे",
      "image": "assets/greenVegetables/vange.jpg",
      "vegetablesName": "/fruits",
      "price": ''
    },
    {
      "title": "फुलगोबी",
      "image": "assets/greenVegetables/gobi.jpg",
      "vegetablesName": "/fruits",
      "price": ''
    },
    {
      "title": "पत्तागोबी",
      "image": "assets/greenVegetables/pattagobi.jpg",
      "vegetablesName": "/fruits",
      "price": ''
    },
    {
      "title": "वालाच्या शेंगा",
      "image": "assets/greenVegetables/valachyashenga.png",
      "vegetablesName": "/fruits",
      "price": ''
    },
  ];
// fetch the value of vegetables from the firebase
  Future<void> fetchVegetablePrices() async {
    try {
      // Fetch prices
      DocumentSnapshot priceSnapshot = await FirebaseFirestore.instance
          .collection('VegetablesPrice')
          .doc('vegetablePrices')
          .get();

      // Fetch quantities
      DocumentSnapshot quantitySnapshot = await FirebaseFirestore.instance
          .collection('VegetablesPrice')
          .doc('QuantityOfVegetable')
          .get();

      if (priceSnapshot.exists && quantitySnapshot.exists) {
        Map<String, dynamic> fetchedPrices =
            priceSnapshot.data() as Map<String, dynamic>;
        Map<String, dynamic> fetchedQuantities =
            quantitySnapshot.data() as Map<String, dynamic>;

        print("Fetched Prices: $fetchedPrices");
        print("Fetched Quantities: $fetchedQuantities");

        setState(() {
          isLoading = false;

          // Map for Prices
          Map<String, String> vegetablePrices = {
            "bhendi": fetchedPrices["bhendiVegetablesPrice"] ?? "N/A",
            "chavali": fetchedPrices["chavaliVegetablesPrice"] ?? "N/A",
            "chuka": fetchedPrices["chukaVegetablesPrice"] ?? "N/A",
            "dodka": fetchedPrices["dodkaVegetablesPrice"] ?? "N/A",
            "gavar": fetchedPrices["gavarVegetablesPrice"] ?? "N/A",
            "kakdi": fetchedPrices["kakdiVegetablesPrice"] ?? "N/A",
            "kandaPath": fetchedPrices["kandaPathVegetablesPrice"] ?? "N/A",
            "kande": fetchedPrices["kandeVegetablesPrice"] ?? "N/A",
            "karle": fetchedPrices["karleVegetablesPrice"] ?? "N/A",
            "kothimbir": fetchedPrices["kothimbirVegetablesPrice"] ?? "N/A",
            "methi": fetchedPrices["methiVegetablesPrice"] ?? "N/A",
            "palak": fetchedPrices["palakVegetablesPrice"] ?? "N/A",
            "shepu": fetchedPrices["shepuVegetablesPrice"] ?? "N/A",
            "allu": fetchedPrices["alluVegetablesPrice"] ?? "N/A",
            "vange": fetchedPrices["vangeVegetablesPrice"] ?? "N/A",
            "gobi": fetchedPrices["gobiVegetablesPrice"] ?? "N/A",
            "pattagobi": fetchedPrices["pattagobiVegetablesPrice"] ?? "N/A",
            "valachyashenga":
                fetchedPrices["valachyashengaVegetablesPrice"] ?? "N/A"
          };

          // Map for Quantities
          Map<String, String> vegetableQuantities = {
            "bhendi": fetchedQuantities["bhendiVegetablesQuantity"] ?? "N/A",
            "chavali": fetchedQuantities["chavaliVegetablesQuantity"] ?? "N/A",
            "chuka": fetchedQuantities["chukaVegetablesQuantity"] ?? "N/A",
            "dodka": fetchedQuantities["dodkaVegetablesQuantity"] ?? "N/A",
            "gavar": fetchedQuantities["gavarVegetablesQuantity"] ?? "N/A",
            "kakdi": fetchedQuantities["kakdiVegetablesQuantity"] ?? "N/A",
            "kandaPath":
                fetchedQuantities["kandaPathVegetablesQuantity"] ?? "N/A",
            "kande": fetchedQuantities["kandeVegetablesQuantity"] ?? "N/A",
            "karle": fetchedQuantities["karleVegetablesQuantity"] ?? "N/A",
            "kothimbir":
                fetchedQuantities["kothimbirVegetablesQuantity"] ?? "N/A",
            "methi": fetchedQuantities["methiVegetablesQuantity"] ?? "N/A",
            "palak": fetchedQuantities["palakVegetablesQuantity"] ?? "N/A",
            "allu": fetchedQuantities["alluVegetablesQuantity"] ?? "N/A",
            "vange": fetchedQuantities["vangeVegetablesQuantity"] ?? "N/A",
            "gobi": fetchedQuantities["gobiVegetablesQuantity"] ?? "N/A",
            "pattagobi":
                fetchedQuantities["pattagobiVegetablesQuantity"] ?? "N/A",
            "valachyashenga":
                fetchedQuantities["valachyashengaVegetablesQuantity"] ?? "N/A"
          };

          // Hindi to Key Mapping
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

          // Update menuItems
          for (var item in menuItems) {
            String vegetableKey = titleToKeyMap[item["title"]] ?? "";

            if (vegetablePrices.containsKey(vegetableKey)) {
              item["price"] = "₹${vegetablePrices[vegetableKey]}";
            }
            if (vegetableQuantities.containsKey(vegetableKey)) {
              item["quantity"] = vegetableQuantities[vegetableKey];
            }
          }
        });
      } else {
        print("No data found in Firestore.");
        setState(() => isLoading = false);
      }
    } catch (e) {
      print('Error fetching vegetable prices: $e');
      setState(() => isLoading = false);
    }
  }
Future<void> _launchUrl(Uri url) async {
  if (await canLaunchUrl(url)) {
    await launchUrl(url, mode: LaunchMode.inAppBrowserView);
  } else {
    debugPrint("Could not launch $url");
  }
}


  Future<void> fetchOfferDetails() async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('OfferDetails')
          .doc(
              'tcQ5jNhydeqxtiVMTWWK') // Ensure this is the correct Firestore document ID
          .get();

      if (snapshot.exists) {
        setState(() {
          offerDetails = snapshot["offer"] ?? "No offer available";
        });
      } else {
        setState(() {
          offerDetails = "No offer available";
        });
      }
    } catch (e) {
      print('Error fetching offer details: $e');
      setState(() {
        offerDetails = "Error loading offer details";
      });
    }
  }

  void _filterSearchResults(String query) {
    List<Map<String, dynamic>> results = [];
    if (query.isEmpty) {
      results = menuItems; // No search query, show all items
    } else {
      // Check if any part of the vegetable name contains the query (case-insensitive)
      results = menuItems.where((item) {
        return item["title"].toLowerCase().contains(query.toLowerCase());
      }).toList();
    }
    setState(() {
      _filteredItems = results;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchOfferDetails();
    fetchVegetablePrices();
    _filteredItems = menuItems;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 70,
        title: const Center(
          child: Text.rich(
            TextSpan(
              text: "फ्रेश ",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 34,
                color: Colors.black,
              ),
              children: <TextSpan>[
                TextSpan(
                  text: "भाजीपाला",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 35,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
          ),
        ),
        backgroundColor: Colors.green,
        actions: [
          Consumer<CartProvider>(
            builder: (context, cartProvider, child) {
              return IconButton(
                icon: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Icon(
                      Icons.shopping_cart_outlined,
                      size: 31,
                      color: Colors.black,
                    ),
                    if (cartProvider.cartItemCount > 0)
                      Positioned(
                        top: 0,
                        right: 0,
                        child: CircleAvatar(
                          radius: 10,
                          backgroundColor: Colors.red,
                          child: Text(
                            cartProvider.cartItemCount.toString(),
                            style: const TextStyle(
                                fontSize: 12, color: Colors.white),
                          ),
                        ),
                      ),
                  ],
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CartScreen(),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
      drawer: Drawer(
        backgroundColor: Colors.white,
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
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
            //const SizedBox(height: 10),
            ListTile(
              leading: const Image(
                  image: AssetImage('assets/greenVegetables/home.gif')),
              title: const Text(
                'होम',
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HomeScreen(),
                  ), // Navigate to CartScreen
                );
                // Navigator.pushNamed(context, '/tttt');
              },
            ),
            // const SizedBox(height: 10),
            ListTile(
              leading: const Image(
                  image: AssetImage('assets/greenVegetables/grocery.gif')),
              title: const Text(
                'कार्ट',
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
              onTap: () {
                Navigator.pop(context); // Close the Drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CartScreen(),
                  ), // Navigate to CartScreen
                );
              },
            ),
            // const SizedBox(height: 10),

            ListTile(
              leading: const Image(
                image: AssetImage('assets/greenVegetables/profile.gif'),
              ),
              title: const Text(
                'प्रोफाइल',
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => ProfileScreen()));
                Navigator.pushNamed(context, '/profile');
              },
            ),
            //const SizedBox(height: 10),
            ListTile(
              leading: const Image(
                image: AssetImage('assets/animation/contact.gif'),
              ),
              title: const Text(
                'संपर्क साधा',
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ContactUs(),
                    ));
                Navigator.pushNamed(context, '/contact');
              },
            ),
            ListTile(
              leading:  Image(
                image: AssetImage('assets/animation/review.gif'),
              ),
              title: Text(
                'अभिप्राय',
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MoodReviewScreen(),
                    ));
                Navigator.pushNamed(context, '/contact');
              },
            ),

            ListTile(
              leading: const Image(
                image: AssetImage('assets/animation/boy.gif'),
              ),
              title: const Text(
                'आमच्याबद्दल',
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AboutUsScreen(),
                    ));
                Navigator.pushNamed(context, '/contact');
              },
            ),

            const SizedBox(
              height: 100,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
               
               
                IconButton(
                  onPressed: () {
                    final Uri whatsappGroupUrl = Uri.parse(
                        'https://chat.whatsapp.com/L3dnGGUjzvcJok4vQqsoI8');
                    launchUrl(whatsappGroupUrl,
                        mode: LaunchMode.externalApplication);
                  },
                  icon: const FaIcon(
                    FontAwesomeIcons.whatsapp,
                    color: Colors.green,
                    size: 32.0,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    debugPrint(
                      'Facebook Tapped',
                    );
                    Uri fburl = Uri.parse(
                        'https://www.facebook.com/eenadupellipandiriofficial');
                    _launchUrl(fburl);
                  },
                  icon: const FaIcon(
                    FontAwesomeIcons.facebook,
                    color: Colors.blue,
                    size: 32.0,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    debugPrint(
                      'Instagram Tapped',
                    );
                    Uri instaurl =
                        Uri.parse
                        (

                          'https://www.instagram.com/_u/rajelove99/'
                         
                        );
                    _launchUrl(instaurl);
                  },
                  icon: const FaIcon(
                    FontAwesomeIcons.instagram,
                    color: Colors.red,
                    size: 32.0,
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 20,
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
          : _buildScreenBody(),
    
    
      bottomNavigationBar: CurvedNavigationBar(
        color: Colors.grey.shade300,
        key: _bottomNavigationKey,
        index: 0,
        items: <Widget>[
          Icon(Icons.grass, size: 30, color: Colors.black),
          Icon(Icons.egg, size: 30, color: Colors.black),
          Icon(Icons.list, size: 30, color: Colors.black),
        ],


        backgroundColor: Colors.white,
        
        animationCurve: Curves.fastEaseInToSlowEaseOut,
        animationDuration: Duration(milliseconds: 300
        ),
        onTap: (index) {
            HapticFeedback.mediumImpact(); 
          setState(() {
            _selectedIndex = index;
          });
        },
        letIndexChange: (index) => true,
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Function to handle different body content based on selected index
  Widget _buildScreenBody() {
    switch (_selectedIndex) {
      case 0:
        return _buildVeggieScreen();
      case 1:
        return const EggsScreen();
      case 2:
        return const OrderScreen();

      default:
        return const SizedBox();
    }
  }

  Widget _buildVeggieScreen() {
    return Padding(
      padding: const EdgeInsets.only(top: 20, right: 10, left: 10),
      child: Column(
        children: [
          AnimatedTextKit(
            animatedTexts: [
              TypewriterAnimatedText(
                offerDetails,
                textStyle: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
                speed: const Duration(milliseconds: 50),
              ),
            ],
            totalRepeatCount: 8,
            pause: const Duration(milliseconds: 500),
            displayFullTextOnTap: true,
            stopPauseOnTap: true,
          ),
          const SizedBox(
            height: 10,
          ),
          TextField(
            cursorHeight: 25,
            controller: _searchController,
            decoration: const InputDecoration(
              labelText: 'इथे भाज्या मराठी अक्षरांमध्ये शोधा...',
              hintStyle: TextStyle(color: Colors.black, fontSize: 35),
              border: OutlineInputBorder(),
            ),
            onChanged: (query) {
              _filterSearchResults(query);
            },
          ),
          const SizedBox(
            height: 20,
          ),
          Consumer<CartProvider>(
            builder: (context, cartProvider, child) {
              return Expanded(
                child: _filteredItems.isEmpty
                    ? const Center(
                        child: Text(
                          "भाज्या अवैलेबल नाहीत",
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                      )
                    : GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.6,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        itemCount: _filteredItems.length,
                        itemBuilder: (context, index) {
                          var filteredItem = _filteredItems[index];

                          var cartItem = cartProvider.cartItems.firstWhere(
                            (cartItem) =>
                                cartItem['title'] == filteredItem['title'],
                            orElse: () => {},
                          );

                          int currentCount = cartItem.isNotEmpty
                              ? cartItem['quantity'] ?? 0
                              : 0;

                          return GestureDetector(
                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              elevation: 20,
                              color: Colors.white,
                              shadowColor: Colors.black45,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const SizedBox(height: 10),
                                  Image.asset(
                                    _filteredItems[index]["image"],
                                    height: 140,
                                    width: double.maxFinite,
                                    fit: BoxFit.fill,
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    '${_filteredItems[index]["title"]}',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                                  ),
                                  Text(
                                    '   250 ग्राम (पावकीलो)',
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.pink.shade400,
                                    ),
                                  ),
                                  Text(
                                    _filteredItems[index]["price"],
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.remove),
                                        onPressed: () {
                                          if (currentCount > 0) {
                                            cartProvider.removeFromCart(
                                                menuItems[index]);
                                          }
                                        },
                                      ),
                                      AnimatedSwitcher(
                                        duration:
                                            const Duration(milliseconds: 200),
                                        child: currentCount == 0
                                            ? const Text(
                                                "Add",
                                                key: ValueKey<int>(0),
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              )
                                            : Text(
                                                '$currentCount',
                                                key:
                                                    ValueKey<int>(currentCount),
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.add),
                                        onPressed: () {
                                          cartProvider
                                              .addToCart(menuItems[index]);
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              );
            },
          ),
        ],
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
