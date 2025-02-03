import 'package:flutter/material.dart';
class CartProvider with ChangeNotifier {
  List<Map<String, dynamic>> _cartItems = [];

  List<Map<String, dynamic>> get cartItems => _cartItems;

  double get totalPrice {
    double total = 0.0;
    for (var item in _cartItems) {
      final price = double.tryParse(item['price'].substring(1)) ?? 0.0; // Convert price string to double
      total += price * (item['quantity'] ?? 0);
    }
    return total;
  }

  void addToCart(Map<String, dynamic> item) {
    // Check if item already exists in cart
    final existingItemIndex =
        _cartItems.indexWhere((cartItem) => cartItem['title'] == item['title']);
    if (existingItemIndex >= 0) {
      // If item already exists, increase its quantity
      _cartItems[existingItemIndex]['quantity']++;
    } else {
      // If item doesn't exist, add it to the cart with a quantity of 1
      _cartItems.add({...item, 'quantity': 1});
    }
    notifyListeners();
  }

  void removeFromCart(Map<String, dynamic> item) {
    final existingItemIndex =
        _cartItems.indexWhere((cartItem) => cartItem['title'] == item['title']);
    if (existingItemIndex >= 0) {
      if (_cartItems[existingItemIndex]['quantity'] > 1) {
        // If quantity is more than 1, just reduce the quantity
        _cartItems[existingItemIndex]['quantity']--;
      } else {
        // If quantity is 1, remove the item from the cart completely
        _cartItems.removeAt(existingItemIndex);
      }
    }
    notifyListeners();
  }
int get cartItemCount {
  int count = 0;
  for (var item in _cartItems) {
    count += (item['quantity'] ?? 0) as int; // Casting to int
  }
  return count;
}

}
