import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gromore_application/addToCartScreen.dart';
import 'package:gromore_application/cartScreen.dart';
import 'package:provider/provider.dart';

class EggsScreen extends StatefulWidget {
  const EggsScreen({super.key});

  @override
  State<EggsScreen> createState() => _EggsScreenState();
}

class _EggsScreenState extends State<EggsScreen> {
  bool isLoading = true;
  String offerDetails = '';

  // Fetch the eggs offer from the firebase

  Future<void> fetchOfferDetails() async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('OfferDetails')
          .doc(
              'eggsOffer') // Ensure this is the correct Firestore document ID
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

  //Fetch the eggs price from the firebase
  Future<void> fetchVegetablePrices() async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('EggsPrice')
          .doc('EggsPriceses') // Ensure this is the correct document ID
          .get();

      if (snapshot.exists) {
        Map<String, dynamic> fetchedPrices =
            snapshot.data() as Map<String, dynamic>;

        print("Fetched prices: $fetchedPrices");

        setState(() {
          isLoading = false;

          // Directly updating the prices inside eggItems
          for (var item in eggItems) {
            if (item["title"] == "अंडी (Dozen)") {
              item["price"] = "₹${fetchedPrices["oneDozen"] ?? "N/A"}";
            } else if (item["title"] == "अंडी (halfDozen)") {
              item["price"] = "₹${fetchedPrices["halfDozen"] ?? "N/A"}";
            }
          }
        });
      } else {
        print("No data found in Firestore.");
        setState(() => isLoading = false);
      }
    } catch (e) {
      print('Error fetching egg prices: $e');
      setState(() => isLoading = false);
    }
  }

  // List to store only two eggs items
  final List<Map<String, String>> eggItems = [
    {
      "title": "अंडी (Dozen)",
      "image": "assets/greenVegetables/egg1.jpeg",
      "price": "",
    },
    {
      "title": "अंडी (halfDozen)",
      "image": "assets/greenVegetables/egg2.jpeg",
      "price": "",
    },
  ];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchVegetablePrices();
    fetchOfferDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 
      body: Column(
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
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Consumer<CartProvider>(
                builder: (context, cartProvider, child) {
                  return GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, // Display 2 cards in a row
                      childAspectRatio: 0.65,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: eggItems.length, // Will be 2 items now
                    itemBuilder: (context, index) {
                      // Check the current count of the item in the cart
                      int currentCount = cartProvider.cartItems.firstWhere(
                            (cartItem) =>
                                cartItem['title'] == eggItems[index]["title"],
                            orElse: () =>
                                {}, // Return an empty map if no matching item is found
                          )['quantity'] ??
                          0;

                      return GestureDetector(
                        onTap: () {
                          // Handle tap if needed
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
                              const SizedBox(height: 10),
                              Image.asset(
                                eggItems[index]["image"]!,
                                height: 140,
                                width: 140,
                                fit: BoxFit.fill,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                eggItems[index]["title"]!,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                              Text(
                                eggItems[index]["price"]!,
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
                                            .removeFromCart(eggItems[index]);
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
                                      cartProvider.addToCart(eggItems[index]);
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
