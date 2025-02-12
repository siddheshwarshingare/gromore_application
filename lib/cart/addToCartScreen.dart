import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';

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
