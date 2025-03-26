import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CartProvider with ChangeNotifier {
  List<Map<String, dynamic>> _cartItems = [];

  List<Map<String, dynamic>> get cartItems => _cartItems;

  double get totalPrice {
    double total = 0.0;
    for (var item in _cartItems) {
      final price = double.tryParse(item['price'].substring(1)) ??
          0.0; // Convert price string to double
      total += price * (item['quantity'] ?? 0);
    }
    return total;
  }
void updateVegetableQuantity(String title, int newQuantity) async {
  // Mapping vegetable names to Firestore field names
  Map<String, String> vegetableFieldMapping = {
    "मेथी": "methiVegetablesQuantity",
    "गवार": "gavarVegetablesQuantity",
    "पालक": "palakVegetablesQuantity",
    "चवली": "chavaliVegetablesQuantity",
    "कोथिंबीर": "kothimbirVegetablesQuantity",
    "शेपू": "shepuVegetablesQuantity",
    "कंदे": "kandeVegetablesQuantity",
    "भेंडी": "bhendiVegetablesQuantity",
    "आलू": "alluVegetablesQuantity",
    "काकड़ी": "kakdiVegetablesQuantity",
    "कांदा पथ": "kandaPathVegetablesQuantity",
    "करले": "karleVegetablesQuantity",
    "फुलगोबी": "pattagobiVegetablesQuantity",
    "वालाच्या शेंगा": "valachyashengaVegetablesQuantity",
  };

  // Check if the title exists in the mapping
  String? firestoreField = vegetableFieldMapping[title];

  if (firestoreField == null) {
    print("Error: No mapping found for vegetable $title");
    return;
  }

  // Firestore document reference
  DocumentReference productRef = FirebaseFirestore.instance
      .collection('VegetablesPrice')
      .doc('QuantityOfVegetable');

  try {
    // Fetch the current value from Firestore
    DocumentSnapshot docSnapshot = await productRef.get();
    String currentQuantity = docSnapshot[firestoreField] ?? '0kg';

    // Remove 'kg' and convert the remaining string to an integer
    int currentQuantityValue = int.tryParse(currentQuantity.replaceAll('kg', '')) ?? 0;

    // Add the newQuantity to the current quantity
    int updatedQuantity = currentQuantityValue + newQuantity;

    // Update the quantity in Firestore
    await productRef.update({
      firestoreField: '${updatedQuantity}kg',
    });

    print("$firestoreField updated to ${updatedQuantity}kg successfully!");
  } catch (error) {
    print("Error updating Firestore: $error");
  }
}
// Future<double> get discountedTotalPrice async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   final double? decimal = prefs.getDouble('discount');
  //   print("111111111111111ttttttttttttttt$decimal");
  //   double total = 0.0;
  //   for (var item in cartItems) {
  //     final price = double.tryParse(item['price'].substring(1)) ?? 0.0;
  //     total += price * (item['quantity'] ?? 0);
  //   }
  //   double discount = total * 0.15;
  //   // double discount = total * decimal!; // 15% Discount
  //   return total - discount; // Final price after discount
  // }

  void addToCart(Map<String, dynamic> product) {
    // Check if the product already exists in the cart based on its title
    int index = _cartItems
        .indexWhere((element) => element['title'] == product['title']);
    if (index != -1) {
      // Increase the quantity for the existing vegetable
      _cartItems[index]['quantity'] =
          (_cartItems[index]['quantity'] as int) + 1;
    } else {
      // Add as a new unique entry with initial quantity 1
      _cartItems.add({...product, 'quantity': 1});
    }
    notifyListeners();
  }

  void removeFromCart(Map<String, dynamic> product) {
    int index = _cartItems
        .indexWhere((element) => element['title'] == product['title']);
    if (index != -1) {
      int currentQuantity = _cartItems[index]['quantity'] as int;
      if (currentQuantity > 1) {
        _cartItems[index]['quantity'] = currentQuantity - 1;
      } else {
        _cartItems.removeAt(index);
      }
      notifyListeners();
    }
  }

  int get cartItemCount {
    return _cartItems.length;
  }

  // int get cartItemCount {
  //   int count = 0;
  //   for (var item in _cartItems) {
  //     count += (item['quantity'] ?? 0) as int; // Casting to int
  //   }
  //   return count;
  // }
}
