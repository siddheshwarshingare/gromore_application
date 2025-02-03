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
  // List to store only two eggs items
  final List<Map<String, String>> eggItems = [
    {
      "title": "Eggs (Dozen)",
      "image": "assets/greenVegetables/egg1.jpeg", 
      "price": "₹150",
    },
    {
      "title": "Eggs (Pack of 6)",
      "image": "assets/greenVegetables/egg2.jpeg", 
      "price": "₹75",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Eggs",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 25),),
        backgroundColor: Colors.green,
        actions: [
          // Cart Icon
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
                            style: const TextStyle(fontSize: 12, color: Colors.white),
                          ),
                        ),
                      ),
                  ],
                ),
                onPressed: () {
                  // Navigate to cart screen
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Consumer<CartProvider>(
          builder: (context, cartProvider, child) {
            return GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
                  orElse: () => {}, // Return an empty map if no matching item is found
                )['quantity'] ?? 0;

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
                                  cartProvider.removeFromCart(eggItems[index]);
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
    );
  }
}

