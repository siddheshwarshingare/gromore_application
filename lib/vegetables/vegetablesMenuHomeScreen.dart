import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gromore_application/cart/addToCartScreen.dart';
import 'package:gromore_application/cart/cartScreen.dart';
import 'package:gromore_application/contact/contact_us.dart';
import 'package:gromore_application/eggs/eggs_screen.dart';
import 'package:gromore_application/order/order_screen.dart';
import 'package:gromore_application/order/totalOrderScreen.dart';
import 'package:gromore_application/userProfileScreen.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

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
            "allu": fetchedPrices["alluVegetablesPrice"] ?? "N/A",
            "vange": fetchedPrices["vangeVegetablesPrice"] ?? "N/A",
            "gobi": fetchedPrices["gobiVegetablesPrice"] ?? "N/A",
            "pattagobi": fetchedPrices["pattagobiVegetablesPrice"] ?? "N/A",
            "valachyashenga":
                fetchedPrices["valachyashengaVegetablesPrice"] ?? "N/A"   
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
            "वांगे": "vange",
            "फुलगोबी": "gobi",
            "पत्तागोबी": "pattagobi",
            "वालाच्या शेंगा": "valachyashenga",
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

  Future<void> _launchUrl(Uri url) async {
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
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
                      builder: (context) => CartScreen(),
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
            const SizedBox(height: 10),
            ListTile(
              leading: const Image(
                  image: AssetImage('assets/greenVegetables/home.gif')),
              title: const Text(
                'होम',
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/tttt');
              },
            ),
            const SizedBox(height: 10),
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
                    builder: (context) => CartScreen(),
                  ), // Navigate to CartScreen
                );
              },
            ),
            const SizedBox(height: 10),
            ListTile(
              leading: const Image(
                  image: AssetImage('assets/greenVegetables/cart.gif')),
              title: const Text(
                'ऑर्डर हिस्ट्री',
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AllOrdersScreen(),

                      // OrderScreen(),
                    ));
              },
            ),
            const SizedBox(height: 10),
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
            const SizedBox(height: 10),
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
            const SizedBox(
              height: 250,
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
                        Uri.parse('instagram://user?username=rajelove99');
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
          ],
        ),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _buildScreenBody(),
      bottomNavigationBar: BottomNavigationBar(
        // selectedLabelStyle: TextStyle(fontSize: 25),
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
            label: 'भाजी',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.egg, size: 30),
            label: 'अंडी',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list, size: 30),
            label: 'ऑर्डर',
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
          SizedBox(
            height: 10,
          ),
          TextField(
            cursorHeight: 25,
            controller: _searchController,
            decoration: InputDecoration(
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
                    ? Center(
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
                      // onTap: () {
                      //   Navigator.pushNamed(
                      //       context, _filteredItems[index]["vegetablesName"]);
                      // },
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
