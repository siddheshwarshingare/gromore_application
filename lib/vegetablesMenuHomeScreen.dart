import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:gromore_application/addToCartScreen.dart';
import 'package:gromore_application/cartScreen.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // List to store counts for each item
  final List<int> itemCounts = List.filled(8, 0);
  bool isLoading = true;
  String offerDetails = '';
   int _selectedIndex = 0;

  final List<Widget> _screens = [
    HomeScreen(),  // Home
    CartScreen(),  // Cart
    // OrderScreen(), // Orders
    // ProfileScreen(), // Profile
    // SettingsScreen(), // Settings
  ];

  void _onItemTapped(int index) {
    setState(() {
      _screens[index];
    });
  }
  final List<Map<String, dynamic>> menuItems = [
    {
      "title": "मेथी",
      "image": "assets/greenVegetables/methiBhaji.jpg",
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
      "image": "assets/greenVegetables/chvali.jpeg",
      "vegetablesName": "/orders",
      "price": ''
    },
    {
      "title": "कथिम्बीर",
      "image": "assets/greenVegetables/kothimbir.jpg",
      "vegetablesName": "/profile",
      "price": ''
    },
    {
      "title": "शेपू",
      "image": "assets/greenVegetables/shepu.jpg",
      "vegetablesName": "/settings",
      "price": ''
    },
    {
      "title": "कंदे",
      "image": "assets/greenVegetables/kande.jpg",
      "vegetablesName": "/vegetables",
      "price": ''
    },
    {
      "title": "भेंडी",
      "image": "assets/greenVegetables/bhendi.jpg",
      "vegetablesName": "/fruits",
      "price": ''
    },
  ];
  Future<void> fetchVegetablePrices() async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('VegetablesPrice')
          .doc(
              'vegetablePrices') // Ensure this is the correct Firestore document ID
          .get();

      if (snapshot.exists) {
        Map<String, dynamic> fetchedPrices =
            snapshot.data() as Map<String, dynamic>;

        // Debugging: Print fetched prices to see if the data is being fetched correctly
        print("Fetched prices: $fetchedPrices");

        setState(() {
          isLoading = false;

          // Store all fetched prices in a map
          Map<String, String> vegetablePrices = {
            "bhendi": fetchedPrices["bhendiVegetablesPrice"] ?? "N/A",
            "chavali": fetchedPrices["chavaliVegetablesPrice"] ?? "N/A",
            "chuka": fetchedPrices["chukaVegetablesPrice"] ?? "N/A",
            "dodka": fetchedPrices["dodkaVegetablesPrice"] ?? "N/A",
            "gavar": fetchedPrices["gavarVegetablesPrice"] ?? "N/A",
            "kakdi": fetchedPrices["kakdivegetablesPrice"] ?? "N/A",
            "kandaPath": fetchedPrices["kandaPathVegetablesPrice"] ?? "N/A",
            "kande": fetchedPrices["kandeVegetablesPrice"] ?? "N/A",
            "karle": fetchedPrices["karleVegetablesPrice"] ?? "N/A",
            "kothimbir": fetchedPrices["kothimbirVegetablesPrice"] ?? "N/A",
            "methi": fetchedPrices["methiVegetablesPrice"] ?? "N/A",
            "palak": fetchedPrices["palakVegetablesPrice"] ?? "N/A",
            "shepu": fetchedPrices["shepuVegetablesPrice"] ?? "N/A",
          };

          // Mapping between Hindi titles and the corresponding vegetable keys
          Map<String, String> titleToKeyMap = {
            "मेथी": "methi",
            "गवार": "gavar",
            "पालक": "palak",
            "चवली": "chavali",
            "चूका": "chuka",
            "कथिम्बीर": "kothimbir",
            "शेपू": "shepu",
            "भेंडी": "bhendi",
            "कांदा पथ": "kandaPath",
            "कंदे": "kande",
            "करले": "karle",
            "डोकडा": "dodka",
            "काकड़ी": "kakdi",
          };

          // Update menuItems prices dynamically
          for (var item in menuItems) {
            // Get the title and map it to the corresponding vegetable key
            String vegetableKey = titleToKeyMap[item["title"]] ?? "";

            // Debugging: Print the vegetable key to check if it matches correctly
            print("Looking for price for: $vegetableKey");

            if (vegetablePrices.containsKey(vegetableKey)) {
              item["price"] =
                  "₹${vegetablePrices[vegetableKey]}"; // Assign the price dynamically
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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchOfferDetails();
    fetchVegetablePrices();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Center(
            child: Text(
              "Veggie Fresh",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
//         leading: IconButton(
//   icon: Icon(Icons.shopping_cart),
//   onPressed: () {
//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (context) => CartScreen()),
//     );
//   },
// ),

          backgroundColor: Colors.green,
          actions: [
            Consumer<CartProvider>(
              builder: (context, cartProvider, child) {
                return IconButton(
                  icon: Stack(
                    children: [
                      Icon(Icons.shopping_cart,size:31),
                      if (cartProvider.cartItemCount > 0)
                        Positioned(
                          right: 0,
                          left: 5,
                          // top: 2,
                          bottom: 10,
                          child: CircleAvatar(
                            radius: 10,
                            backgroundColor: Colors.red,
                            child: Text(
                              cartProvider.cartItemCount.toString(),
                              style:
                                  TextStyle(fontSize: 12, color: Colors.white),
                            ),
                          ),
                        ),
                    ],
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CartScreen()),
                    );
                  },
                );
              },
            ),
          ],
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.green,
                ),
                child: Column(
                  children: [
                    Text(
                      'Menu',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              ListTile(
                title: Text('Home'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/tttt');
                },
              ),
              ListTile(
                title: Text('Cart'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/cart');
                },
              ),
              ListTile(
                title: Text('Orders'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/orders');
                },
              ),
              ListTile(
                title: Text('Profile'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/profile');
                },
              ),
              ListTile(
                title: Text('Settings'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/settings');
                },
              ),
            ],
          ),
        ),
        body: isLoading
            ? Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    AnimatedTextKit(
                      animatedTexts: [
                        TypewriterAnimatedText(
                          offerDetails,
                          textStyle: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                          speed: Duration(
                              milliseconds: 50), // Adjust speed as needed
                        ),
                      ],
                      totalRepeatCount: 8,
                      // Adjust how many times the animation should repeat
                      pause: Duration(
                          milliseconds: 500), // Pause between repetitions
                      displayFullTextOnTap: true, // Show full text when tapped
                      stopPauseOnTap: true, // Pause animation when tapped
                    ),
                    // Text(offerDetails, style: TextStyle(fontSize: 17),),
                    Consumer<CartProvider>(
                      builder: (context, cartProvider, child) {
                        return Expanded(
                          child: GridView.builder(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.65,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                            ),
                            itemCount: menuItems.length,
                            itemBuilder: (context, index) {
                              int currentCount =
                                  cartProvider.cartItems.firstWhere(
                                        (cartItem) =>
                                            cartItem['title'] ==
                                            menuItems[index]["title"],
                                        orElse: () =>
                                            {}, // Return an empty map if no matching item is found
                                      )['quantity'] ??
                                      0;

                              return GestureDetector(
                                onTap: () {
                                  Navigator.pushNamed(context,
                                      menuItems[index]["vegetablesName"]);
                                },
                                child: Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  elevation: 10,
                                  color: Colors.white,
                                  shadowColor: Colors.greenAccent,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(height: 10),
                                      Image.asset(
                                        menuItems[index]["image"],
                                        height: 140,
                                        width: 140,
                                        fit: BoxFit.fill,
                                      ),
                                      SizedBox(height: 10),
                                      Text(
                                        menuItems[index]["title"],
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green,
                                        ),
                                      ),
                                      // SizedBox(height: 10),
                                      Text(
                                        menuItems[index]["price"],
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green,
                                        ),
                                      ),
                                      //  SizedBox(height: 15),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          IconButton(
                                            icon: Icon(Icons.remove),
                                            onPressed: () {
                                              if (currentCount > 0) {
                                                cartProvider.removeFromCart(
                                                    menuItems[index]);
                                              }
                                            },
                                          ),
                                          AnimatedSwitcher(
                                            duration:
                                                Duration(milliseconds: 200),
                                            child: currentCount == 0
                                                ? Text(
                                                    "Add",
                                                    key: ValueKey<int>(0),
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  )
                                                : Text(
                                                    '$currentCount',
                                                    key: ValueKey<int>(
                                                        currentCount),
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                          ),
                                          IconButton(
                                            icon: Icon(Icons.add),
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
                    )
                  ],
                ),
              ),
        bottomNavigationBar: BottomNavigationBar(
            currentIndex: _selectedIndex,
            selectedItemColor: Colors.green,
            unselectedItemColor: Colors.grey,
            type: BottomNavigationBarType.fixed,
            onTap: _onItemTapped,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.shopping_cart),
                label: 'Cart',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.list),
                label: 'Orders',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Profile',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings),
                label: 'Settings',
              )
            ]));
  }
}
