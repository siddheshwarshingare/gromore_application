import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:gromore_application/cart/addToCartScreen.dart';
import 'package:gromore_application/cart/cartScreen.dart';
import 'package:gromore_application/contact/contact_us.dart';
import 'package:gromore_application/eggs/eggs_screen.dart';
import 'package:gromore_application/login/loginScreen.dart';
import 'package:gromore_application/order/order_screen.dart';
import 'package:gromore_application/order/totalOrderScreen.dart';
import 'package:gromore_application/userProfileScreen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // List to store counts for each item
  final List<int> itemCounts = List.filled(12, 0);
  bool isLoading = true;
  String offerDetails = '';
  int _selectedIndex = 0;

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
            "allu": fetchedPrices["alluVegetablesPrice"] ?? "N/A"
          };

          // Mapping between Hindi titles and the corresponding vegetable keys
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
    super.initState();
    fetchOfferDetails();
    fetchVegetablePrices();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 70,
        title: const Center(
          child: Text.rich(
            TextSpan(
              text: "Veggie",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 32,
                color: Colors.black,
              ),
              children: <TextSpan>[
                TextSpan(
                  text: " Fresh",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 32,
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
                    MaterialPageRoute(builder: (context) => CartScreen()),
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
             DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.white,
              ),
              child: Column(
                children: [
                  SizedBox(
                    height: 130,
                    child: Image(
                      image: AssetImage('assets/greenVegetables/vegetable.png'),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 10),
            ListTile(
              leading:
                  Image(image: AssetImage('assets/greenVegetables/home.gif')),
              title: const Text(
                'Home',
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/tttt');
              },
            ),
            SizedBox(height: 10),
            ListTile(
              leading: Image(
                  image: AssetImage('assets/greenVegetables/grocery.gif')),
              title: const Text(
                'Cart',
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
              onTap: () {
                Navigator.pop(context); // Close the Drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CartScreen(),
                  ), // Navigate to CartScreen
                );
              },
            ),
            SizedBox(height: 10),
            ListTile(
              leading:
                  Image(image: AssetImage('assets/greenVegetables/cart.gif')),
              title: const Text(
                'Order History',
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AllOrdersScreen(),
                      
                      
                     // OrderScreen(),
                    ));
                // Navigator.pop(context);
                // Navigator.pushNamed(context, '/orders');
              },
            ),
            const SizedBox(height: 10),
            ListTile(
              leading: Image(
                  image: AssetImage('assets/greenVegetables/profile.gif')),
              title: const Text(
                'Profile',
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>ProfileScreen(),
                  ), // Navigate to CartScreen
                );

                // Navigator.pop(context);
                Navigator.pushNamed(context, '/profile');
              },
            ),
            SizedBox(height: 10),
            ListTile(
              leading: Image(
                  image: AssetImage('assets/greenVegetables/settings.gif')),
              title: const Text(
                'Settings',
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ContactUs(),
                  ), // Navigate to CartScreen
                );

                // Navigator.pop(context);
                Navigator.pushNamed(context, '/settings');
              },
            ),
           
           
          ],
        ),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _buildScreenBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black,
        type: BottomNavigationBarType.fixed,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.grass,
              size: 30,
              color: Colors.black,
            ),
            label: 'Veggie',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.egg, size: 30),
            label: 'Eggs',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list, size: 30),
            label: 'Orders',
          ),
        ],
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
        return OrderScreen();

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
          SizedBox(
            height: 20,
          ),
          Consumer<CartProvider>(
            builder: (context, cartProvider, child) {
              return Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.7,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: menuItems.length,
                  itemBuilder: (context, index) {
                    int currentCount = cartProvider.cartItems.firstWhere(
                          (cartItem) =>
                              cartItem['title'] == menuItems[index]["title"],
                          orElse: () =>
                              {}, // Return an empty map if no matching item is found
                        )['quantity'] ??
                        0;

                    return GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(
                            context, menuItems[index]["vegetablesName"]);
                      },
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
                            SizedBox(height: 10),
                            Image.asset(
                              menuItems[index]["image"],
                              height: 140,
                              width: double.maxFinite,
                              fit: BoxFit.fill,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              menuItems[index]["title"],
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                            Text(
                              menuItems[index]["price"],
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
                                      cartProvider
                                          .removeFromCart(menuItems[index]);
                                    }
                                  },
                                ),
                                AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 200),
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
                                          key: ValueKey<int>(currentCount),
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add),
                                  onPressed: () {
                                    cartProvider.addToCart(menuItems[index]);
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
}
