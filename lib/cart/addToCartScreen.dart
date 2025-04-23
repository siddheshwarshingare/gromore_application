import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class CartProvider with ChangeNotifier {
  List<Map<String, dynamic>> _cartItems = [];

  List<Map<String, dynamic>> get cartItems => _cartItems;

  double get totalPrice {
    double total = 0.0;
    for (var item in _cartItems) {
      final price = double.tryParse(item['price'].substring(1)) ?? 0.0;
      total += price * (item['quantity'] ?? 0);
    }
    return total;
  }

  void updateVegetableQuantity(String title, int newQuantity) async {
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

    String? firestoreField = vegetableFieldMapping[title];
    if (firestoreField == null) {
      print("Error: No mapping found for vegetable $title");
      return;
    }

    DocumentReference productRef = FirebaseFirestore.instance
        .collection('VegetablesPrice')
        .doc('QuantityOfVegetable');

    try {
      DocumentSnapshot docSnapshot = await productRef.get();
      String currentQuantity = docSnapshot[firestoreField] ?? '0kg';
      int currentQuantityValue =
          int.tryParse(currentQuantity.replaceAll('kg', '')) ?? 0;
      int updatedQuantity = currentQuantityValue + newQuantity;

      await productRef.update({
        firestoreField: '${updatedQuantity}kg',
      });

      print("$firestoreField updated to ${updatedQuantity}kg successfully!");
    } catch (error) {
      print("Error updating Firestore: $error");
    }
  }

  // ✅ Save cart to SharedPreferences
  Future<void> saveCartToLocal() async {
    final prefs = await SharedPreferences.getInstance();
    String cartJson = jsonEncode(_cartItems);
    await prefs.setString('cart_items', cartJson);
  }

  // ✅ Load cart from SharedPreferences
  Future<void> loadCartFromLocal() async {
    final prefs = await SharedPreferences.getInstance();
    String? cartJson = prefs.getString('cart_items');

    if (cartJson != null) {
      List<dynamic> decoded = jsonDecode(cartJson);
      _cartItems = decoded.map((e) => Map<String, dynamic>.from(e)).toList();
      notifyListeners();
    }
  }

  // ✅ Clear cart from SharedPreferences
  Future<void> clearCartFromLocal() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('cart_items');
    _cartItems.clear();
    notifyListeners();
  }

  void addToCart(Map<String, dynamic> product) {
    int index = _cartItems.indexWhere((element) => element['title'] == product['title']);
    if (index != -1) {
      _cartItems[index]['quantity'] =
          (_cartItems[index]['quantity'] as int) + 1;
    } else {
      _cartItems.add({...product, 'quantity': 1});
    }
    saveCartToLocal(); // Save after adding
    notifyListeners();
  }

  void removeFromCart(Map<String, dynamic> product) {
    int index = _cartItems.indexWhere((element) => element['title'] == product['title']);
    if (index != -1) {
      int currentQuantity = _cartItems[index]['quantity'] as int;
      if (currentQuantity > 1) {
        _cartItems[index]['quantity'] = currentQuantity - 1;
      } else {
        _cartItems.removeAt(index);
      }
      saveCartToLocal(); // Save after removing
      notifyListeners();
    }
  }

  int get cartItemCount {
    return _cartItems.length;
  }
}
