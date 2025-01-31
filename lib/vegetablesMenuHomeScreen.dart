import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

  class _HomeScreenState extends State<HomeScreen> {
  // List to store counts for each item
  final List<int> itemCounts = List.filled(8, 0);
  bool isLoading = true;
  final List<Map<String, dynamic>> menuItems = [
    {
      "title": "मेथी",
      "image": "assets/greenVegetables/methiBhaji.jpg",
      "vegetablesName": "/vegetables",
      "price": '20.0₹/250gm'
    },
    {
      "title": "Fruits",
      "image": "assets/greenVegetables/methiBhaji.jpg",
      "vegetablesName": "/fruits",
      "price": '20.0₹/250gm'
    },
    {
      "title": "Cart",
      "image": "assets/greenVegetables/methiBhaji.jpg",
      "vegetablesName": "/cart",
      "price": '20.0₹/250gm'
    },
    {
      "title": "Orders",
      "image": "assets/greenVegetables/methiBhaji.jpg",
      "vegetablesName": "/orders",
      "price": '20.0₹/250gm'
    },
    {
      "title": "Profile",
      "image": "assets/greenVegetables/methiBhaji.jpg",
      "vegetablesName": "/profile",
      "price": '20.0₹/250gm'
    },
    {
      "title": "Settings",
      "image": "assets/greenVegetables/methiBhaji.jpg",
      "vegetablesName": "/settings",
      "price":'20.0₹/250gm'
    },
    {
      "title": "गवार",
      "image": "assets/greenVegetables/methiBhaji.jpg",
      "vegetablesName": "/vegetables",
      "price": '20.0₹/250gm'
    },
    {
      "title": "Fruits",
      "image": "assets/greenVegetables/methiBhaji.jpg",
      "vegetablesName": "/fruits",
      "price": '20.0₹/250gm'
    },
  ];
  Future<void> fetchVegetablePrices() async {
  try {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('VegetablesPrice')
        .doc('gavarVegetablesPrice') // Replace with actual Firestore document ID
        .get();

    if (snapshot.exists) {
      Map<String, dynamic> fetchedPrices = snapshot.data() as Map<String, dynamic>;

      setState(() {
        isLoading = false;

        // Update menuItems prices dynamically
        for (var item in menuItems) {
          String key = item["title"] + "VegetablesPrice"; // Match Firestore field names
          if (fetchedPrices.containsKey(key)) {
            item["price"] = "₹${fetchedPrices[key]}"; // Assign Firestore price
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
@override
  void initState() {
    // TODO: implement initState
    super.initState();
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
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.pushNamed(context, '/cart');
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
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.6,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: menuItems.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, menuItems[index]["vegetablesName"]);
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
                    SizedBox(height: 10),
                    Text(
                      menuItems[index]["price"], // ✅ Updated price from Firestore
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: Icon(Icons.remove),
                          onPressed: () {
                            setState(() {
                              if (itemCounts[index] > 0) {
                                itemCounts[index]--;
                              }
                            });
                          },
                          color: itemCounts[index] == 0 ? Colors.black : Colors.green,
                        ),
                        AnimatedSwitcher(
                          duration: Duration(milliseconds: 200),
                          child: itemCounts[index] == 0
                              ? Text(
                                  "Add",
                                  key: ValueKey<int>(0),
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              : Text(
                                  '${itemCounts[index]}',
                                  key: ValueKey<int>(itemCounts[index]),
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                        IconButton(
                          icon: Icon(Icons.add),
                          color: itemCounts[index] == 0 ? Colors.black : Colors.pink,
                          onPressed: () {
                            setState(() {
                              itemCounts[index]++;
                            });
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
      ),

    );
  }
}
